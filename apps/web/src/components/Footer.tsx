import React from 'react';
import { Smartphone, Heart } from 'lucide-react';

export const Footer: React.FC = () => {
  return (
    <footer
      style={{
        background: '#060608',
        borderTop: '1px solid rgba(255, 255, 255, 0.08)',
        padding: '50px 0 32px 0',
      }}
    >
      <div className="container">
        <div
          style={{
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'space-between',
            flexWrap: 'wrap',
            gap: '20px',
            marginBottom: '32px',
          }}
        >
          {/* Brand */}
          <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
            <img
              src="/assets/logo.png"
              alt="Photon Logo"
              style={{
                width: '30px',
                height: '30px',
                borderRadius: '6px',
                objectFit: 'contain',
                flexShrink: 0,
              }}
            />
            <span style={{ fontFamily: 'var(--font-display)', fontWeight: 800, fontSize: '18px', letterSpacing: '2px', color: '#ffffff' }}>
              PHOTON
            </span>
          </div>

          {/* Slogan */}
          <div style={{ fontSize: '13px', color: 'var(--text-muted)' }}>
            Işık • Sinematik • Siyah & Beyaz — Native Mobil Fotoğraf Editörü
          </div>

          {/* Download Link */}
          <div>
            <a
              href="#pricing"
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
              <Smartphone size={16} />
              <span>iOS & Android</span>
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
            gap: '12px',
            paddingTop: '20px',
            borderTop: '1px solid rgba(255, 255, 255, 0.05)',
            fontSize: '12px',
            color: 'var(--text-muted)',
          }}
        >
          <div>
            © 2026 Photon. Tüm hakları saklıdır. Swift & Kotlin native mimari.
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
