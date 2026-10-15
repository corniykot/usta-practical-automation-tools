# Photoshop'ta Tüm Katmanları Tek Tek Yazdırma

`Print_All_Layers.jsx`, Photoshop belgesindeki üst düzey katmanları **tek tek ve otomatik olarak yazdırır**.

Belgenizi hazırlayın, bir test baskısı alın, yazıcı ayarlarını kontrol edin ve scripti çalıştırın. Script her yazdırılabilir katmanı sırayla görünür yapar, Photoshop'un mevcut yazdırma ayarlarıyla bir kopya gönderir ve iş bittiğinde katmanların ilk görünürlük durumunu geri getirir.

Dosya dışa aktarma yok, geçici dosya yok, her katman için tekrar tekrar Print'e basmak yok.

## Ne yapar?

- üst düzey ArtLayer katmanlarını sırayla yazdırır
- Background katmanını atlar
- her katmanı tek başına görünür yapar
- Photoshop'un mevcut yazıcı ayarlarını kullanır
- her katman için `printOneCopy()` çalıştırır
- başarılı batch sonunda katmanların ilk görünürlük durumunu geri yükler

Katman gruplarının içindeki katmanlar işlenmez.

## Nerede kullanışlı?

Özellikle şu iş akışlarında işe yarar:

- fotoğraf ve sanat baskısı
- sublimasyon ve transfer baskı
- sticker, magnet ve küçük seri üretim
- aynı Photoshop belgesinde her katmanın ayrı bir baskı işi olduğu üretim dosyaları
- yerleşim scriptlerinden sonra oluşan sayfa katmanlarını toplu yazdırma

## Nasıl kullanılır?

1. Photoshop belgenizi hazırlayın; her baskı işi ayrı bir üst düzey katmanda olsun.
2. Önce **bir manuel test baskısı** alın.
3. Yazıcı, kâğıt, ölçek, yön ve renk ayarlarını kontrol edin.
4. `Print_All_Layers.jsx` scriptini çalıştırın.
5. Katmanlar sırayla yazdırılır.

Script yazıcı ayarlarını değiştirmez; Photoshop'ta o anda geçerli olan ayarları kullanır.

## Kurulum

`Print_All_Layers.jsx` dosyasını Photoshop'un `Presets/Scripts` klasörüne kopyalayın ve Photoshop'u yeniden başlatın.

Daha sonra:

```text
File → Scripts → Print_All_Layers
```

üzerinden çalıştırabilirsiniz.

Sık kullanıyorsanız klavye kısayolu atamak da mantıklıdır:

```text
Edit → Keyboard Shortcuts → Application Menus → File → Scripts
```

## Not

- Katman adı için özel bir kural gerekmez.
- Yalnızca üst düzey ArtLayer katmanları işlenir.
- Background katmanı yazdırılmaz.
- Yazdırma sırası Photoshop'taki üst düzey katman sırasıdır.
- Üretim batch'inden önce mutlaka bir test baskısı alın.

**Adobe Photoshop CS6 / Windows üzerinde gerçek üretimde test edilmiştir.**

## İletişim

Yazıcının başında katman nöbeti tutmak mesleki kaderiniz değil. Photoshop'ta sizi hâlâ aynı düğmeye tekrar tekrar bastıran başka bir saçmalık varsa anlatın; belki onu da script yaparız: [**usta.scripts@gmail.com**](mailto:usta.scripts@gmail.com)
