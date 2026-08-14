import React from 'react';
import { Apple, Heart } from 'lucide-react';

export const Footer: React.FC = () => {
  return (
    <footer
      style={{
        background: '#060608',
        borderTop: '1px solid rgba(255, 255, 255, 0.08)',
        padding: '60px 0 40px 0',
      }}
    >
      <div className="container">
        <div
          style={{
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'space-between',
            flexWrap: 'wrap',
            gap: '24px',
            marginBottom: '40px',
          }}
        >
          {/* Brand */}
          <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
            <div
              style={{
                width: '32px',
                height: '32px',
                borderRadius: '8px',
                background: 'linear-gradient(135deg, #181822 0%, #282836 100%)',
                border: '1px solid rgba(255, 255, 255, 0.15)',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
              }}
            >
              <svg width="18" height="18" viewBox="0 0 100 100" fill="none">
                <circle cx="50" cy="50" r="42" stroke="white" strokeWidth="6" opacity="0.9" />
                <circle cx="50" cy="50" r="22" stroke="var(--accent-cyan)" strokeWidth="6" />
              </svg>
            </div>
            <span style={{ fontFamily: 'var(--font-display)', fontWeight: 800, fontSize: '18px', letterSpacing: '2px', color: '#ffffff' }}>
              PHOTON
            </span>
          </div>

          {/* Slogan */}
          <div style={{ fontSize: '13px', color: 'var(--text-muted)' }}>
            Işık • Sinematik • Siyah & Beyaz — Native iOS Fotoğraf Editörü
          </div>

          {/* Download Link */}
          <div>
            <a
              href="https://apps.apple.com"
              target="_blank"
              rel="noreferrer"
              style={{
                color: '#ffffff',
                textDecoration: 'none',
                fontSize: '13px',
                fontWeight: 600,
                display: 'flex',
                alignItems: 'center',
                gap: '6px',
              }}
            >
              <Apple size={16} />
              <span>App Store</span>
            </a>
          </div>
        </div>

        {/* Bottom Sub-footer */}
        <div
          style={{
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'space-between',
            flexWrap: 'wrap',
            gap: '16px',
            paddingTop: '24px',
            borderTop: '1px solid rgba(255, 255, 255, 0.05)',
            fontSize: '12px',
            color: 'var(--text-muted)',
          }}
        >
          <div>
            © 2026 Photon. Tüm hakları saklıdır. Swift & Metal ile geliştirildi.
          </div>

          <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
            <span>Made with</span>
            <Heart size={12} color="#ff4d6d" fill="#ff4d6d" />
            <span>for pure mobile photography</span>
          </div>
        </div>
      </div>
    </footer>
  );
};
