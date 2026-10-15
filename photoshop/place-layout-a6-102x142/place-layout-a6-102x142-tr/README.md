# Photoshop 102×142 mm A4 Baskı Yerleşimi — 4 Görsel

`Place_Layout_102x142_safe_v2.jsx`, bir klasördeki görselleri Photoshop'a toplu olarak yerleştirir, yönlerini kontrol eder, her birini tam **102 × 142 mm** boyutuna getirir ve A4 üzerinde sabit **2 × 2** düzene yerleştirir.

Bu ölçü standart A6 değildir. Standart A6 **105 × 148 mm**'dir; bu üretim düzeni bilinçli olarak **102 × 142 mm** kullanır.

## Ne yapar?

- JPG, JPEG, PNG, TIFF, PSD ve BMP dosyalarını işler
- görselleri Smart Object olarak yerleştirir
- yatay kaynakları otomatik olarak dikey yöne çevirir
- her görseli tam **102 × 142 mm** boyutuna getirir
- A4 sayfada dört sabit konum kullanır
- ek dosyalar için aynı 2 × 2 yerleşimi yeni katmanlar halinde tekrarlar
- bozuk veya açılamayan dosyaları atlar ve batch işlemine devam eder
- hatalı dosya bir yerleşim konumunu tüketmez
- yalnızca hata olursa TXT kayıt dosyası oluşturur

## Yerleşim

A4 sayfa üzerinde dört konum kullanılır:

1. **X 2,5 mm / Y 4 mm**
2. **X 105,5 mm / Y 4 mm**
3. **X 2,5 mm / Y 148 mm**
4. **X 105,5 mm / Y 148 mm**

Böylece her A4 üzerinde dört adet **102 × 142 mm** görsel hazırlanır.

## Nasıl kullanılır?

1. Photoshop'ta **210 × 297 mm A4** bir belge açın.
2. **File → Scripts → Browse…** yoluna gidin.
3. `Place_Layout_102x142_safe_v2.jsx` dosyasını seçin.
4. Görsellerin bulunduğu klasörü seçin.
5. Script dosyaları sırayla yerleştirir, yönünü düzeltir, boyutlandırır ve dört sabit konuma dağıtır.

İsterseniz JSX dosyasını Photoshop'un `Presets/Scripts` klasörüne kopyalayıp Photoshop'u yeniden başlatabilirsiniz.

## Not

Genişlik ve yükseklik ayrı ayrı tam **102 × 142 mm** değerine zorlanır. Kaynak görsel bu orana uygun değilse oranı değişebilir.

Script kırpma veya akıllı yeniden kompozisyon yapmaz.

Hatasız çalışmada TXT log oluşturulmaz. Bir dosya atlanırsa hata kaydı scriptin yanında, mümkün değilse kaynak görsel klasöründe oluşturulur.

## İletişim

Bu script dört görseli yerleştiriyor. Photoshop'ta hâlâ aynı ölçüyü, aynı konumu veya aynı tıklamayı tekrar tekrar yapıyorsanız, o işi bize tarif edin — belki sıradaki script odur: [**usta.scripts@gmail.com**](mailto:usta.scripts@gmail.com)
