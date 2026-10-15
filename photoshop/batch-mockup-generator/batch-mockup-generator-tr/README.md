# Photoshop Toplu Mockup Oluşturucu — Akıllı Nesne Değiştirme ve Toplu Dışa Aktarma

Akıllı Nesneyi her seferinde elle değiştirmek zorunda kalmadan bir tasarım klasöründen çok sayıda Photoshop mockup'ı oluşturun.

**Toplu Mockup Oluşturucu**, açık olan PSD mockup dosyasını kullanır, içindeki Akıllı Nesne katmanlarını bulur, tasarımın yerleştirileceği hedefi seçmenizi sağlar ve PNG, JPEG, TIFF veya PSD dosyalarından oluşan bir klasörü otomatik olarak işler.

**Sığdır** veya **Doldur** seçeneğini belirleyin, çıktı klasörünü seçin ve tamamlanan mockup'ları JPEG ya da PNG olarak dışa aktarın.

Yaygın çalışma akışı:

```text
PSD mockup
    +
tasarım klasörü
    ↓
Akıllı Nesneyi değiştir
tasarımı sığdır / doldur
mockup'ı dışa aktar
tekrarla
    ↓
tamamlanmış mockup klasörü
```

Kısacası: Photoshop'un gayet iyi yapabildiği, ama aksi halde size 200 kez yaptırmak istediği işi otomatikleştirir.

## Ne yapar?

`Batch_Mockup_Generator.jsx`, o anda açık olan Photoshop mockup dosyasıyla çalışır.

Şunları yapabilir:

- etkin PSD içindeki Akıllı Nesne katmanlarını algılar
- katman gruplarının içindeki Akıllı Nesneleri de bulur
- tasarımın hangi Akıllı Nesneye yerleştirileceğini seçmenizi sağlar
- bir tasarım klasörünü toplu olarak işler
- PNG, JPEG, TIFF ve PSD dosyalarını yerleştirir
- her tasarımı **Sığdır** veya **Doldur** yöntemiyle ölçekler
- yerleştirilen tasarımı otomatik olarak ortalar
- tamamlanan her mockup'ı **JPEG veya PNG** olarak dışa aktarır
- dışa aktarılan mockup için kaynak tasarımın dosya adını kullanır
- her tasarım arasında orijinal mockup durumunu geri yükler
- toplu işlem tamamlandığında kaynak PSD'yi değiştirmeden bırakır

## Sığdır ve Doldur arasındaki fark

**Sığdır**, tasarımın oranlarını koruyarak tamamını Akıllı Nesne tuvalinin içine sığdırır. Tasarım ile tuvalin en-boy oranları farklıysa boş alan kalabilir.

**Doldur**, tasarımın oranlarını koruyarak Akıllı Nesne tuvalinin tamamını kaplar. En-boy oranları farklıysa tasarımın bazı bölümleri tuvalin dışına taşabilir.

Görüntü esnetilmez.

## Tipik kullanım alanları

Tekrarlanan Photoshop mockup üretiminde kullanışlıdır:

- **toplu mockup oluşturma**
- **toplu Akıllı Nesne değiştirme**
- ürün mockup'ları
- tişört ve giyim mockup'ları
- poster ve sanat baskısı mockup'ları
- çerçeve ve duvar sanatı mockup'ları
- ambalaj mockup'ları
- ürün önizlemeleri
- Etsy ve diğer pazaryerleri için ürün görselleri
- baskı üzerine üretim (print-on-demand) tasarım önizlemeleri
- sosyal medya ve portföy sunum görselleri
- tek bir PSD şablonundan çok sayıda mockup oluşturma

Çalışma akışınız temelde **Akıllı Nesneyi değiştir → görseli kaydet → Akıllı Nesneyi değiştir → görseli kaydet → tekrarla** şeklindeyse, bu script tam olarak bunun için tasarlanmıştır.

## Nasıl kullanılır?

1. Photoshop'ta PSD mockup dosyasını açın.
2. `Batch_Mockup_Generator.jsx` scriptini çalıştırın.
3. Tasarımların yerleştirileceği Akıllı Nesneyi seçin.
4. Tasarımlarınızın bulunduğu klasörü seçin.
5. **Sığdır** veya **Doldur** seçeneğini belirleyin.
6. Çıktı klasörünü seçin.
7. **JPEG** veya **PNG** formatını seçin.
8. **Oluştur** düğmesine tıklayın.

Script dosyaları tek tek işler ve bir sonraki tasarımı yerleştirmeden önce mockup'ı başlangıç durumuna geri döndürür.

## Desteklenen giriş formatları

Mevcut sürüm şunları kabul eder:

- PNG
- JPG / JPEG
- TIFF
- PSD

## Çıktı

Seçenekler:

- kalite ayarlı **JPEG**
- **PNG**

Çıktı dosyaları, her kaynak tasarımın temel dosya adını kullanır.

Örnek:

```text
design-red.png   → design-red.jpg
design-blue.png  → design-blue.jpg
design-gold.psd  → design-gold.jpg
```

## Kapsam

Bu ilk sürüm, özellikle basit ve yüksek hacimli kullanım senaryosuna odaklanır:

**bir PSD mockup + seçilmiş bir Akıllı Nesne + bir tasarım klasörü.**

Tam kapsamlı bir mockup üretim sistemi olmaya çalışmaz.

Birbiriyle koordineli birden fazla Akıllı Nesne, bağlantılı tasarım setleri, iç içe değiştirme mantığı, CSV tabanlı işler veya birden fazla PSD şablonu kullanan karmaşık yapılar farklı bir çalışma akışı gerektirebilir.

## Güvenlik

Script, her tasarım arasında ve işlem tamamlandığında açık mockup dosyasını Photoshop geçmişindeki başlangıç durumuna geri döndürür.

Kaynak PSD'nin üzerine bilerek yazmaz.

Her toplu Photoshop otomasyonunda olduğu gibi, üretim iş akışında kullanmadan önce kopyalar üzerinde test etmeniz önerilir.

## Durum

**İlk herkese açık prototip — test süreci devam ediyor.**

Temel çalışma akışı uygulanmıştır; ancak farklı Photoshop sürümleri ve alışılmadık Akıllı Nesne yapılarıyla uyumluluğun daha geniş ölçekte test edilmesi gerekir.

## Arama terimleri / çözdüğü problem

Photoshop toplu mockup oluşturucu, Photoshop mockup otomasyonu, Akıllı Nesneleri toplu değiştirme, toplu Smart Object değiştirme, Photoshop mockup otomasyonu, klasörden mockup oluşturma, Photoshop ürün mockup scripti, toplu ürün görselleri, Photoshop JSX mockup otomasyonu.

## İletişim

Photoshop size aynı işi 200 kez yaptırıyorsa bize yazın: [**usta.scripts@gmail.com**](mailto:usta.scripts@gmail.com)
