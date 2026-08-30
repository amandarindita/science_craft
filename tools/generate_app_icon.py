import math
from PIL import Image, ImageDraw, ImageFilter

def create_science_craft_app_icon():
    # Supersampling 2x (2048x2048) for ultra crisp anti-aliasing
    size = 2048
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # Colors
    c_dark_navy = (30, 58, 138, 255)   # #1E3A8A
    c_primary_blue = (37, 99, 235, 255) # #2563EB
    c_sky_blue = (56, 189, 248, 255)    # #38BDF8
    c_cyan_glow = (56, 189, 248, 180)
    c_white = (255, 255, 255, 255)

    # 1. Base Gradient Background (Rounded Squircle)
    margin = 80
    bg_img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    bg_draw = ImageDraw.Draw(bg_img)
    
    # Draw linear gradient on base squircle
    for y in range(margin, size - margin):
        factor = (y - margin) / (size - 2 * margin)
        r = int(c_dark_navy[0] * (1 - factor) + c_primary_blue[0] * factor)
        g = int(c_dark_navy[1] * (1 - factor) + c_primary_blue[1] * factor)
        b = int(c_dark_navy[2] * (1 - factor) + c_primary_blue[2] * factor)
        bg_draw.line([(margin, y), (size - margin, y)], fill=(r, g, b, 255), width=1)

    # Mask with rounded rectangle
    mask = Image.new('L', (size, size), 0)
    mask_draw = ImageDraw.Draw(mask)
    radius = 420
    mask_draw.rounded_rectangle([margin, margin, size - margin, size - margin], radius=radius, fill=255)
    
    img.paste(bg_img, (0, 0), mask)

    # 2. Glowing Ambient Ring (Cyan Glow)
    glow_img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    glow_draw = ImageDraw.Draw(glow_img)
    center = (size // 2, size // 2)
    outer_radius = 640
    
    # Cyan outer ring
    glow_draw.ellipse([
        center[0] - outer_radius, center[1] - outer_radius,
        center[0] + outer_radius, center[1] + outer_radius
    ], outline=c_cyan_glow, width=32)
    glow_img = glow_img.filter(ImageFilter.GaussianBlur(radius=28))
    img.alpha_composite(glow_img)

    # 3. Inner White Glassmorphic Circle
    inner_circle = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    ic_draw = ImageDraw.Draw(inner_circle)
    inner_radius = 560
    
    # Soft translucent white background for the emblem
    ic_draw.ellipse([
        center[0] - inner_radius, center[1] - inner_radius,
        center[0] + inner_radius, center[1] + inner_radius
    ], fill=(255, 255, 255, 245), outline=(147, 197, 253, 255), width=24)
    img.alpha_composite(inner_circle)

    # 4. Atomic Orbital Rings (Rotated Ellipses)
    atom_img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    atom_draw = ImageDraw.Draw(atom_img)
    
    angles = [-35, 35]
    for angle in angles:
        orbit_img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
        orbit_draw = ImageDraw.Draw(orbit_img)
        rx, ry = 420, 160
        orbit_draw.ellipse([
            center[0] - rx, center[1] - ry,
            center[0] + rx, center[1] + ry
        ], outline=(56, 189, 248, 190), width=16)
        
        # Electron particles
        orbit_draw.ellipse([
            center[0] + rx - 24, center[1] - 24,
            center[0] + rx + 24, center[1] + 24
        ], fill=(37, 99, 235, 255), outline=c_white, width=6)
        
        # Rotate
        rotated_orbit = orbit_img.rotate(angle, center=center, resample=Image.BICUBIC)
        atom_img.alpha_composite(rotated_orbit)

    img.alpha_composite(atom_img)

    # 5. Science Beaker Flask Emblem
    flask_img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    flask_draw = ImageDraw.Draw(flask_img)

    # Flask geometry
    cx, cy = size // 2, size // 2 + 30
    neck_w = 70
    neck_top = cy - 260
    neck_bot = cy - 80
    body_w = 260
    body_bot = cy + 220
    lip_w = 100

    # Draw Flask Body Gradient/Fill (Liquid)
    liquid_poly = [
        (cx - 160, cy + 40),
        (cx + 160, cy + 40),
        (cx + body_w, body_bot),
        (cx - body_w, body_bot),
    ]
    flask_draw.polygon(liquid_poly, fill=(37, 99, 235, 240))

    # Bubbles inside flask
    bubbles = [
        (cx - 60, cy + 120, 24),
        (cx + 40, cy + 90, 32),
        (cx + 90, cy + 150, 18),
        (cx - 20, cy + 160, 22),
    ]
    for bx, by, br in bubbles:
        flask_draw.ellipse([bx - br, by - br, bx + br, by + br], fill=(255, 255, 255, 200), outline=(56, 189, 248, 255), width=4)

    # Flask Outline & Neck
    # Lip at top
    flask_draw.rounded_rectangle([cx - lip_w, neck_top - 20, cx + lip_w, neck_top + 10], radius=10, fill=(30, 58, 138, 255))
    
    # Neck & Body Path Outline
    outline_poly = [
        (cx - neck_w, neck_top),
        (cx + neck_w, neck_top),
        (cx + neck_w, neck_bot),
        (cx + body_w, body_bot),
        (cx - body_w, body_bot),
        (cx - neck_w, neck_bot),
    ]
    
    # Draw thicker primary outline for the beaker
    flask_draw.line([(cx - neck_w, neck_top), (cx - neck_w, neck_bot), (cx - body_w, body_bot), (cx + body_w, body_bot), (cx + neck_w, neck_bot), (cx + neck_w, neck_top)], fill=(30, 58, 138, 255), width=32, joint='curve')
    
    # Meniscus / Liquid line
    flask_draw.line([(cx - 160, cy + 40), (cx + 160, cy + 40)], fill=(56, 189, 248, 255), width=12)

    # 6. Sparkle Stars
    def draw_star(sx, sy, rad):
        star_poly = [
            (sx, sy - rad),
            (sx + rad * 0.28, sy - rad * 0.28),
            (sx + rad, sy),
            (sx + rad * 0.28, sy + rad * 0.28),
            (sx, sy + rad),
            (sx - rad * 0.28, sy + rad * 0.28),
            (sx - rad, sy),
            (sx - rad * 0.28, sy - rad * 0.28),
        ]
        flask_draw.polygon(star_poly, fill=(253, 224, 71, 255))

    draw_star(cx + 280, cy - 220, 60)
    draw_star(cx - 280, cy - 140, 44)
    draw_star(cx + 240, cy + 180, 36)

    img.alpha_composite(flask_img)

    # 7. Downsample to 1024x1024 and 512x512
    icon_1024 = img.resize((1024, 1024), Image.Resampling.LANCZOS)
    icon_512 = img.resize((512, 512), Image.Resampling.LANCZOS)

    icon_1024.save('d:/Antigravity/science_craft/assets/app_icon.png')
    icon_512.save('d:/Antigravity/science_craft/assets/logo_app.png')
    print("App icon generated successfully at assets/app_icon.png and assets/logo_app.png!")

if __name__ == '__main__':
    create_science_craft_app_icon()
