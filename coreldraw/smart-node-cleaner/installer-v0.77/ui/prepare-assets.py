"""Developer-only conversion of owner-supplied artwork; Pillow is not a setup dependency."""
from pathlib import Path
from PIL import Image, ImageOps

root = Path(__file__).parent
# Match the layout aspect ratio; crop, never distort the curves.
ImageOps.fit(Image.open(root / 'welcome-source.png').convert('RGB'), (528, 1240),
             method=Image.Resampling.LANCZOS).save(root / 'welcome.bmp')
ImageOps.fit(Image.open(root / 'header-source.png').convert('RGB'), (1440, 360),
             method=Image.Resampling.LANCZOS).save(root / 'header.bmp')
Image.open(root / 'usta-source.png').convert('RGBA').save(
    root / 'setup.ico', sizes=[(16,16),(24,24),(32,32),(48,48),(64,64),(128,128),(256,256)])
