import React from 'react';
import { Cpu, Film, CircleDot, ShieldCheck, Layers } from 'lucide-react';

const features = [
  {
    icon: Cpu,
    color: 'var(--accent-cyan)',
    tag: 'iOS & Android Native GPU',
    title: '60 FPS Donanım Hızlandırmalı Pipeline',
    description:
      'Her slider hareketinde mobil GPU çekirdeklerini doğrudan kullanarak sıfır gecikmeyle anlık 60 FPS önizleme sunar. Bellek dostu mimarisiyle cihazınızı yormaz.',
  },
  {
    icon: Film,
    color: 'var(--accent-amber)',
    tag: '35mm Film Karakteri',
    title: 'Ödüllü Sinematik Renk Paletleri',
    description:
      'Analog 35mm film emülasyonları, altın saat sıcaklığı ve sinematik kontrast eğrileriyle fotoğraflarınıza gerçek bir sinema filmi derinliği kazandırın.',
  },
  {
    icon: CircleDot,
    color: '#ffffff',
    tag: 'Analog Gümüş Baskı',
    title: 'Profesyonel Monochrome Motoru',
    description:
      'Sıradan bir gri filtre yerine; Kırmızı, Yeşil ve Mavi ışık kanallarını ayrı ayrı harmanlayan gelişmiş lüminans formülleriyle kadifemsi derin siyahlar ve parlak gümüş tonlar.',
  },
  {
    icon: ShieldCheck,
    color: '#10b981',
    tag: '%100 On-Device Gizlilik',
    title: 'Sıfır Bulut, Mutlak Cihaz Güvenliği',
    description:
      'Fotoğraflarınız hiçbir sunucuya yüklenmez, yapay zeka sunucularında taranmaz. Orijinal fotoğrafınız salt-okunur kalır ve asla üzerine yazılmaz.',
  },
];

export const FeaturesSection: React.FC = () => {
  return (
    <section id="features" style={{ padding: '80px 0', position: 'relative' }}>
      <div className="container">
        
        {/* Section Title */}
        <div style={{ textAlign: 'center', marginBottom: '48px' }}>
          <div className="badge-pill badge-pill-cyan" style={{ marginBottom: '14px' }}>
            <Layers size={14} />
            <span>Mühendislik ve Tasarım</span>
          </div>
          <h2 style={{ fontSize: 'clamp(28px, 4vw, 44px)', marginBottom: '14px' }}>
            Phonla'yı Benzersiz Kılan <span className="gradient-text">4 Temel İlke</span>
          </h2>
          <p style={{ color: 'var(--text-secondary)', fontSize: '15px', maxWidth: '580px', margin: '0 auto' }}>
            Native mobil teknolojileriyle (Swift & Kotlin) sıfırdan geliştirilen Phonla, masaüstü sınıfı renk derecelendirme gücünü cebinize getiriyor.
          </p>
        </div>

        {/* Feature Cards Grid */}
        <div
          style={{
            display: 'grid',
            gridTemplateColumns: 'repeat(auto-fit, minmax(250px, 1fr))',
            gap: '20px',
          }}
        >
          {features.map((item, idx) => {
            const Icon = item.icon;
            return (
              <div
                key={idx}
                className="glass-card"
                style={{
                  padding: '28px 22px',
                  display: 'flex',
                  flexDirection: 'column',
                  gap: '14px',
                }}
              >
                <div
                  style={{
                    width: '44px',
                    height: '44px',
                    borderRadius: '12px',
                    background: 'rgba(255, 255, 255, 0.05)',
                    border: '1px solid rgba(255, 255, 255, 0.1)',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                  }}
                >
                  <Icon size={22} color={item.color} />
                </div>

                <div style={{ fontSize: '10px', fontWeight: 700, letterSpacing: '1.5px', textTransform: 'uppercase', color: item.color }}>
                  {item.tag}
                </div>

                <h3 style={{ fontSize: '18px', lineHeight: 1.3, color: '#ffffff' }}>
                  {item.title}
                </h3>

                <p style={{ fontSize: '13px', color: 'var(--text-secondary)', lineHeight: 1.6 }}>
                  {item.description}
                </p>
              </div>
            );
          })}
        </div>

      </div>
    </section>
  );
};
