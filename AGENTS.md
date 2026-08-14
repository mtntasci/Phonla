# AGENTS.md — Photon Proje Kuralları ve Geliştirme Yönergeleri

Bu doküman, Photon monoreposunda çalışan yapay zeka ajanları (ve geliştiriciler) için bağlayıcı kural ve prensipleri tanımlar.

---

## 1. Genel Geliştirme Yaklaşımı

- **Native-First**: Photon tamamen native teknolojiler ile geliştirilecektir.
  - **iOS**: Swift + SwiftUI
  - **Android**: Kotlin + Jetpack Compose
  - **Kural**: Flutter, React Native veya benzeri cross-platform framework'ler **kullanılmayacaktır**.
- **Öncelikli Hedef (iOS MVP)**: İlk geliştirme hedefi eksiksiz, stabil bir **iOS MVP**'dir.
- **Android Parity Stratejisi**: Android geliştirmesi, iOS MVP fiziksel bir iPhone cihazda test edilip kabul edildikten sonra başlayacak ve kabul edilmiş iOS ürün davranışını birebir (parity) takip edecektir.
- **Yalınlık & Odak**: MVP geliştirme sürecinde gereksiz abstraction, premature optimization (erken optimizasyon) ve over-engineering **yapılmayacaktır**.
- **Aşama Disiplini**: Geliştirme `ROADMAP.md`'deki faz sırasına göre yürütülecektir. Kullanıcı onayı olmadan bir sonraki faza otomatik geçilmeyecektir.

---

## 2. Kritik Blocker Kriterleri

Aşağıdaki durumlar **kesin blocker** kabul edilir ve tespit edildiğinde derhal çözülmelidir:

1. **Crash**: Uygulamanın herhangi bir senaryoda çökmesi.
2. **Kullanıcı Fotoğrafının Bozulması / Kaybolması**: İşlem sırasında görsel verisinin bozulması, eksik kaydedilmesi veya kaybolması.
3. **Orijinal Fotoğrafın Overwrite Edilmesi**: Kaynak fotoğrafın üzerine yazılması veya doğrudan değiştirilmesi kesinlikle yasaktır.
4. **Ciddi Memory Problemleri**: OOM (Out-of-Memory) çökmeleri, yüksek bellek sızıntıları (memory leak) ve `CIContext` veya dokuların bellekten temizlenmemesi.
5. **Export / Render Doğruluğu**: Editor önizlemesi ile dışa aktarılan final görsel arasında renk, parlaklık veya çözünürlük tutarsızlığı.
6. **Authentication Güvenliği**: Yetkisiz oturum durumları, güvensiz token yönetimi veya hatalı session persistence.
7. **Privacy Problemi**: Kullanıcı fotoğraflarının veya kişisel verilerinin yetkisiz biçimde dışarı aktarılması/sızdırılması.
8. **Fiziksel Cihaz Uyumsuzluğu**: Temel özelliklerin gerçek iPhone cihazında çalışmaması veya kabul edilemez gecikmeyle (lag/unresponsive UI) çalışması.

> **Not**: Düşük riskli estetik/teknik mükemmelleştirmeler MVP sonrasına bırakılabilir.

---

## 3. iOS Geliştirme Kuralları

- **Mevcut Proje Bütünlüğü**:
  - `apps/ios/` (veya `apps/` altındaki mevcut Xcode projesi) kullanıcı tarafından oluşturulmuş resmi projedir.
  - Mevcut project/target yapısını incelemeden **asla değiştirme**.
  - Yeni bir Xcode projesi **oluşturma**.
  - Mevcut projeyi yeniden **generate etme**.
- **Bağımlılık Yönetimi (Dependencies)**:
  - Gereksiz harici kütüphane (third-party dependency) ekleme.
  - Apple native framework'lerini öncelikli olarak tercih et.
- **UI & Framework**:
  - Arayüz tamamen **SwiftUI** ile yazılacaktır.
- **Görüntü İşleme Öncelik Sırası**:
  1. **Core Image** (`CIImage`, `CIFilter`, `CIContext`)
  2. **Photos / PhotosUI** (`PHPickerViewController`, `PhotosPicker`, `PHPhotoLibrary`)
  3. **Metal** (Yalnızca Core Image ile çözülemeyen özel LUT/shader ihtiyaçlarında)
- **Third-Party Görüntü İşleme Yasağı**:
  - Yeni bir third-party görüntü işleme SDK'sı eklenmeden önce **kullanıcıdan açık onay alınmalıdır**.

---

## 4. Görüntü İşleme & State Mimarisi

- **Non-Destructive Editing**: Orijinal görsel daima salt-okunur (read-only) tutulur.
- **PhotoEditState**: Tüm düzenleme parametreleri (Light, Color, Cinematic Look, Mono) tek bir merkezi state modelinde (`PhotoEditState`) tutulur.
- **Preview vs Export Ayrımı**:
  - **Editor Sırasında**: Performans ve 60 FPS akıcılık için optimize edilmiş preview çözünürlüğü üzerinden render alınır.
  - **Export Sırasında**: Orijinal tam çözünürlüklü görsel + `PhotoEditState` uygulanarak yeni bir asset olarak kaydedilir.
  - Her slider hareketinde full-resolution görseli render etmek yasaktır.

---

## 5. Gizlilik (Privacy-First) Prensibi

- Photon MVP'de kullanıcı fotoğrafları **cihaz üzerinde (on-device)** işlenir.
- Fotoğraflar **asla** Firebase Storage'a, Photon backend'ine veya 3. parti sunuculara yüklenmez.
- Backend/Cloud altyapısı ileride yalnızca açıkça server-side bir ihtiyaç (ör. senkronizasyon, hesap yönetimi) doğarsa kullanılacaktır.

---

## 6. Kodlama & Git Standartları

- Açık, okunabilir, Swift API Design Guidelines'a uygun kod yazılmalıdır.
- Her faz tamamlandığında test edilmeli ve diff'ler temiz tutulmalıdır.
- Dosya ve klasör yapılandırmasında gereksiz derin nesting yapılmamalıdır.
