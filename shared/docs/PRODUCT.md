# Photon — Ürün Tanımı (PRODUCT.md)

## 1. Genel Bilgiler

- **Ürün Adı**: Photon
- **Bundle ID**: `com.alafteknoloji.photon` (veya proje tanımına göre `com.alafteknoloji.Photon`)
- **Platform**: Native iOS (İlk Hedef), Native Android (Parity)
- **Teknoloji**: Swift, SwiftUI, Core Image, Metal

---

## 2. Ürün Vizyonu ve Temel Yaklaşım

**Photon**; ışık manipülasyonu, sinematik color grading ve profesyonel monochrome işlemlerine odaklanan üst seviye bir native mobil fotoğraf düzenleme uygulamasıdır.

### Felsefe: Odaklanmış ve Hızlı Estetik

Photon, Photoshop veya Lightroom benzeri yüzlerce karmaşık araç barındıran genel amaçlı bir editör olmayı hedeflemez. 

Temel ürün yaklaşımı:
> **Fotoğraf Seç → Işığı Düzenle → Sinematik veya Mono Görünüm Uygula → Kaydet.**

Photon'un amacı, kullanıcının saniyeler içinde fotoğraflarına sinematik bir atmosfer ve profesyonel ışık/kontrast dengesi kazandırmasını sağlamaktır.

---

## 3. Temel Kullanıcı Akışı (User Flow)

```text
┌──────────────┐
│    Splash    │
└──────┬───────┘
       │
       ▼
┌─────────────────────────┐
│  Auth / Session Check   │
└──────┬──────────────────┘
       │
       ▼
┌──────────────┐
│     Home     │
└──────┬───────┘
       │
       ▼
┌──────────────────┐
│   Photo Picker   │
└──────┬───────────┘
       │
       ▼
┌──────────────┐
│    Editor    │  ◄── [Light / Color / Cinematic / Mono]
└──────┬───────┘
       │
       ▼
┌──────────────┐
│    Export    │  ──► [Save to Photos as New Asset]
└──────────────┘
```

---

## 4. MVP Özellik Kümeleri

1. **Authentication**: 
   - Firebase Auth tabanlı güvenli oturum yönetimi (Sign in with Apple, Google, Facebook).
   - Session persistence (kullanıcının her açılışta tekrar giriş yapmaması).
2. **Minimalist Home**:
   - Sade, karanlık mod odaklı ve şık arayüz.
   - Ana eylem: `Fotoğraf Yükle` butonu.
   - Native Apple Photos Picker entegrasyonu.
3. **Core Editor**:
   - **Light**: Exposure, Brightness, Contrast, Highlights, Shadows.
   - **Color**: Temperature, Tint, Saturation, Vibrance.
   - **Cinematic Looks**: Ayarlanabilir yoğunluklu (intensity) sinematik LUT/preset kütüphanesi.
   - **Mono Engine**: Luminance ve RGB kanal dengeli profesyonel siyah-beyaz motoru.
4. **Editor UX**:
   - Before / After canlı karşılaştırma.
   - Undo / Redo geçmiş yönetimi.
   - Reset (tek dokunuşla sıfırlama).
   - Non-destructive state yapısı.
5. **Non-Destructive Export**:
   - Orijinal dosya bütünlüğünü koruma.
   - Orijinal çözünürlükte yüksek kaliteli render.
   - Fotoğraf galerisine yeni bir asset olarak kaydetme.

---

## 5. Gizlilik ve Güvenlik Taahhüdü

- **On-Device Image Processing**: Kullanıcı fotoğrafları tamamen cihaz üzerinde işlenir.
- **Sıfır Sunucu Yüklemesi**: MVP kapsamında görseller hiçbir uzak sunucuya, veritabanına veya Firebase Storage'a yüklenmez.
- **Kaynak Koruma**: Kaynak görsel asla üzerine yazılarak yok edilemez.
