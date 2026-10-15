# Photoshop 142×202 mm A4 Baskı Yerleşimi

`Place_Rotate_Layout_142x202_safe_v2.jsx`, bir klasördeki görselleri Photoshop'a toplu olarak yerleştirir, yönlerini kontrol eder, tam **142 × 202 mm** boyutuna getirir, baskı için 90° döndürür ve A4 üzerinde **iki sabit konuma** yerleştirir.

Bu ölçü standart A5 değildir. Standart A5 **148 × 210 mm**'dir; bu üretim düzeni bilinçli olarak **142 × 202 mm** kullanır.

## Ne yapar?

- JPG, JPEG, PNG, TIFF, PSD ve BMP dosyalarını işler
- görselleri Smart Object olarak yerleştirir
- yatay kaynakları önce dikey yöne çevirir
- her görseli tam **142 × 202 mm** boyutuna getirir
- ardından 90° döndürerek baskı yerleşimine hazırlar
- A4 sayfada üst ve alt olmak üzere iki sabit konum kullanır
- hatalı bir dosya yerleşim sırasını bozmaz; sonraki geçerli görsel aynı konumu kullanır
- yalnızca hata olursa TXT kayıt dosyası oluşturur

## A4 yerleşimi

Döndürme sonrasında her görsel sayfada **202 × 142 mm** alan kaplar.

Konumlar:

1. Üst: **X 4 mm / Y 4 mm**
2. Alt: **X 4 mm / Y 148 mm**

İki konum arasındaki dikey boşluk **2 mm**'dir.

Ek dosyalar aynı iki konumu yeni katmanlar halinde tekrar kullanır.

## Nasıl kullanılır?

1. Photoshop'ta **210 × 297 mm A4** bir belge açın.
2. **File → Scripts → Browse…** yoluna gidin.
3. `Place_Rotate_Layout_142x202_safe_v2.jsx` dosyasını seçin.
4. Görsellerin bulunduğu klasörü seçin.
5. Script geçerli dosyaları sırayla yerleştirir, yönünü düzeltir, boyutlandırır, döndürür ve konumlandırır.

İsterseniz JSX dosyasını Photoshop'un `Presets/Scripts` klasörüne kopyalayıp Photoshop'u yeniden başlatabilirsiniz.

## Not

Genişlik ve yükseklik ayrı ayrı tam **142 × 202 mm** değerine zorlanır. Kaynak görsel bu orana uygun değilse oranı değişebilir.

Script kırpma veya akıllı yeniden kompozisyon yapmaz.

Hatasız çalışmada TXT log oluşturulmaz. Bir dosya atlanırsa hata kaydı scriptin yanında, mümkün değilse kaynak görsel klasöründe oluşturulur.

## İletişim

Cetvel, hesap makinesi ve sabır üçlüsünden kurtulduk. Photoshop size hâlâ başka bir işi gereksiz yere elle yaptırıyorsa bize anlatın: [**usta.scripts@gmail.com**](mailto:usta.scripts@gmail.com)
