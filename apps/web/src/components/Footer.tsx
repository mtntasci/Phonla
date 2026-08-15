import React from 'react';
import { Smartphone, Heart, Shield } from 'lucide-react';
import { PhotonLogo } from './PhotonLogo';

interface FooterProps {
  onPrivacyClick?: () => void;
  onUserPrivacyClick?: () => void;
}

export const Footer: React.FC<FooterProps> = ({ onPrivacyClick, onUserPrivacyClick }) => {
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
          <PhotonLogo size={28} showText={true} />

          {/* Slogan */}
          <div style={{ fontSize: '13px', color: 'var(--text-muted)' }}>
            Işık • Sinematik • Siyah & Beyaz — Native Mobil Fotoğraf Editörü
          </div>

          {/* Navigation Links */}
          <div style={{ display: 'flex', alignItems: 'center', flexWrap: 'wrap', gap: '20px' }}>
            <button
              onClick={onPrivacyClick}
              style={{
                background: 'transparent',
                border: 'none',
                color: '#a0a5b5',
                fontSize: '13px',
                fontWeight: 500,
                display: 'flex',
                alignItems: 'center',
                gap: '6px',
                cursor: 'pointer',
                padding: 0,
                transition: 'color 0.2s ease',
              }}
              onMouseEnter={(e) => (e.currentTarget.style.color = '#ffffff')}
              onMouseLeave={(e) => (e.currentTarget.style.color = '#a0a5b5')}
            >
              <Shield size={15} />
              <span>Privacy Policy</span>
            </button>

            <button
              onClick={onUserPrivacyClick}
              style={{
                background: 'transparent',
                border: 'none',
                color: '#a0a5b5',
                fontSize: '13px',
                fontWeight: 500,
                display: 'flex',
                alignItems: 'center',
                gap: '6px',
                cursor: 'pointer',
                padding: 0,
                transition: 'color 0.2s ease',
              }}
              onMouseEnter={(e) => (e.currentTarget.style.color = '#ffffff')}
              onMouseLeave={(e) => (e.currentTarget.style.color = '#a0a5b5')}
            >
              <Shield size={15} />
              <span>User Privacy</span>
            </button>

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
            © 2026 Photonla. Tüm hakları saklıdır. Swift & Kotlin native mimari.
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

