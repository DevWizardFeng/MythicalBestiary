#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
神兽志 - 图片生成测试脚本
使用 doubao-seedream-4.5 API 生成神话生物图片
"""

import requests
import json
import base64
import os
from datetime import datetime

# API 配置 (不可修改)
BASE_URL = "https://ark.cn-beijing.volces.com/api/v3/images/generations"
API_KEY = "096dd19b-a3ba-4dd1-a610-8c3495b18548"
MODEL = "doubao-seedream-4-5-251128"

# 输出目录
OUTPUT_DIR = os.path.join(os.path.dirname(__file__), "output")


def generate_image(prompt: str, size: str = "2K", save_name: str = None) -> str:
    """
    生成单张图片

    Args:
        prompt: 图片描述提示词
        size: 图片尺寸，可选 "2K", "4K" 或具体像素值如 "2048x2048"
        save_name: 保存的文件名（不含扩展名），默认使用时间戳

    Returns:
        保存的图片路径
    """
    headers = {
        "Content-Type": "application/json",
        "Authorization": f"Bearer {API_KEY}"
    }

    payload = {
        "model": MODEL,
        "prompt": prompt,
        "size": size,
        "watermark": False,
        "response_format": "b64_json",  # 使用base64返回，方便直接保存
        "sequential_image_generation": "disabled"  # 生成单图
    }

    print(f"正在生成图片...")
    print(f"提示词: {prompt}")
    print(f"尺寸: {size}")

    try:
        response = requests.post(BASE_URL, headers=headers, json=payload, timeout=120)
        response.raise_for_status()

        result = response.json()

        if "error" in result:
            print(f"API错误: {result['error']}")
            return None

        if "data" not in result or len(result["data"]) == 0:
            print("未返回图片数据")
            return None

        # 获取图片数据
        image_data = result["data"][0]

        if "error" in image_data:
            print(f"图片生成失败: {image_data['error']}")
            return None

        # 确保输出目录存在
        os.makedirs(OUTPUT_DIR, exist_ok=True)

        # 生成文件名
        if save_name is None:
            save_name = f"creature_{datetime.now().strftime('%Y%m%d_%H%M%S')}"

        file_path = os.path.join(OUTPUT_DIR, f"{save_name}.png")

        # 解码并保存图片
        if "b64_json" in image_data:
            image_bytes = base64.b64decode(image_data["b64_json"])
            with open(file_path, "wb") as f:
                f.write(image_bytes)
            print(f"图片已保存: {file_path}")

            # 打印用量信息
            if "usage" in result:
                usage = result["usage"]
                print(f"生成图片数: {usage.get('generated_images', 'N/A')}")
                print(f"消耗tokens: {usage.get('total_tokens', 'N/A')}")

            return file_path
        elif "url" in image_data:
            # 如果返回的是URL，下载图片
            img_response = requests.get(image_data["url"], timeout=60)
            img_response.raise_for_status()
            with open(file_path, "wb") as f:
                f.write(img_response.content)
            print(f"图片已保存: {file_path}")
            return file_path
        else:
            print("未知的返回格式")
            return None

    except requests.exceptions.Timeout:
        print("请求超时，请重试")
        return None
    except requests.exceptions.RequestException as e:
        print(f"请求失败: {e}")
        return None
    except json.JSONDecodeError as e:
        print(f"JSON解析失败: {e}")
        return None


def test_single_image():
    """测试生成单张神话生物图片"""

    # 测试提示词 - 中国龙
    prompt = """
    一条威严的中国神龙，金色鳞片闪烁着神圣光芒，
    身躯蜿蜒盘旋于云海之上，龙角如鹿角般优雅，
    龙须飘逸，龙爪锋利有力，背景是红色祥云和金色光芒，
    中国传统水墨画风格与现代奇幻风格结合，
    史诗级神话生物插画，高度细节，8K超高清
    """

    result = generate_image(
        prompt=prompt.strip(),
        size="2048x2048",
        save_name="test_chinese_dragon"
    )

    if result:
        print(f"\n测试成功! 图片保存在: {result}")
    else:
        print("\n测试失败，请检查网络连接和API配置")


if __name__ == "__main__":
    print("=" * 50)
    print("神兽志 - 图片生成测试")
    print("=" * 50)
    print()
    test_single_image()
