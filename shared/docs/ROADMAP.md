# Photon Geliştirme Yol Haritası (ROADMAP.md)

Bu doküman, Photon projesinin faz bazlı geliştirme yol haritasını tanımlar. Geliştirme sürecinde her faz tamamlandıktan sonra test edilecek ve kullanıcı onayı alınarak bir sonraki faza geçilecektir.

---

## Fazlar (Phases)

### Phase 0: Repository / Documentation / Rules 🏁 *(Tamamlandı)*
- Monorepo klasör yapısının oluşturulması (`apps/`, `backend/`, `shared/`, `firebase/`).
- `AGENTS.md`, `PRODUCT.md`, `ARCHITECTURE.md`, `IOS_MVP.md`, `ROADMAP.md`, `README.md` dokümantasyonunun hazırlanması.
- Mevcut Xcode projesinin doğrulanması ve dokunulmazlığının teyit edilmesi.

---

### Phase 1: iOS Application Foundation
- Mevcut Xcode proje ve target yapısının incelenmesi.
- Klasör hiyerarşisi (Core, Features, UI, Models, Services) ve temiz mimari iskeletinin kurulması.
- Tasarım sistemi token'ları (Renk paleti, Dark Theme, Tipografi, Buton stilleri).
- Temel navigasyon / root coordinator yapısının oluşturulması.

---

### Phase 2: Authentication + Session
- Firebase Auth SDK entegrasyonu (SPM üzerinden minimal yapılandırma).
- Sign in with Apple, Google Sign-In, Facebook Login akışları.
- Oturum sürekliliği (Session persistence) ve state listener mekanizması.
- Auth / Splash geçiş mantığı.

---

### Phase 3: Home + Native Photo Picker
- Minimalist Photon ana ekran tasarımı.
- `Fotoğraf Yükle` ana eylemi.
- `PhotosUI` (`PHPickerViewController` / `PhotosPicker`) entegrasyonu.
- Seçilen fotoğrafın editor için yüklenmesi ve hata durumlarının yönetimi.

---

### Phase 4: Core Image Editor Foundation
- `CIContext` (Metal-backed) yaşam döngüsü ve bellek yönetimi.
- `PhotoEditState` merkezi modelinin tanımlanması.
- Preview resolution optimizasyonu ve canlı SwiftUI / Metal render görünümü.
- Temel editor arayüz iskeleti.

---

### Phase 5: Light + Color Adjustments
- **Light**: Exposure, Brightness, Contrast, Highlights, Shadows filtreleri.
- **Color**: Temperature (Beyaz Dengesi), Tint, Saturation, Vibrance filtreleri.
- Gerçek zamanlı ve akıcı slider etkileşimleri.

---

### Phase 6: Cinematic LUT / Preset Engine
- Sinematik 3D LUT / Color Cube motoru altyapısı.
- Başlangıç sinematik preset paketlerinin (`shared/assets/luts/`) entegrasyonu.
- Ayarlanabilir preset yoğunluğu (Intensity slider: 0% - 100%).

---

### Phase 7: Mono Engine
- Profesyonel siyah-beyaz (Monochrome) filtre mimarisi.
- RGB kanal mikseri ve luminance tabanlı tonlama.
- Çoklu Mono preset seçeneklerinin (High Contrast, Noir, Soft vb.) sisteme eklenmesi.

---

### Phase 8: Undo/Redo + Before/After + Reset
- `HistoryManager` ile state geçmiş stack'i.
- Canlı Before/After karşılaştırma etkileşimi (Press & Hold veya Split).
- Tek tıkla tüm düzenlemeleri sıfırlama (Reset).
- Non-destructive state bütünlüğünün doğrulanması.

---

### Phase 9: Full-Resolution Export + Photos Save
- Orijinal tam çözünürlüklü görsel üzerinden final render pipeline'ı.
- `PHPhotoLibrary` entegrasyonu ile yeni bir asset olarak galeriye kaydetme.
- Kaynak fotoğrafın asla üzerine yazılmadığının doğrulanması.
- Export başarı bildirimi ve hata yönetimi.

---

### Phase 10: Physical iPhone MVP Verification
- Gerçek iPhone cihazda performans, FPS ve ısınma testleri.
- Memory leak ve OOM profillemesi (Instruments).
- Render renk doğruluğu ve export kalitesi doğrulaması.
- MVP acceptance (kabul) onayı.

---

### Phase 11: Android Parity
- Kotlin + Jetpack Compose ile Android projesinin başlatılması.
- Onaylanmış iOS MVP ürün davranışının ve mimarisinin Android platformuna birebir uyarlanması.

---

## Gelecek Sürümler (Post-MVP / Later)

- **Auto Enhancement**: Yapay zeka veya histogram tabanlı tek dokunuşla otomatik ışık iyileştirme.
- **Ekstra Preset Paketleri**: İndirilebilir / satın alınabilir yeni sinematik renk paketleri.
- **RAW Desteği**: Apple ProRAW ve DNG dosyalarını işleme yeteneği.
- **Gelişmiş Renk Araçları**: Ton eğrileri (Curves), seçici renk (HSL), split toning.
- **Kırpma ve Perspektif**: Crop, Rotate, Dikey/Yatay perspektif düzeltme.
- **Cloud / Backend Servisleri**: Yalnızca gerçekten sunucu tarafı bir ihtiyaç doğduğunda değerlendirilecektir.
