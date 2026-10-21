"""Developer-only conversion of owner-supplied artwork; Pillow is not a setup dependency."""
from pathlib import Path
from PIL import Image, ImageOps

root = Path(__file__).parent
# Match the layout aspect ratio; crop, never distort the curves.
ImageOps.fit(Image.open(root / 'welcome-source.jpg').convert('RGB'), (528, 1240),
             method=Image.Resampling.LANCZOS).save(root / 'welcome.png', optimize=True)
ImageOps.fit(Image.open(root / 'header-source.jpg').convert('RGB'), (1440, 360),
             method=Image.Resampling.LANCZOS).save(root / 'header.png', optimize=True)
# header-singleline.png is the edited left text-band variant. Its full canvas
# remains 1440 x 360; do not regenerate it by cropping the complete banner.
Image.open(root / 'usta-icon-source.png').convert('RGBA').save(
    root / 'setup.ico', sizes=[(16,16),(24,24),(32,32),(48,48),(64,64),(128,128),(256,256)])
