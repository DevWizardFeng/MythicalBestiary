#!/usr/bin/env python3
"""
图标后处理脚本
- 去除背景色（转为透明）
- 裁剪主体区域
- 放大并居中
"""

import os
from PIL import Image
import numpy as np
from pathlib import Path

def remove_background_and_crop(image_path: str, output_path: str,
                                 bg_threshold: int = 30,
                                 padding_ratio: float = 0.05):
    """
    去除背景并裁剪图标主体

    Args:
        image_path: 输入图片路径
        output_path: 输出图片路径
        bg_threshold: 背景检测阈值（边缘像素与中心差异）
        padding_ratio: 裁剪后的边距比例
    """
    # 打开图片
    img = Image.open(image_path).convert('RGBA')
    img_array = np.array(img)

    # 获取四角的颜色作为背景色参考
    h, w = img_array.shape[:2]
    corners = [
        img_array[0, 0, :3],
        img_array[0, w-1, :3],
        img_array[h-1, 0, :3],
        img_array[h-1, w-1, :3]
    ]
    bg_color = np.mean(corners, axis=0).astype(np.uint8)

    # 创建透明度蒙版
    # 计算每个像素与背景色的差异
    diff = np.abs(img_array[:, :, :3].astype(np.int16) - bg_color.astype(np.int16))
    diff_sum = np.sum(diff, axis=2)

    # 差异大于阈值的像素保留，否则设为透明
    alpha_mask = (diff_sum > bg_threshold * 3).astype(np.uint8) * 255

    # 应用透明度
    img_array[:, :, 3] = alpha_mask

    # 找到非透明区域的边界
    non_transparent = np.where(alpha_mask > 0)
    if len(non_transparent[0]) == 0:
        print(f"警告: {image_path} 处理后全透明，跳过")
        return False

    top = np.min(non_transparent[0])
    bottom = np.max(non_transparent[0])
    left = np.min(non_transparent[1])
    right = np.max(non_transparent[1])

    # 计算裁剪区域（保留一定边距）
    content_h = bottom - top
    content_w = right - left
    padding = int(max(content_h, content_w) * padding_ratio)

    crop_top = max(0, top - padding)
    crop_bottom = min(h, bottom + padding)
    crop_left = max(0, left - padding)
    crop_right = min(w, right + padding)

    # 裁剪
    cropped = img_array[crop_top:crop_bottom, crop_left:crop_right]
    cropped_img = Image.fromarray(cropped)

    # 创建正方形画布并居中
    crop_h, crop_w = cropped.shape[:2]
    max_dim = max(crop_h, crop_w)

    # 创建透明正方形画布
    square_img = Image.new('RGBA', (max_dim, max_dim), (0, 0, 0, 0))

    # 居中粘贴
    paste_x = (max_dim - crop_w) // 2
    paste_y = (max_dim - crop_h) // 2
    square_img.paste(cropped_img, (paste_x, paste_y))

    # 调整到目标尺寸（保持较大尺寸以保证清晰度）
    target_size = 512
    final_img = square_img.resize((target_size, target_size), Image.Resampling.LANCZOS)

    # 保存
    final_img.save(output_path, 'PNG')
    return True


def process_all_icons(input_dir: str, output_dir: str = None):
    """处理目录下所有图标"""
    input_path = Path(input_dir)

    if output_dir is None:
        output_dir = input_dir
    output_path = Path(output_dir)

    # 查找所有ic_开头的png文件
    icon_files = list(input_path.glob('ic_*.png'))

    print(f"找到 {len(icon_files)} 个图标文件")

    success_count = 0
    for icon_file in icon_files:
        output_file = output_path / icon_file.name
        print(f"处理: {icon_file.name}...", end=" ")

        try:
            if remove_background_and_crop(str(icon_file), str(output_file)):
                print("✓")
                success_count += 1
            else:
                print("跳过")
        except Exception as e:
            print(f"失败: {e}")

    print(f"\n处理完成: {success_count}/{len(icon_files)}")


if __name__ == '__main__':
    import sys

    # 默认处理媒体目录
    media_dir = "/Users/zyb/Desktop/Harmony/MythicalBestiary/entry/src/main/resources/base/media"

    if len(sys.argv) > 1:
        media_dir = sys.argv[1]

    # 先备份原始文件
    backup_dir = Path(media_dir).parent / "media_backup"
    if not backup_dir.exists():
        import shutil
        print(f"备份原始图标到: {backup_dir}")
        shutil.copytree(media_dir, backup_dir,
                       ignore=lambda d, files: [f for f in files if not f.startswith('ic_')])

    process_all_icons(media_dir)
