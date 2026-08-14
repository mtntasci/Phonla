import React, { useState, useEffect } from 'react';
import { Smartphone, Menu, X } from 'lucide-react';
import { PhotonLogo } from './PhotonLogo';

export const Navbar: React.FC = () => {
  const [isScrolled, setIsScrolled] = useState(false);
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);

  useEffect(() => {
    const handleScroll = () => {
      setIsScrolled(window.scrollY > 20);
    };
    window.addEventListener('scroll', handleScroll);
    return () => window.removeEventListener('scroll', handleScroll);
  }, []);

  return (
    <header
      style={{
        position: 'fixed',
        top: 0,
        left: 0,
        right: 0,
        zIndex: 1000,
        padding: isScrolled ? '12px 0' : '18px 0',
        transition: 'all 0.3s ease',
        background: isScrolled ? 'rgba(8, 8, 10, 0.88)' : 'transparent',
        backdropFilter: isScrolled ? 'blur(20px)' : 'none',
        WebkitBackdropFilter: isScrolled ? 'blur(20px)' : 'none',
        borderBottom: isScrolled ? '1px solid rgba(255, 255, 255, 0.08)' : 'none',
      }}
    >
      <div className="container" style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        {/* Brand Official App Icon & Title */}
        <a href="#" style={{ textDecoration: 'none' }}>
          <PhotonLogo size={36} showText={true} variant="app-icon" />
        </a>

        {/* Desktop Nav Links */}
        <nav
          style={{
            display: 'flex',
            alignItems: 'center',
            gap: '28px',
          }}
          className="desktop-nav"
        >
          <a href="#features" style={{ color: 'var(--text-secondary)', textDecoration: 'none', fontSize: '14px', fontWeight: 500, transition: 'color 0.2s' }}>
            Özellikler
          </a>
          <a href="#comparison" style={{ color: 'var(--text-secondary)', textDecoration: 'none', fontSize: '14px', fontWeight: 500, transition: 'color 0.2s' }}>
            Kıyaslama Stüdyosu
          </a>
          <a href="#simulator" style={{ color: 'var(--text-secondary)', textDecoration: 'none', fontSize: '14px', fontWeight: 500, transition: 'color 0.2s' }}>
            Canlı Simülatör
          </a>
          <a href="#presets" style={{ color: 'var(--text-secondary)', textDecoration: 'none', fontSize: '14px', fontWeight: 500, transition: 'color 0.2s' }}>
            Presetler
          </a>
          <a href="#privacy" style={{ color: 'var(--text-secondary)', textDecoration: 'none', fontSize: '14px', fontWeight: 500, transition: 'color 0.2s' }}>
            Gizlilik & Donanım
          </a>
          <a href="#pricing" style={{ color: 'var(--text-secondary)', textDecoration: 'none', fontSize: '14px', fontWeight: 500, transition: 'color 0.2s' }}>
            Üyelikler
          </a>
        </nav>

        {/* Action CTA */}
        <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
          <a
            href="#pricing"
            className="btn btn-primary"
            style={{ padding: '8px 18px', fontSize: '13px' }}
          >
            <Smartphone size={15} />
            <span>Hemen İndir</span>
          </a>

          {/* Mobile Menu Toggle */}
          <button
            onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
            style={{
              background: 'transparent',
              border: 'none',
              color: '#ffffff',
              display: 'none',
              cursor: 'pointer',
              padding: '6px',
            }}
            className="mobile-toggle"
            aria-label="Menüyü Aç"
          >
            {mobileMenuOpen ? <X size={24} /> : <Menu size={24} />}
          </button>
        </div>
      </div>

      {/* Mobile Menu Overlay */}
      {mobileMenuOpen && (
        <div
          style={{
            position: 'absolute',
            top: '100%',
            left: 0,
            right: 0,
            background: 'rgba(10, 10, 14, 0.98)',
            backdropFilter: 'blur(20px)',
            WebkitBackdropFilter: 'blur(20px)',
            borderBottom: '1px solid rgba(255, 255, 255, 0.1)',
            padding: '24px 20px',
            display: 'flex',
            flexDirection: 'column',
            gap: '16px',
          }}
        >
          <a
            href="#features"
            onClick={() => setMobileMenuOpen(false)}
            style={{ color: '#ffffff', textDecoration: 'none', fontSize: '15px', fontWeight: 500 }}
          >
            Özellikler
          </a>
          <a
            href="#comparison"
            onClick={() => setMobileMenuOpen(false)}
            style={{ color: '#ffffff', textDecoration: 'none', fontSize: '15px', fontWeight: 500 }}
          >
            Kıyaslama Stüdyosu
          </a>
          <a
            href="#simulator"
            onClick={() => setMobileMenuOpen(false)}
            style={{ color: '#ffffff', textDecoration: 'none', fontSize: '15px', fontWeight: 500 }}
          >
            Canlı Simülatör
          </a>
          <a
            href="#presets"
            onClick={() => setMobileMenuOpen(false)}
            style={{ color: '#ffffff', textDecoration: 'none', fontSize: '15px', fontWeight: 500 }}
          >
            Presetler
          </a>
          <a
            href="#privacy"
            onClick={() => setMobileMenuOpen(false)}
            style={{ color: '#ffffff', textDecoration: 'none', fontSize: '15px', fontWeight: 500 }}
          >
            Gizlilik & Donanım
          </a>
          <a
            href="#pricing"
            onClick={() => setMobileMenuOpen(false)}
            style={{ color: '#ffffff', textDecoration: 'none', fontSize: '15px', fontWeight: 500 }}
          >
            Üyelikler
          </a>
        </div>
      )}

      <style>{`
        @media (max-width: 900px) {
          .desktop-nav { display: none !important; }
          .mobile-toggle { display: block !important; }
        }
      `}</style>
    </header>
  );
};
