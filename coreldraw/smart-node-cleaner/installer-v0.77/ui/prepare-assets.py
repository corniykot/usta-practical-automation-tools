"""Developer-only conversion of owner-supplied artwork; Pillow is not a setup dependency."""
from pathlib import Path
from PIL import Image, ImageOps

root = Path(__file__).parent
# Match the layout aspect ratio; crop, never distort the curves.
ImageOps.fit(Image.open(root / 'welcome-source.jpg').convert('RGB'), (528, 1240),
             method=Image.Resampling.LANCZOS).save(root / 'welcome.png', optimize=True)
ImageOps.fit(Image.open(root / 'header-source.jpg').convert('RGB'), (1440, 360),
             method=Image.Resampling.LANCZOS).save(root / 'header.png', optimize=True)
# A single-line header: retain pixel scale and crop the two-line text band.
Image.open(root / 'header.png').crop((0,64,1440,224)).save(
    root / 'header-compact.png', optimize=True)
Image.open(root / 'usta-icon-source.png').convert('RGBA').save(
    root / 'setup.ico', sizes=[(16,16),(24,24),(32,32),(48,48),(64,64),(128,128),(256,256)])
