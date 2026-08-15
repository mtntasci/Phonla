import React from 'react';
import { Check, Sparkles, Crown, Smartphone } from 'lucide-react';

export const PricingSection: React.FC = () => {
  return (
    <section id="pricing" style={{ padding: '80px 0', background: 'rgba(12, 12, 16, 0.5)' }}>
      <div className="container">
        
        {/* Header */}
        <div style={{ textAlign: 'center', marginBottom: '48px' }}>
          <div className="badge-pill badge-pill-cyan" style={{ marginBottom: '14px' }}>
            <Crown size={14} />
            <span>Şeffaf Model</span>
          </div>
          <h2 style={{ fontSize: 'clamp(28px, 4vw, 44px)', marginBottom: '14px' }}>
            Phonla <span className="gradient-text">Üyelik Planları</span>
          </h2>
          <p style={{ color: 'var(--text-secondary)', fontSize: '15px', maxWidth: '580px', margin: '0 auto' }}>
            Temel profesyonel fotoğraf düzenleme araçları her zaman ücretsiz.
          </p>
        </div>

        {/* Pricing Cards Grid */}
        <div
          style={{
            display: 'grid',
            gridTemplateColumns: 'repeat(auto-fit, minmax(280px, 1fr))',
            gap: '24px',
            maxWidth: '860px',
            margin: '0 auto',
            alignItems: 'stretch',
          }}
        >
          {/* Free Tier */}
          <div
            className="glass-card"
            style={{
              padding: 'clamp(24px, 5vw, 36px) clamp(20px, 4vw, 28px)',
              display: 'flex',
              flexDirection: 'column',
              justifyContent: 'space-between',
              border: '1px solid rgba(255, 255, 255, 0.12)',
            }}
          >
            <div>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '10px' }}>
                <h3 style={{ fontSize: '22px', color: '#ffffff' }}>Phonla Standart</h3>
                <span
                  style={{
                    background: 'rgba(255, 255, 255, 0.1)',
                    padding: '3px 10px',
                    borderRadius: 'var(--radius-full)',
                    fontSize: '11px',
                    fontWeight: 600,
                    color: '#ffffff',
                  }}
                >
                  Mevcut Plan
                </span>
              </div>

              <p style={{ fontSize: '13px', color: 'var(--text-secondary)', marginBottom: '20px' }}>
                Her fotoğraf meraklısı için eksiksiz ve güçlü native düzenleme paketi.
              </p>

              <div style={{ fontSize: '32px', fontWeight: 800, color: '#ffffff', marginBottom: '24px' }}>
                Ücretsiz
              </div>

              <div style={{ display: 'flex', flexDirection: 'column', gap: '12px', marginBottom: '28px' }}>
                {[
                  'Işık & Renk ayarları (Pozlama, Sıcaklık vb.)',
                  '9 Adet Küratörlü Sinematik Görünüm Preseti',
                  '6 Adet Profesyonel Monochrome Önayarı',
                  'Tam çözünürlüklü kayıpsız dışa aktarma',
                  'GPU ile 60 FPS akıcı canlı önizleme',
                  '%100 On-Device cihaz üzerinde gizlilik',
                ].map((feature, i) => (
                  <div key={i} style={{ display: 'flex', alignItems: 'center', gap: '8px', fontSize: '13px', color: 'var(--text-secondary)' }}>
                    <Check size={15} color="var(--accent-cyan)" style={{ flexShrink: 0 }} />
                    <span>{feature}</span>
                  </div>
                ))}
              </div>
            </div>

            <a
              href="#pricing"
              className="btn btn-secondary"
              style={{ width: '100%' }}
            >
              <Smartphone size={15} />
              <span>Hemen Kullanmaya Başla</span>
            </a>
          </div>

          {/* Pro Tier (Upcoming) */}
          <div
            style={{
              padding: 'clamp(24px, 5vw, 36px) clamp(20px, 4vw, 28px)',
              display: 'flex',
              flexDirection: 'column',
              justifyContent: 'space-between',
              background: 'linear-gradient(135deg, #181822 0%, #0d0d12 100%)',
              borderRadius: 'var(--radius-md)',
              border: '1px solid rgba(0, 240, 255, 0.4)',
              boxShadow: '0 20px 50px rgba(0, 240, 255, 0.15)',
              position: 'relative',
              overflow: 'hidden',
            }}
          >
            {/* Top Glow Ribbon */}
            <div
              style={{
                position: 'absolute',
                top: 0,
                right: 0,
                left: 0,
                height: '4px',
                background: 'linear-gradient(90deg, var(--accent-cyan), var(--accent-amber))',
              }}
            />

            <div>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '10px' }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
                  <h3 style={{ fontSize: '22px', color: '#ffffff' }}>Phonla Pro</h3>
                  <Sparkles size={16} color="var(--accent-amber)" />
                </div>
                <span
                  style={{
                    background: 'var(--accent-amber)',
                    color: '#000000',
                    padding: '3px 10px',
                    borderRadius: 'var(--radius-full)',
                    fontSize: '11px',
                    fontWeight: 700,
                  }}
                >
                  Yakında
                </span>
              </div>

              <p style={{ fontSize: '13px', color: 'var(--text-secondary)', marginBottom: '20px' }}>
                Yakında: AI Otomatik Düzenleme ve gelişmiş özellikler
              </p>

              <div style={{ fontSize: '32px', fontWeight: 800, color: 'var(--accent-cyan)', marginBottom: '24px' }}>
                Yakında
              </div>

              <div style={{ display: 'flex', flexDirection: 'column', gap: '12px', marginBottom: '28px' }}>
                {[
                  'Yapay Zeka ile Otomatik Renk Dengesi & İyileştirme',
                  'Özel 3D LUT ve Film Emülasyonu Desteği',
                  'Gelişmiş RGB Ton Eğrileri (Tone Curves)',
                  'Bölgesel Maskeleme & Seçici Düzenleme Fırçaları',
                  'Yeni Özelliklere ve Presetlere Öncelikli Erişim',
                ].map((feature, i) => (
                  <div key={i} style={{ display: 'flex', alignItems: 'center', gap: '8px', fontSize: '13px', color: '#ffffff' }}>
                    <Check size={15} color="var(--accent-amber)" style={{ flexShrink: 0 }} />
                    <span>{feature}</span>
                  </div>
                ))}
              </div>
            </div>

            <button
              disabled
              className="btn"
              style={{
                width: '100%',
                background: 'rgba(255, 255, 255, 0.1)',
                color: 'var(--text-muted)',
                cursor: 'not-allowed',
              }}
            >
              Çok Yakında Yayında
            </button>
          </div>

        </div>

      </div>
    </section>
  );
};
