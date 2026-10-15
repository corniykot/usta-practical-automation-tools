# Photoshop'ta Beyaz Alt Baskı ve White Spot Kanalı Oluşturma

Koyu, şeffaf, renkli veya metalik bir yüzeye baskı yaparken renkler soluk, kirli veya yarı saydam mı görünüyor? DTF, DTG veya UV baskı dosyanız için Photoshop'ta ayrı bir **beyaz mürekkep kanalı (White spot channel)** hazırlamanız mı gerekiyor?

**Create White Underbase**, Photoshop'ta beyaz alt baskı hazırlamanın tekrar eden adımlarını otomatikleştiren ücretsiz bir JSX scriptidir.

Script, görselden gerçek bir **Spot Color** kanalı oluşturur, kanalı `White` olarak adlandırır, isteğe bağlı **choke / daraltma** uygular ve orijinal görsel katmanlarını değiştirmeden bırakır.

## Hangi problemi çözer?

Beyaz mürekkep kullanılan baskılarda sorun yalnızca "beyaz renk eklemek" değildir. Beyaz, çoğu üretim akışında renklerin altında çalışan ayrı bir baskı verisidir.

Manuel Photoshop iş akışı genellikle şöyledir:

```text
görsel alanını seç
→ arka planı hariç tut
→ seçimi daralt
→ yeni spot kanal oluştur
→ kanalı doldur
→ kanal adını ayarla
→ sonucu kontrol et
```

Bir iki dosyada kolaydır. Çok sayıda dosyada ise hem zaman kaybına hem de tutarsızlıklara dönüşür.

Yaygın problemler:

- koyu tekstilde renklerin yeterince canlı çıkmaması
- şeffaf pleksi, cam veya film üzerinde CMYK renklerin zemine karışması
- UV baskıda beyaz altlık olmadan renklerin zayıf görünmesi
- DTF / DTG için beyaz kanalın her dosyada elle hazırlanması
- beyaz kanal renk sınırına tam oturmadığında görünen beyaz halo
- her dosyada aynı choke değerini manuel uygulama zorunluluğu
- beyaz arka planlı düzleştirilmiş JPG/TIFF dosyalarında baskı alanını ayırma
- RIP yazılımının beklediği spot kanal yapısının yanlış hazırlanması

## Ne yapar?

`Create_White_Underbase.jsx` iki farklı kaynaktan beyaz alt baskı oluşturabilir.

### 1. Etkin katmanın saydamlığı

**Etkin katmanın saydamlığı** seçeneği, şeffaf arka planı zaten temizlenmiş görseller için kullanılır.

Özellikle:

- DTF / DTG tasarımları
- logolar
- transfer baskı grafikleri
- sticker ve decal dosyaları
- şeffaf PNG / PSD tasarımlar

için uygundur.

Script, etkin katmanın saydamlığını seçim olarak kullanır ve bu alandan `White` spot kanalını oluşturur.

### 2. Beyaz hariç her şey

**Beyaz hariç her şey** seçeneği, beyaz arka plan üzerinde hazırlanmış veya düzleştirilmiş görseller için kullanılır.

Ayarlanabilir **Beyaz toleransı**, saf beyazın yanı sıra beyaza yakın piksellerin de arka plan olarak değerlendirilmesini sağlar.

Bu, özellikle müşteriden gelen JPG/TIFF dosyalarında işe yarayabilir.

## Choke nedir ve neden kullanılır?

Beyaz alt baskı renk katmanının dışına taşarsa baskının kenarında ince beyaz bir çizgi veya **halo** görünebilir.

**Choke**, beyaz alt baskı seçimini renkli görselin içine doğru birkaç piksel daraltır.

Örneğin:

```text
Choke: 1 px
```

beyaz kanalın dış kenarını renkli görselin kenarından 1 piksel içeri çeker.

Doğru choke değeri sabit değildir. Şunlara bağlıdır:

- baskı teknolojisi
- çözünürlük
- yazıcı ve kafa hizalaması
- mürekkep yayılması
- medya / malzeme
- RIP ayarları
- üretim toleransları

Bu nedenle script choke değerini operatöre bırakır.

## Oluşturulan sonuç

Script gerçek bir Photoshop **Spot Color** kanalı oluşturur:

```text
White
```

Bu, beyaz renkle doldurulmuş normal bir Photoshop katmanı değildir.

Script:

- görseli flatten etmez
- katmanları birleştirmez
- resmi yeniden boyutlandırmaz
- yazdırma işlemini başlatmaz
- belgeyi otomatik kaydetmez
- kaynak görselin üzerine yazmaz

İşlem bittikten sonra White kanalı, görsel kanallarıyla birlikte görünür bırakılır; böylece baskıya göndermeden önce ayrımı kontrol edebilirsiniz.

Belgede zaten `White` adlı bir kanal varsa script değiştirmeden önce onay ister.

## DTF baskıda beyaz kanal

DTF üretiminde beyaz mürekkep, renkli baskının koyu tekstil üzerinde opak ve canlı görünmesini sağlayan temel katmandır.

Bazı DTF RIP yazılımları beyaz alt baskıyı PNG saydamlığından otomatik oluşturur. Bazı iş akışları ise önceden hazırlanmış bir spot kanal veya belirli isimde bir beyaz kanal kullanır.

Bu script özellikle **Photoshop içinde manuel White spot kanal hazırlanması gereken DTF iş akışları** için kullanışlıdır.

RIP yazılımınız beyaz kanalı otomatik oluşturuyorsa ayrıca Photoshop'ta spot kanal hazırlamanız gerekmeyebilir.

## UV baskıda beyaz mürekkep

UV baskıda CMYK mürekkepler şeffaf, koyu veya renkli malzemelerde zeminden etkilenebilir.

Beyaz alt baskı özellikle şu yüzeylerde önemlidir:

- şeffaf pleksi
- cam
- koyu MDF
- ahşap
- renkli plastik
- metal
- alüminyum
- renkli veya şeffaf levhalar

Ayrı bir beyaz kanal, renklerin altına opak bir zemin sağlayarak baskının daha doğru ve güçlü görünmesine yardımcı olur.

## Spot kanal neden önemli?

Photoshop'ta spot renkler normal RGB veya CMYK renklerinden farklı olarak ayrı kanallarda tutulabilir.

Üretim yazılımı veya RIP, bu kanalı ayrı bir mürekkep verisi olarak okuyabilir.

Ancak **kanal adı üretim sistemine göre değişebilir**.

Bu script varsayılan olarak:

```text
White
```

adını kullanır.

RIP'iniz `Spot_1`, `SpotWhite`, `WHITE` veya başka bir özel ad bekliyorsa üretimden önce gerekli kanal adını kontrol edin.

## Photoshop'ta beyaz alt baskı nasıl oluşturulur?

1. Photoshop'ta baskı dosyanızı açın.
2. `Create_White_Underbase.jsx` scriptini çalıştırın.
3. Kaynak yöntemini seçin:
   - **Etkin katmanın saydamlığı**
   - **Beyaz hariç her şey**
4. Gerekirse **Beyaz toleransı** değerini ayarlayın.
5. Kullanmak istediğiniz **Choke / daraltma** değerini piksel olarak girin.
6. **Beyaz Kanal Oluştur** düğmesine tıklayın.
7. Oluşturulan `White` spot kanalını Channels / Kanallar panelinde kontrol edin.
8. Dosyayı RIP veya baskı iş akışınızın gerektirdiği format ve kanal adıyla hazırlayın.

## Kullanım alanları

Bu Photoshop beyaz kanal scripti özellikle şunlar için kullanışlıdır:

- DTF baskı dosyası hazırlama
- DTG baskı hazırlığı
- UV baskı beyaz kanal hazırlama
- flatbed UV baskı
- beyaz mürekkep baskısı
- koyu yüzeye baskı
- şeffaf malzemeye baskı
- pleksi ve cam baskı
- spot white separation
- beyaz alt baskı / underbase hazırlama
- prepress ve baskı öncesi dosya hazırlama
- Photoshop spot kanal otomasyonu

## Kurulum

`Create_White_Underbase.jsx` dosyasını Photoshop'un Scripts klasörüne kopyalayın ve Photoshop'u yeniden başlatın.

Daha sonra:

```text
File → Scripts → Create_White_Underbase
```

üzerinden çalıştırabilirsiniz.

Alternatif olarak:

```text
File → Scripts → Browse...
```

ile script dosyasını doğrudan seçebilirsiniz.

## Üretim öncesi kontrol

Otomatik oluşturulan beyaz kanal mutlaka baskıdan önce kontrol edilmelidir.

Özellikle:

- yarı saydam kenarlar
- gölgeler
- gradientler
- çok ince detaylar
- küçük yazılar
- açık tonlar
- kasıtlı olarak beyaz basılmaması gereken alanlar

manuel prepress kontrolü gerektirebilir.

Script tekrar eden işi hızlandırır; operatör kontrolünün yerini almaz.

## Sık sorulan sorular

### Photoshop'ta White spot channel nasıl oluşturulur?

Bu script, etkin katmanın saydamlığından veya beyaz hariç görsel alanlardan seçim oluşturur ve bunu `White` adlı gerçek bir Spot Color kanalına dönüştürür.

### DTF için Photoshop'ta beyaz kanal şart mı?

Her zaman değil. Birçok RIP beyaz alt baskıyı otomatik oluşturabilir. Ancak iş akışınız ayrı bir spot white kanal bekliyorsa Photoshop'ta hazırlanması gerekebilir.

### UV baskı için beyaz kanal neden gerekli?

Şeffaf veya koyu malzemelerde CMYK mürekkep zeminden etkilenebilir. Beyaz alt baskı renklerin altında opak bir zemin oluşturur.

### Beyaz halo neden oluşur?

Beyaz alt baskı renkli görselin kenarından dışarı taşarsa kayıt toleransı veya mürekkep davranışı nedeniyle beyaz çizgi görünebilir. Choke, beyaz seçimi içeri daraltarak bu riski azaltmaya yardımcı olur.

### Kanal neden White olarak adlandırılıyor?

`White` yaygın ve anlaşılır bir varsayılandır. Ancak RIP ve yazıcı üreticileri farklı kanal adları isteyebilir. Üretim sisteminizin gereksinimini kontrol edin.

### Script normal beyaz katman mı oluşturuyor?

Hayır. Gerçek bir Photoshop **Spot Color channel** oluşturur.

## Durum

**İlk herkese açık prototip.**

Amaç, Photoshop'ta tekrar tekrar yapılan beyaz alt baskı / spot white ayırma işlemini hızlandırırken üretim kontrolünü operatörde bırakmaktır.

## İlgili aramalar ve anahtar kelimeler

- Photoshop beyaz alt baskı
- Photoshop beyaz kanal oluşturma
- Photoshop White spot channel
- Photoshop spot renk kanalı
- beyaz mürekkep kanalı
- white underbase Photoshop
- DTF beyaz kanal
- DTF white underbase
- DTF baskı dosyası hazırlama
- DTF spot white
- DTG beyaz alt baskı
- UV baskı beyaz kanal
- UV baskı beyaz mürekkep
- UV baskı dosyası hazırlama
- spot white separation
- beyaz altlık baskı
- choke Photoshop
- baskıda beyaz halo
- Photoshop prepress script
- Photoshop JSX baskı otomasyonu

## Dosya

`Create_White_Underbase.jsx`

## İletişim

Sorular, hata bildirimleri veya tekrar eden Photoshop işlerini otomatikleştirme fikirleri:

[**usta.scripts@gmail.com**](mailto:usta.scripts@gmail.com)
