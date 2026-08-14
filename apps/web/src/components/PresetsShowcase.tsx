import React, { useState } from 'react';
import { Film, CircleDot, Sparkles } from 'lucide-react';

const cinematicPresets = [
  { name: 'Sinema', desc: 'Teal & Orange Sinema Kontrastı', icon: 'film', accent: '#E08A46', filter: 'contrast(1.22) saturate(1.3) hue-rotate(-10deg)' },
  { name: 'Sıcak', desc: 'Altın Saat Günbatımı Sıcaklığı', icon: 'sun', accent: '#E5A93C', filter: 'sepia(0.28) saturate(1.35) brightness(1.08)' },
  { name: 'Soğuk', desc: 'Kuzey Mavi Atmosferi', icon: 'snowflake', accent: '#5B92E5', filter: 'hue-rotate(25deg) saturate(1.1) brightness(1.05)' },
  { name: 'Turkuaz', desc: 'Turkuaz & Cyan Gölgeler', icon: 'drop', accent: '#2FA4A9', filter: 'hue-rotate(15deg) contrast(1.2) saturate(1.4)' },
  { name: 'Soluk', desc: 'Matte Vintage Analog Film', icon: 'smoke', accent: '#9C9288', filter: 'contrast(0.9) brightness(1.12) saturate(0.85)' },
  { name: 'Gece', desc: 'Gece Şehri & Neon Derinliği', icon: 'moon', accent: '#3B4A7A', filter: 'contrast(1.3) brightness(0.92) hue-rotate(-15deg)' },
  { name: 'Orman', desc: 'Zümrüt Yeşili & Organik Toprak', icon: 'leaf', accent: '#3D8249', filter: 'saturate(1.2) hue-rotate(10deg) brightness(1.02)' },
  { name: 'Şehir', desc: 'Sert Metropol Kontrastı', icon: 'building', accent: '#7A7E85', filter: 'contrast(1.25) saturate(0.95)' },
  { name: 'Orijinal', desc: 'Kayıpsız Doğal Renkler', icon: 'circle', accent: '#a1a1aa', filter: 'none' },
];

const monoPresets = [
  { name: 'Doğal', desc: 'Dengeli Doğal Gri Ton Dağılımı', rgb: '29.9% R • 58.7% G • 11.4% B', filter: 'grayscale(100%) contrast(1.0)' },
  { name: 'Portre', desc: 'Pürüzsüz Ten & İpeksi Ton', rgb: '60% R • 30% G • 10% B', filter: 'grayscale(100%) contrast(1.08) brightness(1.04)' },
  { name: 'Yüksek Kontrast', desc: 'Derin Siyahlar & Parlak Gümüş', rgb: '35% R • 55% G • 10% B', filter: 'grayscale(100%) contrast(1.45) brightness(0.96)' },
  { name: 'Yumuşak', desc: 'İpeksi Düşük Kontrast & Gölge Detayı', rgb: '33.3% R • 33.3% G • 33.4% B', filter: 'grayscale(100%) contrast(0.85) brightness(1.05)' },
  { name: 'Sokak', desc: 'Sert Sokak & Mimari Doku', rgb: '40% R • 45% G • 15% B', filter: 'grayscale(100%) contrast(1.25)' },
  { name: 'Dramatik', desc: 'Kırmızı Filtre Gökyüzü Draması', rgb: '78% R • 18% G • 4% B', filter: 'grayscale(100%) contrast(1.5) brightness(0.9)' },
];

export const PresetsShowcase: React.FC = () => {
  const [collection, setCollection] = useState<'cinematic' | 'mono'>('cinematic');

  return (
    <section id="presets" style={{ padding: '100px 0', background: 'rgba(10, 10, 14, 0.4)' }}>
      <div className="container">
        
        {/* Section Header */}
        <div style={{ textAlign: 'center', marginBottom: '40px' }}>
          <div className="badge-pill badge-pill-cyan" style={{ marginBottom: '16px' }}>
            <Sparkles size={14} />
            <span>Küratörlü Önayarlar</span>
          </div>
          <h2 style={{ fontSize: 'clamp(32px, 4vw, 48px)', marginBottom: '16px' }}>
            İmzalı Renk & <span className="gradient-text-cyan">Ton Koleksiyonları</span>
          </h2>
          <p style={{ color: 'var(--text-secondary)', fontSize: '16px', maxWidth: '600px', margin: '0 auto' }}>
            Yılların renk bilimi ve analog fotoğrafçılık deneyimiyle tasarlanan hazır profiller.
          </p>

          {/* Tab Switcher */}
          <div
            style={{
              display: 'inline-flex',
              background: 'rgba(255, 255, 255, 0.06)',
              padding: '4px',
              borderRadius: 'var(--radius-full)',
              marginTop: '28px',
              border: '1px solid rgba(255, 255, 255, 0.1)',
            }}
          >
            <button
              onClick={() => setCollection('cinematic')}
              style={{
                background: collection === 'cinematic' ? '#ffffff' : 'transparent',
                color: collection === 'cinematic' ? '#000000' : 'var(--text-secondary)',
                border: 'none',
                padding: '10px 24px',
                borderRadius: 'var(--radius-full)',
                fontSize: '14px',
                fontWeight: 600,
                cursor: 'pointer',
                display: 'flex',
                alignItems: 'center',
                gap: '8px',
                transition: 'all 0.2s',
              }}
            >
              <Film size={16} />
              <span>Sinematik Görünümler (9)</span>
            </button>

            <button
              onClick={() => setCollection('mono')}
              style={{
                background: collection === 'mono' ? '#ffffff' : 'transparent',
                color: collection === 'mono' ? '#000000' : 'var(--text-secondary)',
                border: 'none',
                padding: '10px 24px',
                borderRadius: 'var(--radius-full)',
                fontSize: '14px',
                fontWeight: 600,
                cursor: 'pointer',
                display: 'flex',
                alignItems: 'center',
                gap: '8px',
                transition: 'all 0.2s',
              }}
            >
              <CircleDot size={16} />
              <span>Siyah & Beyaz (6)</span>
            </button>
          </div>
        </div>

        {/* Presets Grid */}
        <div
          style={{
            display: 'grid',
            gridTemplateColumns: 'repeat(auto-fill, minmax(260px, 1fr))',
            gap: '20px',
          }}
        >
          {collection === 'cinematic'
            ? cinematicPresets.map((item, idx) => (
                <div
                  key={idx}
                  className="glass-card"
                  style={{
                    padding: '18px',
                    display: 'flex',
                    flexDirection: 'column',
                    gap: '14px',
                  }}
                >
                  <div
                    style={{
                      position: 'relative',
                      width: '100%',
                      aspectRatio: '16/10',
                      borderRadius: '12px',
                      overflow: 'hidden',
                    }}
                  >
                    <img
                      src="/assets/nature.jpg"
                      alt={item.name}
                      style={{
                        width: '100%',
                        height: '100%',
                        objectFit: 'cover',
                        filter: item.filter,
                      }}
                    />
                    <div
                      style={{
                        position: 'absolute',
                        top: '8px',
                        right: '8px',
                        background: 'rgba(0, 0, 0, 0.65)',
                        backdropFilter: 'blur(6px)',
                        padding: '3px 8px',
                        borderRadius: '6px',
                        fontSize: '10px',
                        fontWeight: 700,
                        color: item.accent,
                      }}
                    >
                      {item.name}
                    </div>
                  </div>

                  <div>
                    <div style={{ fontSize: '16px', fontWeight: 700, color: '#ffffff' }}>{item.name}</div>
                    <div style={{ fontSize: '12px', color: 'var(--text-secondary)', marginTop: '2px' }}>{item.desc}</div>
                  </div>
                </div>
              ))
            : monoPresets.map((item, idx) => (
                <div
                  key={idx}
                  className="glass-card"
                  style={{
                    padding: '18px',
                    display: 'flex',
                    flexDirection: 'column',
                    gap: '14px',
                  }}
                >
                  <div
                    style={{
                      position: 'relative',
                      width: '100%',
                      aspectRatio: '16/10',
                      borderRadius: '12px',
                      overflow: 'hidden',
                    }}
                  >
                    <img
                      src="/assets/mono_sample.jpg"
                      alt={item.name}
                      style={{
                        width: '100%',
                        height: '100%',
                        objectFit: 'cover',
                        filter: item.filter,
                      }}
                    />
                    <div
                      style={{
                        position: 'absolute',
                        top: '8px',
                        right: '8px',
                        background: 'rgba(0, 0, 0, 0.75)',
                        backdropFilter: 'blur(6px)',
                        padding: '3px 8px',
                        borderRadius: '6px',
                        fontSize: '10px',
                        fontWeight: 700,
                        color: '#ffffff',
                      }}
                    >
                      {item.name}
                    </div>
                  </div>

                  <div>
                    <div style={{ fontSize: '16px', fontWeight: 700, color: '#ffffff' }}>{item.name}</div>
                    <div style={{ fontSize: '12px', color: 'var(--text-secondary)', marginTop: '2px' }}>{item.desc}</div>
                    <div style={{ fontSize: '11px', color: 'var(--accent-cyan)', marginTop: '4px', fontFamily: 'monospace' }}>
                      {item.rgb}
                    </div>
                  </div>
                </div>
              ))}
        </div>

      </div>
    </section>
  );
};
