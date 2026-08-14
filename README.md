# Photon

**Photon**, ışık manipülasyonu, sinematik renk derecelendirme (color grading) ve profesyonel monochrome işlemlerine odaklanan native bir mobil fotoğraf düzenleme uygulamasıdır.

---

## Teknoloji Yığını & Platformlar

- **iOS**: Swift 6, SwiftUI, Core Image, Metal, Photos / PhotosUI
- **Android** *(Post-iOS MVP)*: Kotlin, Jetpack Compose
- **Auth**: Firebase Authentication (Apple, Google, Facebook)
- **Monorepo**: Native platformlar, paylaşılan dokümanlar ve varlıklar tek bir depoda barındırılır.

---

## Geliştirme Stratejisi (iOS-First)

1. **Native-First**: Cross-platform katmanları kullanılmaz; platformun sunduğu native grafik ve donanım hızlandırma yeteneklerinden tam olarak faydalanılır.
2. **Önce iOS MVP**: Tüm temel özellikler ve kullanıcı deneyimi öncelikle iOS üzerinde tamamlanacak ve fiziksel iPhone cihazında doğrulanacaktır.
3. **Android Parity**: iOS MVP kabul edildikten sonra onaylanmış mimari ve tasarım kuralları Android'e aktarılacaktır.
4. **On-Device Gizlilik**: Görseller uzak sunuculara yüklenmez; tüm filtreleme ve render işlemleri tamamen cihaz üzerinde gerçekleştirilir.

---

## Monorepo Klasör Yapısı

```text
Photon/
├── AGENTS.md                 # Agent ve geliştirici kuralları & kısıtları
├── README.md                 # Genel proje özeti ve teknik genel bakış
│
├── apps/
│   ├── Photon.xcodeproj      # Mevcut iOS Xcode Projesi
│   ├── Photon/               # iOS kaynak kodları (SwiftUI)
│   ├── PhotonTests/          # iOS birim testleri
│   ├── PhotonUITests/        # iOS UI testleri
│   ├── android/              # Android uygulaması (Kotlin + Compose)
│   └── web/                  # Web uygulaması (Next.js - İleride)
│
├── backend/
│   └── go/                   # Backend servisleri (Go - İleride)
│
├── shared/
│   ├── assets/
│   │   └── luts/             # Sinematik 3D LUT ve renk tabloları
│   └── docs/
│       ├── PRODUCT.md        # Detaylı ürün tanımı ve vizyonu
│       ├── ARCHITECTURE.md   # Görüntü işleme ve state mimarisi
│       ├── IOS_MVP.md        # iOS MVP kapsamı ve teknik detaylar
│       └── ROADMAP.md        # Faz bazlı geliştirme yol haritası
│
└── firebase/                 # Firebase kuralları ve konfigürasyonları
```

---

## Dokümantasyon

Tüm detaylı dokümanlara `shared/docs/` dizininden ve `AGENTS.md` dosyasından erişilebilir:

- [`AGENTS.md`](./AGENTS.md): Agent geliştirme kuralları, kısıtlar ve blocker kriterleri.
- [`PRODUCT.md`](./shared/docs/PRODUCT.md): Ürün vizyonu, felsefesi ve kullanıcı akışları.
- [`ARCHITECTURE.md`](./shared/docs/ARCHITECTURE.md): Preview/Export render pipeline'ı ve `PhotoEditState` mimarisi.
- [`IOS_MVP.md`](./shared/docs/IOS_MVP.md): iOS MVP araçları, filtreleri ve kullanıcı deneyimi.
- [`ROADMAP.md`](./shared/docs/ROADMAP.md): Faz 0'dan Faz 11'e aşamalı geliştirme planı.

---

## Mevcut Durum

- **Mevcut Faz**: `Phase 0: Repository / Documentation / Rules` tamamlandı.
- **Sıradaki Faz**: `Phase 1: iOS Application Foundation`.
