# Photoshop'ta Toplu Mockup Oluşturma — Smart Object (Akıllı Nesne) Otomasyonu

Bir klasörde onlarca ya da yüzlerce tasarım var ve her biri için aynı PSD mockup dosyasında **Smart Object'i (Akıllı Nesneyi) değiştirip yeniden kaydetmeniz** mi gerekiyor?

**Batch Mockup Generator**, bu tekrar eden işi otomatikleştirir.

Açık olan Photoshop PSD mockup'ındaki Akıllı Nesne katmanlarını bulur, seçtiğiniz Smart Object'e bir klasördeki PNG, JPEG, TIFF veya PSD tasarımlarını sırayla yerleştirir, görseli otomatik olarak sığdırır veya doldurur ve her sonucu **JPEG ya da PNG** olarak dışa aktarır.

Tek tek:

**Smart Object'i aç → tasarımı yerleştir → ölçekle → ortala → kaydet → kapat → mockup'ı dışa aktar → tekrar et**

yerine, tüm klasörü tek işlemde çalıştırabilirsiniz.

## Hangi problemi çözer?

Photoshop'ta mockup hazırlamanın zor kısmı genellikle tek bir tasarımı yerleştirmek değildir. Aynı işlemi 20, 50, 100 veya daha fazla dosya için tekrar etmektir.

Özellikle şu durumlarda zaman kaybı hızla büyür:

- her tasarım için Smart Object'i tek tek açmak
- tasarımı tekrar tekrar ölçeklemek ve ortalamak
- her mockup'ı ayrı ayrı JPEG veya PNG olarak kaydetmek
- çıktı dosyalarına kaynak tasarımla eşleşen adlar vermek
- Etsy, print-on-demand veya e-ticaret için çok sayıda ürün görseli hazırlamak
- aynı PSD mockup şablonuyla büyük bir tasarım koleksiyonu çalışmak
- manuel işlemler yüzünden farklı tasarımlarda farklı yerleşim sonuçları almak

Bu script, özellikle **Photoshop toplu mockup oluşturma**, **Smart Object toplu değiştirme** ve **PSD mockup otomasyonu** için hazırlanmıştır.

## Nasıl çalışır?

```text
PSD mockup
    +
tasarım klasörü
    ↓
Smart Object seç
    ↓
PNG / JPEG / TIFF / PSD dosyalarını sırayla yerleştir
    ↓
Sığdır veya Doldur
    ↓
otomatik ortala
    ↓
JPEG veya PNG dışa aktar
    ↓
sonraki tasarıma geç
```

Kaynak tasarım dosyalarının adları çıktı dosyalarında korunur.

Örneğin:

```text
poster-red.png   → poster-red.jpg
poster-blue.png  → poster-blue.jpg
poster-gold.psd  → poster-gold.jpg
```

## Özellikler

`Batch_Mockup_Generator.jsx`:

- açık PSD içindeki **Smart Object / Akıllı Nesne** katmanlarını algılar
- katman gruplarının içindeki Akıllı Nesneleri de bulur
- hangi Smart Object'in değiştirileceğini seçmenizi sağlar
- bir klasördeki tasarımları toplu olarak işler
- PNG, JPG / JPEG, TIFF ve PSD dosyalarını destekler
- tasarımı **Sığdır (Fit)** veya **Doldur (Fill)** yöntemiyle ölçekler
- yerleştirilen tasarımı otomatik olarak ortalar
- sonuçları JPEG veya PNG olarak dışa aktarır
- JPEG kalite değerini seçmenizi sağlar
- çıktı dosyasında kaynak tasarımın dosya adını kullanır
- her tasarım arasında mockup'ı başlangıç durumuna geri getirir
- toplu işlem bittiğinde açık mockup'ı başlangıç durumuna döndürür

## Sığdır (Fit) ve Doldur (Fill) arasındaki fark

### Sığdır

**Sığdır**, tasarımın tamamını Akıllı Nesne tuvalinin içine yerleştirir ve en-boy oranını korur.

Tasarım ile mockup alanının oranları farklıysa kenarlarda boş alan kalabilir.

### Doldur

**Doldur**, Akıllı Nesne tuvalinin tamamını kaplayacak şekilde tasarımı büyütür ve en-boy oranını korur.

Oranlar farklıysa tasarımın bazı bölümleri tuvalin dışına taşabilir.

Her iki yöntemde de görüntü esnetilmez.

## Kimler için kullanışlı?

Bu Photoshop otomasyon scripti özellikle şu iş akışlarında kullanışlıdır:

- Etsy satıcıları
- print-on-demand (POD) tasarımcıları
- e-ticaret ürün görselleri hazırlayanlar
- poster ve art print satanlar
- çerçeve ve wall art mockup hazırlayanlar
- tişört ve giyim mockup üretimi yapanlar
- ambalaj ve ürün sunumu hazırlayan tasarımcılar
- büyük tasarım koleksiyonlarını tek PSD şablonunda göstermek isteyenler
- sosyal medya ve portföy için seri ürün görselleri hazırlayanlar
- aynı mockup üzerinde sürekli Smart Object değiştiren Photoshop kullanıcıları

## Photoshop'ta toplu mockup nasıl oluşturulur?

1. Photoshop'ta kullanacağınız PSD mockup dosyasını açın.
2. `Batch_Mockup_Generator.jsx` scriptini çalıştırın.
3. Tasarımların yerleştirileceği **Smart Object / Akıllı Nesne** katmanını seçin.
4. Tasarımlarınızın bulunduğu klasörü seçin.
5. **Sığdır** veya **Doldur** seçeneğini belirleyin.
6. Çıktı klasörünü seçin.
7. **JPEG** veya **PNG** formatını seçin.
8. JPEG kullanıyorsanız kalite değerini belirleyin.
9. **Oluştur** düğmesine tıklayın.

Script, klasördeki desteklenen dosyaları sırayla işler ve her tasarım için ayrı bir mockup çıktısı oluşturur.

## Desteklenen giriş formatları

- PNG
- JPG / JPEG
- TIFF
- PSD

## Çıktı formatları

- JPEG
- PNG

JPEG için kalite değeri `0–12` arasında ayarlanabilir.

## Sık sorulan sorular

### Photoshop'ta Smart Object'leri toplu olarak değiştirebilir miyim?

Evet. Bu script, seçtiğiniz bir Smart Object'e klasördeki tasarımları sırayla yerleştirerek manuel değiştirme işlemini otomatikleştirir.

### Bir klasördeki tüm tasarımlardan otomatik mockup oluşturabilir miyim?

Evet. Desteklenen PNG, JPEG, TIFF ve PSD dosyaları klasörden okunur ve her biri için ayrı bir mockup çıktısı oluşturulur.

### Etsy için toplu ürün görseli hazırlamakta kullanılabilir mi?

Evet. Aynı PSD mockup şablonunda çok sayıda poster, baskı, tasarım veya ürün görseli üretmeniz gerekiyorsa bu iş akışına uygundur.

### Print-on-demand (POD) mockup üretiminde kullanılabilir mi?

Evet. Tek bir mockup şablonuna çok sayıda tasarım uygulanan POD iş akışlarında tekrar eden Smart Object değiştirme ve dışa aktarma adımlarını azaltır.

### Kaynak PSD mockup dosyasının üzerine yazar mı?

Script, her tasarım arasında ve işlem sonunda açık mockup'ı başlangıç Photoshop geçmişi durumuna geri döndürmeye çalışır ve kaynak PSD'nin üzerine bilerek yazmaz.

Yine de her Photoshop batch otomasyonunda olduğu gibi, üretim dosyalarında kullanmadan önce bir kopya üzerinde test edilmesi önerilir.

### Aynı anda birden fazla Smart Object'i değiştirebilir mi?

Bu sürümün çalışma modeli:

**bir PSD mockup + seçilmiş bir Smart Object + bir tasarım klasörü**

şeklindedir.

Birbiriyle bağlantılı birden fazla Smart Object, CSV tabanlı veri, çoklu PSD şablonları veya daha karmaşık mockup sistemleri bu sürümün kapsamı dışındadır.

### Tasarımlar bozulur veya esner mi?

Hayır. Sığdır ve Doldur işlemleri tasarımın en-boy oranını korur.

## Neden manuel Smart Object değiştirmek yerine batch script?

Tek bir mockup için manuel yöntem gayet yeterlidir.

Ama aynı PSD üzerinde onlarca veya yüzlerce tasarım olduğunda şu döngü tekrar edilir:

```text
Smart Object'i aç
→ tasarımı ekle
→ ölçekle
→ ortala
→ kaydet
→ kapat
→ ana mockup'ı dışa aktar
→ yeni tasarımla tekrar başla
```

Batch Mockup Generator'ın amacı tam olarak bu tekrar eden üretim işini azaltmaktır.

## Kapsam

Bu sürüm bilinçli olarak basit ve sık görülen yüksek hacimli senaryoya odaklanır:

**tek PSD mockup + tek seçilmiş Smart Object + bir tasarım klasörü.**

Tam kapsamlı bir mockup yönetim sistemi değildir.

Karmaşık şablonlarda birden fazla koordineli Smart Object, bağlantılı tasarım setleri, nested Smart Object mantığı, CSV-driven işler veya birden fazla PSD şablonu için farklı bir otomasyon yapısı gerekebilir.

## Güvenlik

Script:

- kaynak tasarım dosyalarını değiştirmez
- kaynak tasarımları yeniden adlandırmaz
- işlem sırasında mockup'ı her tasarım için başlangıç durumuna döndürür
- işlem sonunda açık mockup'ı başlangıç durumuna geri getirmeye çalışır
- kaynak PSD'nin üzerine bilerek yazmaz

Üretim iş akışına almadan önce test dosyalarıyla çalıştırılması önerilir.

## Durum

**İlk herkese açık prototip — test süreci devam ediyor.**

Temel çalışma akışı uygulanmıştır. Farklı Photoshop sürümleri, farklı PSD mockup yapıları ve alışılmadık Smart Object düzenleriyle daha geniş uyumluluk testleri devam etmektedir.

## İlgili aramalar ve anahtar kelimeler

Bu araç aşağıdaki aramalarla aynı probleme yöneliktir:

- Photoshop toplu mockup oluşturma
- Photoshop mockup otomasyonu
- Photoshop batch mockup generator
- Smart Object toplu değiştirme
- Akıllı Nesne toplu değiştirme
- Photoshop Smart Object otomasyonu
- bulk Smart Object replacement
- PSD mockup otomasyonu
- klasörden otomatik mockup oluşturma
- toplu ürün görseli hazırlama
- Etsy mockup otomasyonu
- Etsy ürün görsellerini toplu hazırlama
- print-on-demand mockup otomasyonu
- POD mockup generator
- Photoshop JSX script
- Photoshop batch processing
- poster mockup otomasyonu
- ürün mockup otomasyonu

## Dosya

`Batch_Mockup_Generator.jsx`

## İletişim

Photoshop size aynı işi 200 kez yaptırıyorsa bize yazın:

[**usta.scripts@gmail.com**](mailto:usta.scripts@gmail.com)
