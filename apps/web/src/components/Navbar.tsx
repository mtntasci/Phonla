import React, { useState, useEffect } from 'react';
import { Smartphone, Menu, X } from 'lucide-react';

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
        {/* Brand Logo */}
        <a href="#" style={{ display: 'flex', alignItems: 'center', gap: '10px', textDecoration: 'none' }}>
          <div
            style={{
              width: '36px',
              height: '36px',
              borderRadius: '10px',
              background: 'linear-gradient(135deg, #181822 0%, #282836 100%)',
              border: '1px solid rgba(255, 255, 255, 0.15)',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              boxShadow: '0 4px 12px rgba(0, 0, 0, 0.4)',
              flexShrink: 0,
            }}
          >
            <svg width="20" height="20" viewBox="0 0 100 100" fill="none">
              <circle cx="50" cy="50" r="42" stroke="white" strokeWidth="6" opacity="0.9" />
              <circle cx="50" cy="50" r="22" stroke="var(--accent-cyan)" strokeWidth="6" />
              <path d="M50 8 L50 28" stroke="white" strokeWidth="5" strokeLinecap="round" />
              <path d="M50 72 L50 92" stroke="white" strokeWidth="5" strokeLinecap="round" />
              <path d="M8 50 L28 50" stroke="white" strokeWidth="5" strokeLinecap="round" />
              <path d="M72 50 L92 50" stroke="white" strokeWidth="5" strokeLinecap="round" />
            </svg>
          </div>
          <div style={{ display: 'flex', flexDirection: 'column' }}>
            <span style={{ fontFamily: 'var(--font-display)', fontWeight: 800, fontSize: '18px', letterSpacing: '2.5px', color: '#ffffff' }}>
              PHOTON
            </span>
            <span style={{ fontSize: '9px', color: 'var(--accent-cyan)', letterSpacing: '1px', textTransform: 'uppercase', fontWeight: 600 }}>
              iOS & Android Native
            </span>
          </div>
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
