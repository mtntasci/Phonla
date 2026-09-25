import React, { useEffect } from 'react';
import { ArrowLeft, LifeBuoy, Mail, HelpCircle } from 'lucide-react';
import { PhotonLogo } from './PhotonLogo';

interface SupportProps {
  onBack: () => void;
}

export const Support: React.FC<SupportProps> = ({ onBack }) => {
  useEffect(() => {
    window.scrollTo(0, 0);
  }, []);

  return (
    <div style={{ minHeight: '100vh', background: '#090a0f', color: '#ffffff', paddingBottom: '80px' }}>
      {/* Top Navigation Bar */}
      <header
        style={{
          borderBottom: '1px solid rgba(255, 255, 255, 0.08)',
          background: 'rgba(9, 10, 15, 0.85)',
          backdropFilter: 'blur(16px)',
          position: 'sticky',
          top: 0,
          zIndex: 50,
          padding: '16px 0',
        }}
      >
        <div className="container" style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
          <button
            onClick={onBack}
            style={{
              display: 'flex',
              alignItems: 'center',
              gap: '8px',
              background: 'rgba(255, 255, 255, 0.06)',
              border: '1px solid rgba(255, 255, 255, 0.12)',
              color: '#ffffff',
              padding: '8px 16px',
              borderRadius: '999px',
              fontSize: '13px',
              fontWeight: 500,
              cursor: 'pointer',
              transition: 'all 0.2s ease',
            }}
          >
            <ArrowLeft size={16} />
            <span>Home</span>
          </button>

          <PhotonLogo size={24} showText={true} />
          
          <div style={{ width: '84px' }} /> {/* Spacer for centering */}
        </div>
      </header>

      {/* Main Document Content */}
      <div className="container" style={{ maxWidth: '820px', margin: '48px auto 0 auto', padding: '0 20px' }}>
        {/* Title Header */}
        <div style={{ marginBottom: '40px' }}>
          <div
            style={{
              display: 'inline-flex',
              alignItems: 'center',
              gap: '8px',
              background: 'rgba(255, 255, 255, 0.05)',
              border: '1px solid rgba(255, 255, 255, 0.1)',
              padding: '6px 14px',
              borderRadius: '999px',
              fontSize: '12px',
              color: '#a0a5b5',
              marginBottom: '16px',
            }}
          >
            <LifeBuoy size={14} color="#3b82f6" />
            <span>Customer Support</span>
          </div>

          <h1 style={{ fontSize: '36px', fontWeight: 800, letterSpacing: '-0.02em', marginBottom: '8px' }}>
            Destek Merkezi
          </h1>
          <p style={{ color: '#8e95a5', fontSize: '14px', marginBottom: '24px' }}>
            Son Güncelleme: 25 Eylül 2026
          </p>
          <p style={{ fontSize: '16px', color: '#cbd5e1', lineHeight: 1.6, borderLeft: '3px solid #3b82f6', paddingLeft: '16px' }}>
            Photon ile ilgili yaşadığınız sorunlarda veya merak ettiğiniz konularda size yardımcı olmaktan mutluluk duyarız.
          </p>
        </div>

        {/* Content Body */}
        <div style={{ display: 'flex', flexDirection: 'column', gap: '32px', lineHeight: 1.7, fontSize: '15px', color: '#cbd5e1' }}>
          
          {/* Section 1 */}
          <section>
            <h2 style={{ display: 'flex', alignItems: 'center', gap: '8px', fontSize: '20px', fontWeight: 700, color: '#ffffff', marginBottom: '12px' }}>
              <HelpCircle size={20} color="#a0a5b5" />
              Sıkça Sorulan Sorular
            </h2>
            
            <div style={{ background: 'rgba(255,255,255,0.03)', padding: '20px', borderRadius: '12px', marginBottom: '16px' }}>
              <h3 style={{ fontSize: '16px', fontWeight: 600, color: '#ffffff', marginBottom: '8px' }}>
                Fotoğraflarım nerede işleniyor?
              </h3>
              <p>
                Gizliliğinize önem veriyoruz. Seçtiğiniz fotoğraflar tamamen cihazınızın işlemcisi ve donanım hızlandırıcısı kullanılarak yerel olarak (cihazınızda) işlenir. Sunucularımıza hiçbir fotoğraf yüklenmez.
              </p>
            </div>

            <div style={{ background: 'rgba(255,255,255,0.03)', padding: '20px', borderRadius: '12px', marginBottom: '16px' }}>
              <h3 style={{ fontSize: '16px', fontWeight: 600, color: '#ffffff', marginBottom: '8px' }}>
                Uygulama içi satın alımlar mevcut mu?
              </h3>
              <p>
                Şu an için tüm temel özelliklerimiz tamamen ücretsizdir.
              </p>
            </div>

            <div style={{ background: 'rgba(255,255,255,0.03)', padding: '20px', borderRadius: '12px', marginBottom: '16px' }}>
              <h3 style={{ fontSize: '16px', fontWeight: 600, color: '#ffffff', marginBottom: '8px' }}>
                Dışa aktarma (Export) sorunu yaşıyorum, ne yapmalıyım?
              </h3>
              <p>
                Lütfen cihazınızın ayarlarından Photon uygulaması için "Fotoğraflara Erişim" izninin verildiğinden emin olun. Fotoğrafları kaydetmek için kütüphanenize erişim gereklidir.
              </p>
            </div>
          </section>

          {/* Section 2 */}
          <section>
            <h2 style={{ display: 'flex', alignItems: 'center', gap: '8px', fontSize: '20px', fontWeight: 700, color: '#ffffff', marginBottom: '12px' }}>
              <Mail size={20} color="#a0a5b5" />
              Bizimle İletişime Geçin
            </h2>
            <p>
              Yukarıdaki sorular dışında teknik bir problem yaşıyorsanız, önerileriniz varsa veya farklı bir konu hakkında yardıma ihtiyacınız varsa bizimle e-posta yoluyla iletişime geçebilirsiniz. Size en kısa sürede geri dönüş yapacağız.
            </p>
            
            <div style={{ 
              marginTop: '16px', 
              padding: '24px', 
              background: 'rgba(59, 130, 246, 0.1)', 
              border: '1px solid rgba(59, 130, 246, 0.2)', 
              borderRadius: '12px',
              display: 'flex',
              flexDirection: 'column',
              alignItems: 'center',
              textAlign: 'center'
            }}>
              <Mail size={32} color="#3b82f6" style={{ marginBottom: '12px' }} />
              <h3 style={{ fontSize: '18px', fontWeight: 600, color: '#ffffff', marginBottom: '8px' }}>
                Destek Ekibi
              </h3>
              <a 
                href="mailto:support@photonla.com" 
                style={{ 
                  color: '#60a5fa', 
                  textDecoration: 'none', 
                  fontWeight: 600, 
                  fontSize: '16px' 
                }}
              >
                support@photonla.com
              </a>
            </div>
          </section>

        </div>
      </div>
    </div>
  );
};
