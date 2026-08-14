import React, { useState } from 'react';
import { Apple, Play, Sun, Palette, Film, CircleDot, ShieldCheck, Zap } from 'lucide-react';

export const HeroSection: React.FC = () => {
  const [activeTab, setActiveTab] = useState<'light' | 'color' | 'cinematic' | 'mono'>('cinematic');
  const [activeBg, setActiveBg] = useState<string>('/assets/cinema.jpg');

  // Filter dynamic styling based on active tab
  const getImageFilter = () => {
    switch (activeTab) {
      case 'light':
        return 'brightness(1.15) contrast(1.1) saturate(1.05)';
      case 'color':
        return 'saturate(1.4) sepia(0.15) contrast(1.08)';
      case 'cinematic':
        return 'contrast(1.2) saturate(1.25) hue-rotate(-8deg) brightness(1.05)';
      case 'mono':
        return 'grayscale(100%) contrast(1.35) brightness(0.95)';
      default:
        return 'none';
    }
  };

  return (
    <section
      style={{
        position: 'relative',
        paddingTop: '140px',
        paddingBottom: '100px',
        overflow: 'hidden',
      }}
    >
      {/* Background Ambient Glows */}
      <div
        style={{
          position: 'absolute',
          top: '10%',
          left: '50%',
          transform: 'translateX(-50%)',
          width: '700px',
          height: '400px',
          background: 'radial-gradient(circle, rgba(0, 240, 255, 0.15) 0%, rgba(255, 122, 0, 0.08) 50%, transparent 80%)',
          filter: 'blur(80px)',
          zIndex: 0,
          pointerEvents: 'none',
        }}
        className="pulse-glow"
      />

      <div className="container" style={{ position: 'relative', zIndex: 1 }}>
        <div style={{ display: 'grid', gridTemplateColumns: '1.1fr 0.9fr', gap: '60px', alignItems: 'center' }} className="hero-grid">
          
          {/* Left Text & CTA Column */}
          <div style={{ display: 'flex', flexDirection: 'column', gap: '24px' }}>
            {/* Pill Tag */}
            <div style={{ display: 'flex', alignItems: 'center', gap: '10px', flexWrap: 'wrap' }}>
              <div className="badge-pill badge-pill-cyan">
                <Zap size={14} />
                <span>Apple Metal GPU Hızlandırmalı</span>
              </div>
              <div className="badge-pill">
                <ShieldCheck size={14} color="#10b981" />
                <span>%100 On-Device Gizlilik</span>
              </div>
            </div>

            {/* Main Headline */}
            <h1 style={{ fontSize: 'clamp(38px, 5.5vw, 64px)', letterSpacing: '-0.03em', lineHeight: 1.08 }}>
              Işığın, Sinemanın ve <span className="gradient-text-cyan">Siyah-Beyazın</span> Saf Hali.
            </h1>

            {/* Subtitle */}
            <p style={{ fontSize: '18px', color: 'var(--text-secondary)', lineHeight: 1.6, maxWidth: '540px' }}>
              Fotoğraflarınızı buluta yüklemeden, iPhone'unuzun Metal GPU donanımıyla anlık 60 FPS hızında işleyin. 
              35mm analog film tonları ve gümüş baskı hissi parmaklarınızın ucunda.
            </p>

            {/* Call to Actions */}
            <div style={{ display: 'flex', alignItems: 'center', gap: '16px', flexWrap: 'wrap', paddingTop: '8px' }}>
              <a
                href="https://apps.apple.com"
                target="_blank"
                rel="noreferrer"
                className="btn btn-primary"
                style={{ padding: '16px 32px', fontSize: '16px' }}
              >
                <Apple size={20} />
                <span>App Store'dan İndir</span>
              </a>

              <a
                href="#comparison"
                className="btn btn-secondary"
                style={{ padding: '16px 28px', fontSize: '15px' }}
              >
                <Play size={16} fill="currentColor" />
                <span>Canlı Stüdyoyu Dene</span>
              </a>
            </div>

            {/* Stats Metrics */}
            <div
              style={{
                display: 'grid',
                gridTemplateColumns: 'repeat(3, 1fr)',
                gap: '20px',
                paddingTop: '28px',
                borderTop: '1px solid rgba(255, 255, 255, 0.08)',
                marginTop: '12px',
              }}
            >
              <div>
                <div style={{ fontFamily: 'var(--font-display)', fontSize: '28px', fontWeight: 800, color: '#ffffff' }}>60 FPS</div>
                <div style={{ fontSize: '13px', color: 'var(--text-muted)' }}>Gerçek Zamanlı GPU Render</div>
              </div>
              <div>
                <div style={{ fontFamily: 'var(--font-display)', fontSize: '28px', fontWeight: 800, color: 'var(--accent-cyan)' }}>%100</div>
                <div style={{ fontSize: '13px', color: 'var(--text-muted)' }}>Cihaz Üzerinde Gizlilik</div>
              </div>
              <div>
                <div style={{ fontFamily: 'var(--font-display)', fontSize: '28px', fontWeight: 800, color: 'var(--accent-amber)' }}>Tam</div>
                <div style={{ fontSize: '13px', color: 'var(--text-muted)' }}>Kayıpsız 48MP+ Çözünürlük</div>
              </div>
            </div>
          </div>

          {/* Right Column: Interactive Phone Mockup */}
          <div style={{ display: 'flex', justifyContent: 'center', position: 'relative' }}>
            {/* Background Halo */}
            <div
              style={{
                position: 'absolute',
                inset: '-20px',
                background: 'linear-gradient(180deg, rgba(0, 240, 255, 0.15) 0%, rgba(255, 122, 0, 0.1) 100%)',
                borderRadius: '60px',
                filter: 'blur(30px)',
                zIndex: 0,
              }}
            />

            {/* Interactive Phone Frame */}
            <div className="phone-mockup-container" style={{ position: 'relative', zIndex: 1 }}>
              {/* Dynamic Island */}
              <div className="phone-island" />

              {/* Screen Content */}
              <div style={{ width: '100%', height: '100%', display: 'flex', flexDirection: 'column', background: '#0a0a0e' }}>
                
                {/* Simulated App Header */}
                <div
                  style={{
                    padding: '38px 18px 12px 18px',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'space-between',
                    background: 'rgba(10, 10, 14, 0.7)',
                    backdropFilter: 'blur(10px)',
                    zIndex: 20,
                  }}
                >
                  <span style={{ fontSize: '12px', fontWeight: 700, letterSpacing: '2px', color: '#fff' }}>PHOTON</span>
                  <div style={{ display: 'flex', gap: '8px' }}>
                    <span style={{ fontSize: '11px', color: '#a1a1aa' }}>Sıfırla</span>
                    <span style={{ fontSize: '11px', fontWeight: 600, color: '#000', background: '#fff', padding: '2px 8px', borderRadius: '10px' }}>Kaydet</span>
                  </div>
                </div>

                {/* Main Photo Canvas */}
                <div style={{ flex: 1, position: 'relative', overflow: 'hidden', margin: '8px', borderRadius: '16px' }}>
                  <img
                    src={activeBg}
                    alt="Photon Live Preview"
                    style={{
                      width: '100%',
                      height: '100%',
                      objectFit: 'cover',
                      filter: getImageFilter(),
                      transition: 'filter 0.4s ease, transform 0.4s ease',
                    }}
                  />

                  {/* Active Tool Badge */}
                  <div
                    style={{
                      position: 'absolute',
                      top: '12px',
                      right: '12px',
                      background: 'rgba(0, 0, 0, 0.7)',
                      backdropFilter: 'blur(8px)',
                      padding: '4px 10px',
                      borderRadius: '20px',
                      fontSize: '10px',
                      fontWeight: 600,
                      color: 'var(--accent-cyan)',
                      border: '1px solid rgba(255, 255, 255, 0.15)',
                    }}
                  >
                    {activeTab === 'light' && 'IŞIK • +0.65 EV'}
                    {activeTab === 'color' && 'RENK • 6800K'}
                    {activeTab === 'cinematic' && 'SİNEMA LOOK • %100'}
                    {activeTab === 'mono' && 'YÜKSEK KONTRAST S&B'}
                  </div>

                  {/* Sample Photo Switcher */}
                  <div
                    style={{
                      position: 'absolute',
                      bottom: '12px',
                      left: '50%',
                      transform: 'translateX(-50%)',
                      display: 'flex',
                      gap: '6px',
                      background: 'rgba(0, 0, 0, 0.65)',
                      padding: '4px',
                      borderRadius: '20px',
                      backdropFilter: 'blur(8px)',
                    }}
                  >
                    {[
                      { src: '/assets/cinema.jpg', label: 'Sinema' },
                      { src: '/assets/nature.jpg', label: 'Doğa' },
                      { src: '/assets/urban.jpg', label: 'Şehir' },
                      { src: '/assets/portrait_sample.jpg', label: 'Portre' },
                    ].map((item, idx) => (
                      <button
                        key={idx}
                        onClick={() => setActiveBg(item.src)}
                        style={{
                          background: activeBg === item.src ? '#ffffff' : 'transparent',
                          color: activeBg === item.src ? '#000000' : '#ffffff',
                          border: 'none',
                          padding: '3px 8px',
                          borderRadius: '12px',
                          fontSize: '10px',
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

                {/* Simulated Bottom Interactive Tool Strip */}
                <div
                  style={{
                    background: 'rgba(18, 18, 24, 0.95)',
                    borderTop: '1px solid rgba(255, 255, 255, 0.08)',
                    padding: '12px 10px 24px 10px',
                  }}
                >
                  <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: '6px' }}>
                    {[
                      { id: 'light', label: 'Işık', icon: Sun },
                      { id: 'color', label: 'Renk', icon: Palette },
                      { id: 'cinematic', label: 'Sinematik', icon: Film },
                      { id: 'mono', label: 'Siyah & Beyaz', icon: CircleDot },
                    ].map((tab) => {
                      const Icon = tab.icon;
                      const isSelected = activeTab === tab.id;
                      return (
                        <button
                          key={tab.id}
                          onClick={() => setActiveTab(tab.id as any)}
                          style={{
                            background: isSelected ? 'rgba(255, 255, 255, 0.15)' : 'transparent',
                            border: isSelected ? '1px solid rgba(255, 255, 255, 0.3)' : '1px solid transparent',
                            borderRadius: '12px',
                            padding: '8px 4px',
                            display: 'flex',
                            flexDirection: 'column',
                            alignItems: 'center',
                            gap: '4px',
                            color: isSelected ? '#ffffff' : 'var(--text-secondary)',
                            cursor: 'pointer',
                            transition: 'all 0.2s',
                          }}
                        >
                          <Icon size={16} color={isSelected ? 'var(--accent-cyan)' : 'currentColor'} />
                          <span style={{ fontSize: '10px', fontWeight: isSelected ? 700 : 500 }}>{tab.label}</span>
                        </button>
                      );
                    })}
                  </div>
                </div>

              </div>
            </div>
          </div>

        </div>
      </div>

      <style>{`
        @media (max-width: 960px) {
          .hero-grid {
            grid-template-columns: 1fr !important;
            gap: 40px !important;
            text-align: center;
          }
          .hero-grid > div:first-child {
            align-items: center;
          }
          .hero-grid p {
            margin: 0 auto;
          }
        }
      `}</style>
    </section>
  );
};
