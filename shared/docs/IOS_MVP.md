# iOS MVP Kapsamı ve Detayları (IOS_MVP.md)

Bu doküman, Photon iOS MVP (Minimum Viable Product) sürümünün kapsamını, teknik gereksinimlerini ve kullanıcı deneyimi kurallarını tanımlar.

---

## 1. Authentication (Oturum Yönetimi)

- **Altyapı**: Firebase Authentication.
- **Desteklenen Sağlayıcılar (Providers)**:
  - Sign in with Apple (iOS native öncelikli)
  - Google Sign-In
  - Facebook Login
- **Session Persistence**:
  - Uygulama yeniden başlatıldığında kullanıcının oturum durumu korunmalı ve kullanıcı doğrudan `Home` ekranına yönlendirilmelidir.
- **Güvenlik & Temizlik Kuralı**:
  - Firebase SDK tarafından yönetilen token ve credential'ların gereksiz ikinci bir kopyası (UserDefaults, Keychain vb.) tutulmamalıdır; Firebase Auth state dinleyicileri (`AuthStateDidChangeListenerHandle`) kullanılmalıdır.

---

## 2. Home Ekranı

- **Tasarım**: Minimalist, şık, karanlık mod (dark theme) odaklı Photon arayüzü.
- **Ana CTA (Call to Action)**: `Fotoğraf Yükle` butonu.
- **Photo Picker**:
  - `PhotosUI` (`PHPickerViewController` veya SwiftUI `PhotosPicker`) kullanılarak native iOS galerisi açılır.
  - İzin isteme akışları Apple yönergelerine uygun şekilde yönetilir.
  - Seçilen fotoğraf editor state'ine güvenle yüklenir.

---

## 3. Editor (Düzenleme Araçları)

Editor 4 ana araç kategorisinden oluşur:

### 3.1. Light (Işık Ayarları)
- **Exposure (Pozlama)**: Genel ışık seviyesi artırma/azaltma.
- **Brightness (Parlaklık)**: Orta tonların parlaklık dengesi.
- **Contrast (Kontrast)**: Açık ve koyu alanlar arasındaki dinamik aralık.
- **Highlights (Açık Tonlar)**: Parlak alanları kurtarma/kısma.
- **Shadows (Gölgeler)**: Karanlık alanları açma/derinleştirme.

### 3.2. Color (Renk Ayarları)
- **Temperature (Sıcaklık)**: Sıcak (kehribar/sarı) - Soğuk (mavi) dengesi (Kelvin/RGB shift).
- **Tint (Ton)**: Yeşil - Magenta renk kayması.
- **Saturation (Doygunluk)**: Tüm renklerin genel canlılık seviyesi.
- **Vibrance (Dinamik Doygunluk)**: Cilt tonlarını koruyarak daha az doymuş renkleri öne çıkarma.

### 3.3. Cinematic (Sinematik Görünümler)
- **Preset / LUT Tabanlı**: Film ve sinema estetiğine uygun renk profilleri (Color grading / 3D LUT / Color Cube).
- **Intensity (Yoğunluk) Kontrolü**: Her preset 0% ile 100% arasında ayarlanabilir yoğunluk slider'ına sahip olmalıdır.

### 3.4. Mono (Monochrome / Siyah-Beyaz Motoru)
- **Profesyonel B&W Yaklaşımı**: Sadece saturasyonu sıfırlayan yüzeysel yöntemler **kullanılmamalıdır**.
- **Luminance & RGB Kanal Karışımı**: Kırmızı, yeşil ve mavi kanalların ağırlıklarını kontrol eden gerçek monochrome filtre mimarisi uygulanmalıdır.
- **Çoklu Preset Mimarisi**: Başlangıçta farklı kontrast ve ton karakterlerine sahip birden fazla Mono preset (ör. High Contrast, Silky Noir, Vintage Grain, Architectural) eklenebilecek genişletilebilir bir mimari kurulmalıdır.

---

## 4. Editor UX ve Etkileşimler

- **Before / After**: Kullanıcının orijinal görsel ile düzenlenmiş halini anlık kıyaslayabilmesi (uzun basma veya karşılaştırma kontrolü).
- **Undo / Redo**: Yapılan her parametre değişikliğini adım adım geri/ileri alabilme.
- **Reset**: Tüm düzenlemeleri sıfırlayarak fotoğrafı ilk ham haline döndürme.
- **Non-Destructive Editing**: Düzenlemeler bir parametre kümesi (`PhotoEditState`) olarak tutulur; hiçbir aşamada geri dönülemez piksel kaybı yaşanmaz.

---

## 5. Export ve Kaydetme

- **Orijinal Görsel Güvenliği**: Kaynak fotoğraf hiçbir koşulda overwrite edilmez (üzerine yazılmaz).
- **Yeni Asset Olarak Kayıt**: Düzenlenen görsel `PHPhotoLibrary` aracılığıyla kullanıcının fotoğraf galerisine yeni bir fotoğraf olarak kaydedilir.
- **Full-Resolution Render**: Dışa aktarım sırasında önizleme ölçeği değil, orijinal görselin tam çözünürlüğü ve kalitesi üzerinden render pipeline çalıştırılır.
- **Format & Metadata**: JPEG/HEIC formatında, mümkün olan en yüksek kalite ve doğru renk uzayı (sRGB / Display P3) korunarak export edilir.
