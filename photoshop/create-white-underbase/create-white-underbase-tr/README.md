# Photoshop'ta Beyaz Alt Baskı (White Underbase) Oluşturma

**Create White Underbase**, Photoshop'ta beyaz alt baskı hazırlamak için kullanılan ücretsiz bir JSX scriptidir.

Koyu, şeffaf, renkli veya metalik yüzeylere baskıda beyaz mürekkep çoğu zaman ayrı bir kanal olarak hazırlanır. Script, bu işlemi hızlandırır: görselden gerçek bir **Spot Color** kanalı oluşturur, kanalı `White` olarak adlandırır ve isteğe bağlı **choke** uygular.

Orijinal görseli değiştirmez.

## Ne yapar?

Script iki kaynak yöntemi sunar:

- **Etkin katmanın saydamlığı** — şeffaf arka planlı PNG/PSD, logo, DTF/DTG veya benzeri çalışmalar için.
- **Beyaz hariç her şey** — beyaz arka planlı düzleştirilmiş görseller için. **Beyaz toleransı** ile beyaza yakın pikseller de arka plan olarak kabul edilebilir.

Sonuç, normal beyaz bir katman değil; Photoshop'ta ayrı bir **White spot kanalıdır**.

## Choke ne işe yarar?

Beyaz alt baskı renkli görselin kenarından dışarı taşarsa baskıda ince bir beyaz çizgi veya halo görünebilir.

**Choke**, beyaz seçimi birkaç piksel içeri daraltır. Varsayılan değer 1 px'tir, ancak doğru değer baskı yöntemi, çözünürlük, malzeme ve RIP ayarlarına göre değişebilir.

## Kullanım alanları

Özellikle şu iş akışlarında kullanışlıdır:

- DTF ve DTG baskı hazırlığı
- UV ve flatbed baskı
- şeffaf veya koyu malzemelere baskı
- pleksi, cam, metal ve renkli yüzeyler
- Photoshop'ta beyaz mürekkep / spot kanal hazırlama
- prepress ve baskı öncesi dosya hazırlığı

Bazı RIP yazılımları beyaz alt baskıyı otomatik oluşturabilir. İş akışınız ayrıca bir White spot kanalı gerektirmiyorsa bu adım gerekli olmayabilir.

## Nasıl kullanılır?

1. Photoshop'ta dosyanızı açın.
2. `Create_White_Underbase.jsx` scriptini çalıştırın.
3. Kaynak yöntemini seçin.
4. Gerekirse **Beyaz toleransı** değerini ayarlayın.
5. **Choke** değerini girin.
6. **Beyaz Kanal Oluştur** düğmesine tıklayın.
7. Oluşturulan `White` kanalını Kanallar panelinde kontrol edin.

Belgede zaten `White` adlı bir kanal varsa script değiştirmeden önce onay ister.

## Kurulum

`Create_White_Underbase.jsx` dosyasını Photoshop'un Scripts klasörüne kopyalayıp Photoshop'u yeniden başlatın.

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

## Önemli not

RIP veya yazıcı yazılımınız `White` yerine farklı bir kanal adı bekleyebilir. Üretimden önce gerekli spot kanal adını kontrol edin.

Yarı saydam kenarlar, gölgeler, gradientler ve çok ince detaylar da baskıdan önce gözle kontrol edilmelidir.

## Güvenlik

Script:

- kaynak görseli yeniden boyutlandırmaz
- katmanları birleştirmez
- belgeyi otomatik kaydetmez
- kaynak dosyanın üzerine yazmaz

## Durum

**İlk herkese açık prototip.**

## İletişim

Sorular, hata bildirimleri veya benzer Photoshop otomasyonları için:

[**usta.scripts@gmail.com**](mailto:usta.scripts@gmail.com)
