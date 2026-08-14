import React from 'react';
import { Cpu, Film, CircleDot, ShieldCheck, Layers } from 'lucide-react';

const features = [
  {
    icon: Cpu,
    color: 'var(--accent-cyan)',
    tag: 'Core Image & Metal',
    title: '60 FPS Donanım Hızlandırmalı GPU Pipeline',
    description:
      'Her slider hareketinde iPhone GPU çekirdeklerini doğrudan kullanarak sıfır gecikmeyle anlık 60 FPS önizleme sunar. Bellek dostu mimarisiyle cihazınızı yormaz.',
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
    <section id="features" style={{ padding: '100px 0', position: 'relative' }}>
      <div className="container">
        
        {/* Section Title */}
        <div style={{ textAlign: 'center', marginBottom: '64px' }}>
          <div className="badge-pill badge-pill-cyan" style={{ marginBottom: '16px' }}>
            <Layers size={14} />
            <span>Mühendislik ve Tasarım</span>
          </div>
          <h2 style={{ fontSize: 'clamp(32px, 4vw, 48px)', marginBottom: '16px' }}>
            Photon'u Benzersiz Kılan <span className="gradient-text">4 Temel İlke</span>
          </h2>
          <p style={{ color: 'var(--text-secondary)', fontSize: '16px', maxWidth: '600px', margin: '0 auto' }}>
            Native Apple teknolojileriyle sıfırdan geliştirilen Photon, masaüstü sınıfı renk derecelendirme gücünü iPhone'unuza getiriyor.
          </p>
        </div>

        {/* Feature Cards Grid */}
        <div
          style={{
            display: 'grid',
            gridTemplateColumns: 'repeat(auto-fit, minmax(270px, 1fr))',
            gap: '24px',
          }}
        >
          {features.map((item, idx) => {
            const Icon = item.icon;
            return (
              <div
                key={idx}
                className="glass-card"
                style={{
                  padding: '32px 28px',
                  display: 'flex',
                  flexDirection: 'column',
                  gap: '16px',
                }}
              >
                <div
                  style={{
                    width: '48px',
                    height: '48px',
                    borderRadius: '14px',
                    background: 'rgba(255, 255, 255, 0.05)',
                    border: '1px solid rgba(255, 255, 255, 0.1)',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                  }}
                >
                  <Icon size={24} color={item.color} />
                </div>

                <div style={{ fontSize: '11px', fontWeight: 700, letterSpacing: '1.5px', textTransform: 'uppercase', color: item.color }}>
                  {item.tag}
                </div>

                <h3 style={{ fontSize: '20px', lineHeight: 1.3, color: '#ffffff' }}>
                  {item.title}
                </h3>

                <p style={{ fontSize: '14px', color: 'var(--text-secondary)', lineHeight: 1.6 }}>
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
