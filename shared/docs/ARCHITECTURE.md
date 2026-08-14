# Photon Mimari Dokümantasyonu (ARCHITECTURE.md)

Bu doküman, Photon'un görüntü işleme motorunu, state yönetimini, render yaşam döngüsünü ve veri gizliliği prensiplerini detaylandırır.

---

## 1. Temel Görüntü İşleme Mimarisi

Photon'da görüntü işleme mimarisi, **Editor Önizleme Pipeline**'ı ve **Export Final Render Pipeline**'ı olarak kesin bir şekilde ikiye ayrılmıştır.

### 1.1. Editor Sırasında (Preview Pipeline)

```text
┌────────────────────────┐
│     Original Image     │
└───────────┬────────────┘
            │ (Downscaled / Cached Preview CIImage)
            ▼
┌────────────────────────┐       ┌────────────────────────┐
│     PhotoEditState     │ ────► │  Filter Pipeline (CI)  │
└────────────────────────┘       └───────────┬────────────┘
                                             │
                                             ▼
                                 ┌────────────────────────┐
                                 │     Preview Render     │
                                 │ (SwiftUI / Metal View) │
                                 └────────────────────────┘
```

- Kullanıcı slider'ı her kaydırdığında full-resolution (ör. 48 MP) bir görüntüyü render etmek **yasaktır**.
- Editor performansının (akıcı 60+ FPS, düşük ısınma ve bellek tüketimi) korunması için ekran boyutuna uygun ölçeklendirilmiş bir **Preview CIImage** kullanılır.
- Filtre zinciri doğrudan GPU üzerinden (`CIContext(mtlDevice: ...)`) çalıştırılır.

### 1.2. Export Sırasında (Final Render Pipeline)

```text
┌──────────────────────────────────────┐
│    Original Full-Resolution Image    │
└──────────────────┬───────────────────┘
                   │
                   ▼
┌──────────────────────────────────────┐       ┌────────────────────────┐
│            PhotoEditState            │ ────► │  Filter Pipeline (CI)  │
└──────────────────────────────────────┘       └───────────┬────────────┘
                                                           │
                                                           ▼
                                               ┌────────────────────────┐
                                               │      Final Render      │
                                               │ (Full Quality CIImage) │
                                               └───────────┬────────────┘
                                                           │
                                                           ▼
                                               ┌────────────────────────┐
                                               │    New Photo Asset     │
                                               │ (Saved to Photo Lib)   │
                                               └────────────────────────┘
```

- Export tetiklendiğinde aynı `PhotoEditState` parametreleri, görselin **orijinal tam çözünürlüklü** verisine uygulanır.
- Kaynak dosya asla bozulmaz veya üzerine yazılmaz; `PHPhotoLibrary` ile yeni bir fotoğraf varlığı (asset) olarak galeriye eklenir.

---

## 2. Merkezi State Modeli: `PhotoEditState`

Tüm düzenleme parametreleri deterministik ve bağımsız bir state modelinde toplanır:

```swift
struct PhotoEditState: Equatable, Codable {
    // Light
    var exposure: Float = 0.0      // -2.0 ... 2.0
    var brightness: Float = 0.0    // -1.0 ... 1.0
    var contrast: Float = 1.0      // 0.5 ... 1.5
    var highlights: Float = 0.0    // -1.0 ... 1.0
    var shadows: Float = 0.0       // -1.0 ... 1.0
    
    // Color
    var temperature: Float = 6500.0 // 2000K ... 10000K (Neutral: 6500K)
    var tint: Float = 0.0          // -100.0 ... 100.0
    var saturation: Float = 1.0    // 0.0 ... 2.0
    var vibrance: Float = 0.0      // -1.0 ... 1.0
    
    // Cinematic Look
    var selectedLookId: String? = nil
    var lookIntensity: Float = 1.0 // 0.0 ... 1.0
    
    // Monochrome
    var isMonoActive: Bool = false
    var selectedMonoPresetId: String? = nil
    var monoIntensity: Float = 1.0
    
    // State Yardımcıları
    var isEdited: Bool { ... }
    static let identity = PhotoEditState()
}
```

### State Yönetimi Prensipleri
1. **Tek Doğruluk Kaynağı (Single Source of Truth)**: Editördeki tüm kontroller `PhotoEditState`'e bağlanır.
2. **Undo/Redo Desteği**: `HistoryManager` ile geçmiş durumlar bir stack yapısında saklanarak sıfır maliyetli geri/ileri alma sağlanır.
3. **Deterministik**: Aynı `PhotoEditState` ve aynı kaynak görsel her zaman birebir aynı piksel çıktısını üretir.

---

## 3. Core Image & Metal Pipeline Katmanları

Görüntü işleme ardışık (pipeline) bir sırayla uygulanır:

```text
Source Image
    │
    ▼
[1. Light Adjustments]   (Exposure, Highlights/Shadows, Contrast/Brightness)
    │
    ▼
[2. Color Adjustments]   (White Balance/Temperature/Tint, Saturation, Vibrance)
    │
    ▼
[3. Cinematic Grading]   (CIColorCube / 3D LUT Engine, Intensity Blending)
    │
    ▼
[4. Monochrome Engine]   (RGB Channel Matrix / Luminance Filter)
    │
    ▼
Output Image
```

### Performans & Bellek Kuralları
- **CIContext Yeniden Kullanımı**: `CIContext` maliyetli bir nesnedir; her render çağrısında yeni context oluşturulmaz, tek bir paylaşılan `Metal-backed CIContext` kullanılır.
- **Lazy Evaluation**: Core Image'ın lazy render avantajından yararlanılır; pikseller yalnızca ekrana çizilirken veya diske yazılırken işlenir.

---

## 4. Privacy & Veri Güvenliği Mimarisi

1. **Tamamen Cihaz Üstü (100% On-Device)**:
   - Tüm piksel işleme operasyonları doğrudan kullanıcının iPhone donanımında (Apple Neural Engine / Metal GPU) gerçekleşir.
2. **Sıfır Bulut Bağımlılığı**:
   - Düzenlenen fotoğraflar Firebase'e, harici backend'e veya Photon sunucularına **kesinlikle gönderilmez**.
3. **Ağ İzolasyonu**:
   - Image pipeline ile ağ katmanı arasında hiçbir veri köprüsü kurulmaz.
   - Firebase yalnızca kullanıcı kimlik doğrulama (Auth) oturumunu yönetmek için kullanılır.
