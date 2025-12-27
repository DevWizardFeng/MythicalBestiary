#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
神兽志 - 并发批量图片生成脚本
使用 doubao-seedream-4.5 API 批量生成神话生物图片

使用方法:
    # 生成全部文化的神兽图片
    python3 batch_image_gen.py

    # 只生成中国神话图片
    python3 batch_image_gen.py --culture chinese

    # 指定并发数
    python3 batch_image_gen.py --max-concurrent 5

    # 使用自定义prompts文件
    python3 batch_image_gen.py --prompts my_prompts.json

依赖安装:
    pip3 install aiohttp
"""

import asyncio
import aiohttp
import json
import base64
import os
import argparse
import logging
from datetime import datetime
from typing import List, Dict, Optional
from pathlib import Path

# API 配置 (不可修改)
BASE_URL = "https://ark.cn-beijing.volces.com/api/v3/images/generations"
API_KEY = "096dd19b-a3ba-4dd1-a610-8c3495b18548"
MODEL = "doubao-seedream-4-5-251128"

# 项目根目录
PROJECT_ROOT = Path(__file__).parent.parent

# 鸿蒙资源目录 (不可嵌套文件夹)
HARMONY_MEDIA_DIR = PROJECT_ROOT / "entry" / "src" / "main" / "resources" / "base" / "media"

# 日志目录
LOG_DIR = Path(__file__).parent / "logs"

# 支持的文化分类
CULTURES = ["chinese", "greek", "norse", "japanese", "indian", "egyptian", "celtic", "icon", "background"]


def setup_logging():
    """配置日志"""
    LOG_DIR.mkdir(parents=True, exist_ok=True)
    log_file = LOG_DIR / f"generation_{datetime.now().strftime('%Y%m%d_%H%M%S')}.log"

    logging.basicConfig(
        level=logging.INFO,
        format='%(asctime)s - %(levelname)s - %(message)s',
        handlers=[
            logging.FileHandler(log_file, encoding='utf-8'),
            logging.StreamHandler()
        ]
    )
    return logging.getLogger(__name__)


logger = setup_logging()


def load_prompts(json_path: str, culture: Optional[str] = None) -> List[Dict]:
    """
    加载提示词配置

    Args:
        json_path: prompts.json 文件路径
        culture: 文化分类筛选 (可选)

    Returns:
        提示词配置列表
    """
    with open(json_path, 'r', encoding='utf-8') as f:
        data = json.load(f)

    creatures = data.get('creatures', [])
    default_settings = data.get('default_settings', {})

    # 为每个creature添加默认设置
    for creature in creatures:
        creature['size'] = creature.get('size', default_settings.get('size', '2048x2048'))
        creature['style_suffix'] = default_settings.get('style_suffix', '')

    # 按文化筛选
    if culture and culture != 'all':
        creatures = [c for c in creatures if c.get('culture') == culture]

    logger.info(f"加载了 {len(creatures)} 个提示词配置")
    return creatures


def get_pending_prompts(prompts: List[Dict], output_dir: Path) -> List[Dict]:
    """
    获取待生成的提示词 (断点续传)

    Args:
        prompts: 全部提示词配置
        output_dir: 输出目录

    Returns:
        待生成的提示词列表
    """
    pending = []
    for p in prompts:
        file_path = output_dir / f"{p['id']}.png"
        if not file_path.exists():
            pending.append(p)
        else:
            logger.info(f"跳过已存在: {p['id']}")

    logger.info(f"待生成: {len(pending)} 个, 已跳过: {len(prompts) - len(pending)} 个")
    return pending


async def generate_image_async(
    session: aiohttp.ClientSession,
    prompt_config: Dict,
    output_dir: Path,
    semaphore: asyncio.Semaphore,
    max_retries: int = 3
) -> Dict:
    """
    异步生成单张图片 (带重试)

    Args:
        session: aiohttp会话
        prompt_config: 提示词配置
        output_dir: 输出目录
        semaphore: 并发限制信号量
        max_retries: 最大重试次数

    Returns:
        生成结果
    """
    async with semaphore:
        creature_id = prompt_config['id']
        name_cn = prompt_config.get('name_cn', creature_id)

        # 构建完整提示词
        full_prompt = prompt_config['prompt']
        if prompt_config.get('style_suffix'):
            full_prompt += prompt_config['style_suffix']

        headers = {
            "Content-Type": "application/json",
            "Authorization": f"Bearer {API_KEY}"
        }

        payload = {
            "model": MODEL,
            "prompt": full_prompt,
            "size": prompt_config.get('size', '2048x2048'),
            "watermark": False,
            "response_format": "b64_json",
            "sequential_image_generation": "disabled"
        }

        for attempt in range(max_retries):
            try:
                logger.info(f"[{attempt + 1}/{max_retries}] 正在生成: {name_cn} ({creature_id})")

                async with session.post(
                    BASE_URL,
                    headers=headers,
                    json=payload,
                    timeout=aiohttp.ClientTimeout(total=180)
                ) as response:
                    if response.status != 200:
                        error_text = await response.text()
                        raise Exception(f"HTTP {response.status}: {error_text}")

                    result = await response.json()

                    if "error" in result:
                        raise Exception(f"API错误: {result['error']}")

                    if "data" not in result or len(result["data"]) == 0:
                        raise Exception("未返回图片数据")

                    image_data = result["data"][0]

                    if "error" in image_data:
                        raise Exception(f"图片生成失败: {image_data['error']}")

                    # 保存图片
                    output_dir.mkdir(parents=True, exist_ok=True)
                    file_path = output_dir / f"{creature_id}.png"

                    if "b64_json" in image_data:
                        image_bytes = base64.b64decode(image_data["b64_json"])
                        with open(file_path, "wb") as f:
                            f.write(image_bytes)

                        # 获取用量信息
                        usage = result.get("usage", {})
                        tokens = usage.get("total_tokens", "N/A")

                        logger.info(f"✓ 生成成功: {name_cn} -> {file_path.name} (tokens: {tokens})")

                        return {
                            "id": creature_id,
                            "name_cn": name_cn,
                            "status": "success",
                            "file_path": str(file_path),
                            "tokens": tokens
                        }
                    else:
                        raise Exception("返回格式不支持")

            except asyncio.TimeoutError:
                logger.warning(f"[{attempt + 1}/{max_retries}] 超时: {name_cn}")
                if attempt < max_retries - 1:
                    wait_time = 2 ** attempt
                    logger.info(f"等待 {wait_time} 秒后重试...")
                    await asyncio.sleep(wait_time)
            except Exception as e:
                logger.warning(f"[{attempt + 1}/{max_retries}] 失败: {name_cn} - {str(e)}")
                if attempt < max_retries - 1:
                    wait_time = 2 ** attempt
                    logger.info(f"等待 {wait_time} 秒后重试...")
                    await asyncio.sleep(wait_time)

        # 所有重试都失败
        logger.error(f"✗ 生成失败: {name_cn} (已重试 {max_retries} 次)")
        return {
            "id": creature_id,
            "name_cn": name_cn,
            "status": "failed",
            "error": "超过最大重试次数"
        }


async def batch_generate(
    prompts: List[Dict],
    output_dir: Path,
    max_concurrent: int = 3,
    max_retries: int = 3
) -> List[Dict]:
    """
    批量并发生成图片

    Args:
        prompts: 提示词配置列表
        output_dir: 输出目录
        max_concurrent: 最大并发数
        max_retries: 最大重试次数

    Returns:
        生成结果列表
    """
    semaphore = asyncio.Semaphore(max_concurrent)

    connector = aiohttp.TCPConnector(limit=max_concurrent, limit_per_host=max_concurrent)
    async with aiohttp.ClientSession(connector=connector) as session:
        tasks = [
            generate_image_async(session, prompt, output_dir, semaphore, max_retries)
            for prompt in prompts
        ]

        results = await asyncio.gather(*tasks, return_exceptions=True)

        # 处理异常
        processed_results = []
        for i, result in enumerate(results):
            if isinstance(result, Exception):
                processed_results.append({
                    "id": prompts[i]['id'],
                    "name_cn": prompts[i].get('name_cn', ''),
                    "status": "error",
                    "error": str(result)
                })
            else:
                processed_results.append(result)

        return processed_results


def print_summary(results: List[Dict]):
    """打印生成摘要"""
    success = [r for r in results if r.get('status') == 'success']
    failed = [r for r in results if r.get('status') != 'success']

    print("\n" + "=" * 60)
    print("生成摘要")
    print("=" * 60)
    print(f"总计: {len(results)}")
    print(f"成功: {len(success)}")
    print(f"失败: {len(failed)}")

    if failed:
        print("\n失败列表:")
        for f in failed:
            print(f"  - {f.get('name_cn', f['id'])}: {f.get('error', 'unknown')}")

    # 计算总tokens
    total_tokens = sum(r.get('tokens', 0) for r in success if isinstance(r.get('tokens'), int))
    if total_tokens > 0:
        print(f"\n总消耗 tokens: {total_tokens}")

    print("=" * 60)


def main():
    parser = argparse.ArgumentParser(description='神兽志 - 批量图片生成工具')
    parser.add_argument(
        '--culture',
        choices=CULTURES + ['all'],
        default='all',
        help='文化分类 (默认: all)'
    )
    parser.add_argument(
        '--max-concurrent',
        type=int,
        default=3,
        help='最大并发数 (默认: 3)'
    )
    parser.add_argument(
        '--max-retries',
        type=int,
        default=3,
        help='最大重试次数 (默认: 3)'
    )
    parser.add_argument(
        '--prompts',
        type=str,
        default=str(Path(__file__).parent / 'prompts.json'),
        help='提示词JSON文件路径'
    )
    parser.add_argument(
        '--output-dir',
        type=str,
        default=str(HARMONY_MEDIA_DIR),
        help=f'输出目录 (默认: {HARMONY_MEDIA_DIR})'
    )
    parser.add_argument(
        '--dry-run',
        action='store_true',
        help='只显示待生成列表，不实际生成'
    )

    args = parser.parse_args()

    print("=" * 60)
    print("神兽志 - 批量图片生成工具")
    print("=" * 60)
    print(f"文化分类: {args.culture}")
    print(f"并发数: {args.max_concurrent}")
    print(f"重试次数: {args.max_retries}")
    print(f"提示词文件: {args.prompts}")
    print(f"输出目录: {args.output_dir}")
    print("=" * 60)

    # 加载提示词
    prompts = load_prompts(args.prompts, args.culture)

    if not prompts:
        print("没有找到匹配的提示词配置")
        return

    # 获取待生成列表
    output_dir = Path(args.output_dir)
    pending = get_pending_prompts(prompts, output_dir)

    if not pending:
        print("所有图片已生成完毕!")
        return

    if args.dry_run:
        print("\n待生成列表 (dry-run 模式):")
        for p in pending:
            print(f"  - {p.get('name_cn', p['id'])} ({p['culture']})")
        print(f"\n共 {len(pending)} 个待生成")
        return

    # 确认开始
    print(f"\n即将生成 {len(pending)} 张图片")
    print("按 Ctrl+C 取消...")
    try:
        import time
        time.sleep(3)
    except KeyboardInterrupt:
        print("\n已取消")
        return

    # 开始批量生成
    start_time = datetime.now()

    results = asyncio.run(
        batch_generate(
            pending,
            output_dir,
            max_concurrent=args.max_concurrent,
            max_retries=args.max_retries
        )
    )

    end_time = datetime.now()
    duration = end_time - start_time

    print_summary(results)
    print(f"总耗时: {duration}")

    # 保存结果到日志
    result_file = LOG_DIR / f"result_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
    with open(result_file, 'w', encoding='utf-8') as f:
        json.dump(results, f, ensure_ascii=False, indent=2)
    print(f"结果已保存: {result_file}")


if __name__ == "__main__":
    main()
