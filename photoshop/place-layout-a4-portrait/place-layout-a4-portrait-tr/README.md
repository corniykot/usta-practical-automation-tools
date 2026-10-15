# Photoshop A4 Dikey Görselleri Otomatik Yerleştirme

Bir klasördeki görselleri Photoshop'a tek tek taşıyıp A4 ölçüsüne getirmek yerine, `Place_Layout_A4_Portrait_safe_v2.jsx` bunu toplu olarak yapar.

Script her desteklenen görseli **Smart Object** olarak yerleştirir, yatay görselleri dikey çevirir, tam **210 × 297 mm** boyutuna getirir ve A4 tuvalinin sol üst köşesine hizalar.

Birden fazla dosya işlendiğinde görseller aynı belgede üst üste ayrı katmanlar olarak kalır.

## Ne yapar?

- klasördeki görselleri toplu olarak yerleştirir
- JPG, JPEG, PNG, TIFF, PSD ve BMP dosyalarını destekler
- yatay görselleri otomatik olarak dikey çevirir
- her görseli tam **210 × 297 mm** yapar
- görselleri X 0 mm / Y 0 mm konumuna hizalar
- dosya adını katman adı olarak kullanır
- bozuk veya açılamayan dosyaları atlayıp işleme devam eder
- yalnızca hata varsa TXT kayıt dosyası oluşturur

## Gereksinimler

- Adobe Photoshop + ExtendScript / JSX desteği
- A4 dikey belge: **210 × 297 mm**
- Photoshop CS6 ile uyumlu çalışma mantığı

## Nasıl kullanılır?

1. Photoshop'ta A4 dikey hedef belgeyi açın.
2. **File → Scripts → Browse…** yoluna gidin.
3. `Place_Layout_A4_Portrait_safe_v2.jsx` dosyasını seçin.
4. Görsellerin bulunduğu klasörü seçin.
5. Script geçerli dosyaları otomatik olarak yerleştirir, yönünü düzeltir, boyutlandırır ve hizalar.

İsterseniz JSX dosyasını Photoshop'un `Presets/Scripts` klasörüne kopyalayıp Photoshop'u yeniden başlatabilirsiniz. Böylece script doğrudan **File → Scripts** menüsünde görünür.

## Not

Genişlik ve yükseklik ayrı ayrı tam **210 × 297 mm** değerine zorlanır. Kaynak görsel A4 oranında değilse oranı değişebilir.

Hatasız çalışmada gereksiz TXT log oluşturulmaz. Bir dosya atlanırsa hata kaydı scriptin yanında, mümkün değilse kaynak görsel klasöründe oluşturulur.

## İletişim

Bir klasördeki A4 görselleri hâlâ tek tek sürükleyip hizalıyorsanız Photoshop sizi fazla uslu bulmuş olabilir: [**usta.scripts@gmail.com**](mailto:usta.scripts@gmail.com)
