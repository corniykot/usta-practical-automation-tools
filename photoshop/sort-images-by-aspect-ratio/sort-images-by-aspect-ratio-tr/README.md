# Görselleri En-Boy Oranına Göre Ayırma — A4, Kare, Diğer

Yüzlerce görseli tek tek açıp oranına bakmak yerine, bu hafif **PowerShell scripti** klasörü tek seferde tarar ve görselleri en-boy oranına göre ayırır.

Kurulum yok. Ek program yok. Tek bir `.ps1` dosyasını çalışma klasörüne koyun, çalıştırın ve üç grup alın:

- `A4` — A4 veya A4'e yakın oranlar
- `Square` — kare görseller
- `Other` — diğer oranlar

Desteklenen formatlar: **JPG, JPEG, PNG, BMP, GIF, TIF, TIFF**.

Orijinal dosyalar **taşınmaz, yeniden adlandırılmaz, değiştirilmez veya silinmez**.

## Neden var?

Üretim klasörlerinde yüzlerce görsel; dikey, kare, 2:3, 3:4, panorama ve başka oranlarda birbirine karışabiliyor.

Baskı yerleşimine geçmeden önce bunları elle kontrol etmek yerine, ilk ayrımı tek seferde otomatik yapmak çok daha hızlıdır.

## Kurulum gerektirmez

Bu, **tek dosyalık ve hafif bir PowerShell aracıdır**.

- sıralama için Photoshop gerekmez
- üçüncü taraf görsel düzenleyici veya katalog programı gerekmez
- installer yok
- kalıcı kurulum yok
- klasörde bir kez çalıştırıp işiniz bitince scripti silebilirsiniz

Windows PowerShell ve `System.Drawing` kullanır.

## Photoshop yerleşim scriptlerinden önce

Bu araç, repodaki Photoshop baskı yerleşim scriptleri için **ön hazırlık adımıdır**.

Önce görselleri oranlarına göre ayırın; ardından uygun üretim yerleşimine geçin:

- [A4 dikey — 210 × 297 mm](../../place-layout-a4-portrait/place-layout-a4-portrait-tr/)
- [142 × 202 mm — A4 üzerinde 2 görsel](../../place-layout-a5-142x202/place-layout-a5-142x202-tr/)
- [102 × 142 mm — A4 üzerinde 4 görsel](../../place-layout-a6-102x142/place-layout-a6-102x142-tr/)
- [72 × 102 mm — A4 üzerinde 8 görsel](../../place-layout-a7-72x102/place-layout-a7-72x102-tr/)
- [64 × 94 mm — A4 üzerinde 3 × 3](../../place-layout-64x94/place-layout-64x94-tr/)

Sorter hangi nihai baskı boyutunu kullanmanız gerektiğine karar vermez; sadece batch yerleşimden önce farklı oranları ayırır.

## Sınıflandırma

Script kısa kenarı uzun kenara oranlar; dikey ve yatay yön aynı şekilde değerlendirilir.

### Kare

```text
kısa kenar / uzun kenar >= 0.99
```

### A4-benzeri

A4 oranı **±10% toleransla** kabul edilir.

### Diğer

Kare veya A4-benzeri olmayan her şey `Other` klasörüne gider.

## Güvenlik

- kaynak görseller değişmez
- dosyalar taşınmaz, yalnızca kopyalanır
- çıktı klasörleri otomatik oluşturulur
- mevcut kopyaların üzerine yazılmaz
- script tekrar güvenle çalıştırılabilir
- yalnızca çalışma klasöründeki desteklenen görseller taranır

## Nasıl çalıştırılır?

1. `Sort_Images_By_Aspect_Ratio.ps1` dosyasını görsellerin bulunduğu klasöre koyun.
2. Klasörü **Dosya Gezgini**'nde açın.
3. Adres çubuğuna şunu yazın:

```text
powershell
```

4. **Enter**'a basın.
5. Açılan PowerShell penceresinde çalıştırın:

```powershell
.\Sort_Images_By_Aspect_Ratio.ps1
```

6. Oluşan `A4`, `Square` ve `Other` klasörlerini kontrol edin.

PowerShell yerel scriptleri engellerse, çalıştırma iznini yalnızca mevcut oturum için açıp scripti tekrar çalıştırın.

## İletişim

“Bunları göz kararı ayırırım” diye başlayıp **saatlerce klasör kazısı** yapıyorsanız, o iş büyük ihtimalle scriptliktir. Üçüncü çay da soğumadan, üretimde tekrar tekrar yaptığınız bir sonraki işi bize yazın: [**usta.scripts@gmail.com**](mailto:usta.scripts@gmail.com)
