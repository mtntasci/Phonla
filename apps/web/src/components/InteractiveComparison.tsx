import React, { useState, useRef, useEffect } from 'react';
import { Sliders, MoveHorizontal, Check } from 'lucide-react';

interface PresetOption {
  id: string;
  name: string;
  category: 'Cinematic' | 'Monochrome';
  cssFilter: string;
  subtitle: string;
}

const presets: PresetOption[] = [
  {
    id: 'cinema',
    name: 'Sinema',
    category: 'Cinematic',
    cssFilter: 'contrast(1.22) saturate(1.3) hue-rotate(-10deg) brightness(1.04)',
    subtitle: 'Teal & Orange Sinema Kontrastı',
  },
  {
    id: 'warm',
    name: 'Sıcak',
    category: 'Cinematic',
    cssFilter: 'sepia(0.28) saturate(1.35) brightness(1.08) contrast(1.12)',
    subtitle: 'Altın Saat Güneş Işıltısı',
  },
  {
    id: 'cold',
    name: 'Soğuk',
    category: 'Cinematic',
    cssFilter: 'hue-rotate(25deg) saturate(1.1) brightness(1.05) contrast(1.15)',
    subtitle: 'Kuzey Mavi Atmosferi',
  },
  {
    id: 'teal',
    name: 'Turkuaz',
    category: 'Cinematic',
    cssFilter: 'hue-rotate(15deg) contrast(1.2) saturate(1.4) brightness(0.98)',
    subtitle: 'Cyan Gölgeler & Canlı Ten',
  },
  {
    id: 'fade',
    name: 'Soluk Film',
    category: 'Cinematic',
    cssFilter: 'contrast(0.9) brightness(1.12) saturate(0.85) sepia(0.12)',
    subtitle: 'Matte Vintage Analog Hissi',
  },
  {
    id: 'mono_high',
    name: 'Yüksek Kontrast S&B',
    category: 'Monochrome',
    cssFilter: 'grayscale(100%) contrast(1.45) brightness(0.95)',
    subtitle: 'Derin Siyahlar & Gümüş Dokusu',
  },
  {
    id: 'mono_dramatic',
    name: 'Dramatik S&B',
    category: 'Monochrome',
    cssFilter: 'grayscale(100%) contrast(1.6) brightness(0.88)',
    subtitle: 'Kırmızı Filtre Gökyüzü Efekti',
  },
];

export const InteractiveComparison: React.FC = () => {
  const [sliderPosition, setSliderPosition] = useState<number>(50);
  const [isDragging, setIsDragging] = useState<boolean>(false);
  const [activePreset, setActivePreset] = useState<PresetOption>(presets[0]);
  const [selectedImage, setSelectedImage] = useState<string>('/assets/portrait_sample.jpg');
  const containerRef = useRef<HTMLDivElement>(null);

  const handleMove = (clientX: number) => {
    if (!containerRef.current) return;
    const rect = containerRef.current.getBoundingClientRect();
    const x = clientX - rect.left;
    const percentage = Math.max(0, Math.min(100, (x / rect.width) * 100));
    setSliderPosition(percentage);
  };

  const handleMouseDown = () => setIsDragging(true);

  useEffect(() => {
    const handleGlobalMouseMove = (e: MouseEvent) => {
      if (isDragging) handleMove(e.clientX);
    };
    const handleGlobalMouseUp = () => {
      if (isDragging) setIsDragging(false);
    };
    const handleGlobalTouchMove = (e: TouchEvent) => {
      if (isDragging && e.touches[0]) handleMove(e.touches[0].clientX);
    };

    if (isDragging) {
      window.addEventListener('mousemove', handleGlobalMouseMove);
      window.addEventListener('mouseup', handleGlobalMouseUp);
      window.addEventListener('touchmove', handleGlobalTouchMove);
      window.addEventListener('touchend', handleGlobalMouseUp);
    }
    return () => {
      window.removeEventListener('mousemove', handleGlobalMouseMove);
      window.removeEventListener('mouseup', handleGlobalMouseUp);
      window.removeEventListener('touchmove', handleGlobalTouchMove);
      window.removeEventListener('touchend', handleGlobalMouseUp);
    };
  }, [isDragging]);

  return (
    <section id="comparison" style={{ padding: '80px 0', position: 'relative' }}>
      <div className="container">
        
        {/* Section Header */}
        <div style={{ textAlign: 'center', marginBottom: '36px' }}>
          <div className="badge-pill badge-pill-cyan" style={{ marginBottom: '14px' }}>
            <Sliders size={14} />
            <span>İnteraktif Kıyaslama Stüdyosu</span>
          </div>
          <h2 style={{ fontSize: 'clamp(28px, 4vw, 44px)', marginBottom: '14px' }}>
            Orijinal vs <span className="gradient-text-cyan">Photon Grade</span>
          </h2>
          <p style={{ color: 'var(--text-secondary)', fontSize: '15px', maxWidth: '580px', margin: '0 auto' }}>
            Çizgiyi parmağınızla veya fareyle sağa sola kaydırın ve Photon analog tonlama motorunun ham fotoğrafları nasıl işlediğini görün.
          </p>
        </div>

        {/* Preset Selector Strip */}
        <div
          style={{
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'flex-start',
            gap: '8px',
            overflowX: 'auto',
            paddingBottom: '12px',
            marginBottom: '24px',
            scrollbarWidth: 'none',
            WebkitOverflowScrolling: 'touch',
          }}
          className="presets-scroll-bar"
        >
          {presets.map((p) => {
            const isSelected = activePreset.id === p.id;
            return (
              <button
                key={p.id}
                onClick={() => setActivePreset(p)}
                style={{
                  background: isSelected ? '#ffffff' : 'rgba(255, 255, 255, 0.06)',
                  color: isSelected ? '#000000' : '#ffffff',
                  border: isSelected ? '1px solid #ffffff' : '1px solid rgba(255, 255, 255, 0.1)',
                  padding: '8px 16px',
                  borderRadius: 'var(--radius-full)',
                  fontSize: '12px',
                  fontWeight: 600,
                  cursor: 'pointer',
                  display: 'flex',
                  alignItems: 'center',
                  gap: '6px',
                  whiteSpace: 'nowrap',
                  flexShrink: 0,
                  transition: 'all 0.2s cubic-bezier(0.16, 1, 0.3, 1)',
                  boxShadow: isSelected ? '0 4px 16px rgba(255, 255, 255, 0.25)' : 'none',
                }}
              >
                {isSelected && <Check size={13} />}
                <span>{p.name}</span>
              </button>
            );
          })}
        </div>

        {/* Interactive Drag Before/After Canvas */}
        <div
          ref={containerRef}
          className="comparison-wrapper"
          onMouseDown={handleMouseDown}
          onTouchStart={handleMouseDown}
          onClick={(e) => handleMove(e.clientX)}
          style={{ cursor: 'ew-resize', touchAction: 'none' }}
        >
          <div className="comparison-image-container">
            {/* Before (Original Raw Photo) */}
            <img
              src={selectedImage}
              alt="Orijinal Fotoğraf"
              className="comparison-image"
              style={{ filter: 'none' }}
            />

            {/* "Orijinal" Badge */}
            <div
              style={{
                position: 'absolute',
                top: '14px',
                left: '14px',
                background: 'rgba(0, 0, 0, 0.75)',
                backdropFilter: 'blur(10px)',
                WebkitBackdropFilter: 'blur(10px)',
                color: '#ffffff',
                padding: '4px 10px',
                borderRadius: 'var(--radius-full)',
                fontSize: '10px',
                fontWeight: 600,
                letterSpacing: '1px',
                border: '1px solid rgba(255, 255, 255, 0.15)',
                zIndex: 5,
                pointerEvents: 'none',
              }}
            >
              ORİJİNAL
            </div>

            {/* After (Photon Graded Photo) */}
            <div
              className="comparison-image-after"
              style={{
                clipPath: `polygon(${sliderPosition}% 0, 100% 0, 100% 100%, ${sliderPosition}% 100%)`,
              }}
            >
              <img
                src={selectedImage}
                alt="Photon Graded Fotoğraf"
                className="comparison-image"
                style={{
                  filter: activePreset.cssFilter,
                  transition: 'filter 0.3s ease',
                }}
              />

              {/* "Photon Grade" Badge */}
              <div
                style={{
                  position: 'absolute',
                  top: '14px',
                  right: '14px',
                  background: 'rgba(0, 240, 255, 0.25)',
                  backdropFilter: 'blur(10px)',
                  WebkitBackdropFilter: 'blur(10px)',
                  color: 'var(--accent-cyan)',
                  padding: '4px 10px',
                  borderRadius: 'var(--radius-full)',
                  fontSize: '10px',
                  fontWeight: 700,
                  letterSpacing: '1px',
                  border: '1px solid rgba(0, 240, 255, 0.4)',
                  zIndex: 5,
                  pointerEvents: 'none',
                }}
              >
                PHOTON • {activePreset.name.toUpperCase()}
              </div>
            </div>

            {/* Center Drag Handle Line */}
            <div
              className="comparison-slider-handle"
              style={{ left: `${sliderPosition}%` }}
            >
              <div className="comparison-slider-button">
                <MoveHorizontal size={16} />
              </div>
            </div>
          </div>
        </div>

        {/* Sample Image Switcher */}
        <div
          style={{
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            gap: '8px',
            marginTop: '20px',
            flexWrap: 'wrap',
          }}
        >
          <span style={{ fontSize: '12px', color: 'var(--text-muted)' }}>Örnek:</span>
          {[
            { src: '/assets/portrait_sample.jpg', label: 'Portre' },
            { src: '/assets/mono_sample.jpg', label: 'Mimari' },
            { src: '/assets/cinema.jpg', label: 'Sinema' },
            { src: '/assets/nature.jpg', label: 'Doğa' },
            { src: '/assets/urban.jpg', label: 'Şehir' },
          ].map((item, idx) => (
            <button
              key={idx}
              onClick={() => setSelectedImage(item.src)}
              style={{
                background: selectedImage === item.src ? 'rgba(255, 255, 255, 0.2)' : 'rgba(255, 255, 255, 0.05)',
                border: selectedImage === item.src ? '1px solid #ffffff' : '1px solid rgba(255, 255, 255, 0.1)',
                color: selectedImage === item.src ? '#ffffff' : 'var(--text-secondary)',
                padding: '5px 12px',
                borderRadius: 'var(--radius-sm)',
                fontSize: '11px',
                fontWeight: 600,
                cursor: 'pointer',
                transition: 'all 0.2s',
              }}
            >
              {item.label}
            </button>
          ))}
        </div>

      </div>

      <style>{`
        .presets-scroll-bar::-webkit-scrollbar {
          display: none;
        }
        @media (min-width: 768px) {
          .presets-scroll-bar {
            justify-content: center !important;
            flex-wrap: wrap !important;
          }
        }
      `}</style>
    </section>
  );
};
