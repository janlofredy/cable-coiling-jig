#!/usr/bin/env python3
import os
import subprocess
import sys
import shutil
from PIL import Image, ImageDraw, ImageFont

OPENSCAD_BIN = "/Applications/OpenSCAD-2021.01.app/Contents/MacOS/OpenSCAD"
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
SCAD_FILE = os.path.join(BASE_DIR, "animation_combo_scene.scad")
OUTPUT_GIF = os.path.join(BASE_DIR, "cable_combo_usage.gif")
ARTIFACT_DIR = "/Users/janlofredy/.gemini/antigravity/brain/06eb6c0a-8fc8-43f2-a3ac-a411e84c3d97"
FRAME_DIR = "/tmp/combo_anim_frames"

FONT_PATH = "/System/Library/Fonts/Helvetica.ttc"

STEPS = [
    {
        "step_num": 1,
        "title": "Pre-lay Velcro strap & wind cable on posts",
        "tip": "Strap sits flat in the mandrel floor groove beneath coils",
        "t_start": 0.0,
        "t_end": 1.0,
        "frames": 6,
        "hold_last": 1400
    },
    {
        "step_num": 2,
        "title": "Press inverted outer sleeve down over mandrel",
        "tip": "Sleeve seats into registration pocket & aligns 16 mm slots",
        "t_start": 1.0,
        "t_end": 2.0,
        "frames": 7,
        "hold_last": 1400
    },
    {
        "step_num": 3,
        "title": "Cinch Velcro strap through aligned center slots",
        "tip": "Locks compressed bundle tightly inside the closed capsule",
        "t_start": 2.0,
        "t_end": 3.0,
        "frames": 6,
        "hold_last": 1500
    },
    {
        "step_num": 4,
        "title": "Lift sleeve off to release — nest empty to store!",
        "tip": "Empty halves snap together into one compact drawer capsule",
        "t_start": 3.0,
        "t_end": 4.0,
        "frames": 7,
        "hold_last": 2200
    }
]

def load_fonts():
    try:
        font_badge = ImageFont.truetype(FONT_PATH, 16, index=1)
        font_title = ImageFont.truetype(FONT_PATH, 19, index=1)
        font_tip = ImageFont.truetype(FONT_PATH, 13, index=0)
    except Exception:
        font_badge = ImageFont.load_default()
        font_title = ImageFont.load_default()
        font_tip = ImageFont.load_default()
    return font_badge, font_title, font_tip

def add_overlay(image_path, step_info):
    img = Image.open(image_path).convert("RGBA")
    w, h = img.size
    overlay = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    draw = ImageDraw.Draw(overlay)
    font_badge, font_title, font_tip = load_fonts()

    banner_h = 60
    draw.rectangle([(0, 0), (w, banner_h)], fill=(15, 23, 42, 230))
    draw.line([(0, banner_h), (w, banner_h)], fill=(56, 189, 248, 200), width=2)

    badge_text = f"STEP {step_info['step_num']}"
    badge_w, badge_h_val = 68, 26
    badge_x, badge_y = 16, 17
    draw.rounded_rectangle(
        [(badge_x, badge_y), (badge_x + badge_w, badge_y + badge_h_val)],
        radius=6,
        fill=(2, 132, 199, 255)
    )
    draw.text((badge_x + 9, badge_y + 4), badge_text, fill=(255, 255, 255), font=font_badge)
    draw.text((badge_x + badge_w + 12, 19), step_info["title"], fill=(255, 255, 255), font=font_title)

    footer_h = 28
    draw.rectangle([(0, h - footer_h), (w, h)], fill=(15, 23, 42, 210))
    draw.text((16, h - footer_h + 6), f"Tip: {step_info['tip']}", fill=(203, 213, 225), font=font_tip)

    combined = Image.alpha_composite(img, overlay)
    return combined.convert("RGB")

def main():
    if not os.path.exists(OPENSCAD_BIN):
        print(f"Error: OpenSCAD binary not found at {OPENSCAD_BIN}", file=sys.stderr)
        sys.exit(1)

    if os.path.exists(FRAME_DIR):
        shutil.rmtree(FRAME_DIR)
    os.makedirs(FRAME_DIR, exist_ok=True)

    print("=" * 60)
    print("GENERATING 2-IN-1 MATING CAPSULE USAGE ANIMATION (GIF)")
    print("=" * 60)

    frames = []
    durations = []
    frame_idx = 0

    for step in STEPS:
        print(f"\n[+] Rendering Step {step['step_num']}: {step['title']}...")
        n_frames = step["frames"]
        t_vals = [
            step["t_start"] + (step["t_end"] - step["t_start"]) * (i / (n_frames - 1))
            for i in range(n_frames)
        ]

        for i, t in enumerate(t_vals):
            frame_png = os.path.join(FRAME_DIR, f"frame_{frame_idx:04d}.png")
            cmd = [
                OPENSCAD_BIN,
                "-o", frame_png,
                "-D", f"t_val={t:.3f}",
                "--camera=0,0,22,55,0,35,215",
                "--imgsize=640,480",
                "--colorscheme=Tomorrow",
                SCAD_FILE
            ]
            res = subprocess.run(cmd, capture_output=True, text=True)
            if res.returncode != 0:
                print(f"Error rendering frame at t={t}: {res.stderr}", file=sys.stderr)
                sys.exit(1)

            annotated_img = add_overlay(frame_png, step)
            frames.append(annotated_img)

            if i == n_frames - 1:
                durations.append(step["hold_last"])
            else:
                durations.append(120)

            frame_idx += 1
            print(f"    ✔ Frame {frame_idx:02d} rendered (t={t:.2f})")

    print("\n[+] Compiling animated GIF with Pillow...")
    first_frame = frames[0]
    first_frame.save(
        OUTPUT_GIF,
        save_all=True,
        append_images=frames[1:],
        duration=durations,
        loop=0,
        optimize=True
    )

    gif_size = os.path.getsize(OUTPUT_GIF) / 1024
    print(f"✔ Animated GIF successfully created: {OUTPUT_GIF} ({gif_size:.1f} KB)")

    if os.path.exists(ARTIFACT_DIR):
        artifact_gif = os.path.join(ARTIFACT_DIR, "cable_combo_usage.gif")
        shutil.copy2(OUTPUT_GIF, artifact_gif)
        print(f"✔ Copied to artifact directory: {artifact_gif}")

    shutil.rmtree(FRAME_DIR)
    print("=" * 60)
    print("DONE!")
    print("=" * 60)

if __name__ == "__main__":
    main()
