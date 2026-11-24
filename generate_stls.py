#!/usr/bin/env python3
import subprocess
import os
import shutil
import sys

OPENSCAD_BIN = "/Applications/OpenSCAD-2021.01.app/Contents/MacOS/OpenSCAD"
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
SCAD_FILE = os.path.join(BASE_DIR, "cable_jig.scad")
ARTIFACT_DIR = "/Users/janlofredy/.gemini/antigravity/brain/06eb6c0a-8fc8-43f2-a3ac-a411e84c3d97"

MODELS = [
    {
        "name": "cable_jig_small",
        "preset": "S",
        "shape": "oblong",
        "desc": "Small Oblong (USB-C, Lightning, Earbuds)",
        "cam": "0,0,20,55,0,35,170"
    },
    {
        "name": "cable_jig_medium",
        "preset": "M",
        "shape": "oblong",
        "desc": "Medium Oblong (Laptop Chargers, HDMI, Audio)",
        "cam": "0,0,25,55,0,35,220"
    },
    {
        "name": "cable_jig_large",
        "preset": "L",
        "shape": "oblong",
        "desc": "Large Oblong (Heavy AC Cords, Extension Leads)",
        "cam": "0,0,30,55,0,35,280"
    },
    {
        "name": "cable_jig_circular_small",
        "preset": "S",
        "shape": "circular",
        "desc": "Small Circular (Round Donut Coils)",
        "cam": "0,0,20,55,0,35,140"
    },
    {
        "name": "cable_mandrel_oblong_small",
        "scad": "cable_mandrel_jig.scad",
        "preset": "S",
        "shape": "oblong",
        "desc": "External Oblong Mandrel - Small",
        "cam": "0,0,18,55,0,35,185"
    },
    {
        "name": "cable_mandrel_oblong_medium",
        "scad": "cable_mandrel_jig.scad",
        "preset": "M",
        "shape": "oblong",
        "desc": "External Oblong Mandrel - Medium",
        "cam": "0,0,24,55,0,35,245"
    },
    {
        "name": "cable_mandrel_oblong_large",
        "scad": "cable_mandrel_jig.scad",
        "preset": "L",
        "shape": "oblong",
        "desc": "External Oblong Mandrel - Large",
        "cam": "0,0,28,55,0,35,310"
    },
    {
        "name": "cable_mandrel_tube_small",
        "scad": "cable_mandrel_jig.scad",
        "preset": "S",
        "shape": "circular",
        "desc": "External Flanged Tube - Small",
        "cam": "0,0,18,55,0,35,160"
    },
    {
        "name": "cable_mandrel_tube_medium",
        "scad": "cable_mandrel_jig.scad",
        "preset": "M",
        "shape": "circular",
        "desc": "External Flanged Tube - Medium",
        "cam": "0,0,24,55,0,35,215"
    },
    {
        "name": "cable_mandrel_tube_large",
        "scad": "cable_mandrel_jig.scad",
        "preset": "L",
        "shape": "circular",
        "desc": "External Flanged Tube - Large",
        "cam": "0,0,28,55,0,35,275"
    }
]

def main():
    if not os.path.exists(OPENSCAD_BIN):
        print(f"Error: OpenSCAD not found at {OPENSCAD_BIN}", file=sys.stderr)
        sys.exit(1)

    print("=" * 65)
    print("PARAMETRIC CABLE COILING JIG - BUILD & EXPORT PIPELINE")
    print("=" * 65)

    for item in MODELS:
        scad_path = os.path.join(BASE_DIR, item.get("scad", "cable_jig.scad"))
        stl_path = os.path.join(BASE_DIR, f"{item['name']}.stl")
        png_path = os.path.join(BASE_DIR, f"{item['name']}.png")

        print(f"\n[+] Building {item['desc']}...")

        # 1. Export STL
        cmd_stl = [
            OPENSCAD_BIN,
            "-o", stl_path,
            "-D", f'preset="{item["preset"]}"',
            "-D", f'shape_type="{item["shape"]}"',
            scad_path
        ]
        res_stl = subprocess.run(cmd_stl, capture_output=True, text=True)
        if res_stl.returncode != 0:
            print(f"Error compiling STL: {res_stl.stderr}", file=sys.stderr)
            sys.exit(1)
        stl_size = os.path.getsize(stl_path) / 1024
        print(f"    ✔ Exported STL: {os.path.basename(stl_path)} ({stl_size:.1f} KB)")

        # 2. Render 3D Preview PNG
        cmd_png = [
            OPENSCAD_BIN,
            "-o", png_path,
            "-D", f'preset="{item["preset"]}"',
            "-D", f'shape_type="{item["shape"]}"',
            f"--camera={item['cam']}",
            "--imgsize=1024,768",
            "--colorscheme=Tomorrow",
            scad_path
        ]
        res_png = subprocess.run(cmd_png, capture_output=True, text=True)
        if res_png.returncode != 0:
            print(f"Warning: Failed to render PNG: {res_png.stderr}", file=sys.stderr)
        else:
            png_size = os.path.getsize(png_path) / 1024
            print(f"    ✔ Rendered 3D Preview: {os.path.basename(png_path)} ({png_size:.1f} KB)")

            # Copy to artifact dir for markdown embedding
            if os.path.exists(ARTIFACT_DIR):
                dest_png = os.path.join(ARTIFACT_DIR, f"{item['name']}.png")
                shutil.copy2(png_path, dest_png)
                print(f"    ✔ Copied to artifact directory: {dest_png}")

    print("\n" + "=" * 65)
    print("ALL MODELS SUCCESSFULLY GENERATED!")
    print("=" * 65)

if __name__ == "__main__":
    main()
