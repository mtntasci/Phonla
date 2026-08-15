import React, { useEffect } from 'react';
import { ArrowLeft, ShieldCheck, Lock, Cpu, EyeOff, UserX, Database, Mail } from 'lucide-react';
import { PhotonLogo } from './PhotonLogo';

interface PrivacyPolicyProps {
  onBack: () => void;
}

export const PrivacyPolicy: React.FC<PrivacyPolicyProps> = ({ onBack }) => {
  useEffect(() => {
    window.scrollTo(0, 0);
  }, []);

  return (
    <div style={{ minHeight: '100vh', background: '#090a0f', color: '#ffffff', paddingBottom: '80px' }}>
      {/* Header */}
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
            <span>Ana Sayfaya Dön</span>
          </button>

          <PhotonLogo size={24} showText={true} />
        </div>
      </header>

      {/* Main Content */}
      <div className="container" style={{ maxWidth: '800px', margin: '48px auto 0 auto', padding: '0 20px' }}>
        {/* Title */}
        <div style={{ marginBottom: '40px', textAlign: 'center' }}>
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
            <ShieldCheck size={14} color="#10b981" />
            <span>Gizlilik ve Veri Güvenliği</span>
          </div>
          <h1 style={{ fontSize: '36px', fontWeight: 800, letterSpacing: '-0.02em', marginBottom: '12px' }}>
            Phonla Gizlilik Politikası
          </h1>
          <p style={{ color: '#8e95a5', fontSize: '14px' }}>
            Son Güncelleme: 15 Ağustos 2026 • Yürürlük Tarihi: 15 Ağustos 2026
          </p>
        </div>

        {/* Core Principles Grid */}
        <div
          style={{
            display: 'grid',
            gridTemplateColumns: 'repeat(auto-fit, minmax(220px, 1fr))',
            gap: '16px',
            marginBottom: '48px',
          }}
        >
          <div
            style={{
              background: 'rgba(255, 255, 255, 0.03)',
              border: '1px solid rgba(255, 255, 255, 0.08)',
              borderRadius: '16px',
              padding: '20px',
            }}
          >
            <Cpu size={24} color="#3b82f6" style={{ marginBottom: '12px' }} />
            <h3 style={{ fontSize: '15px', fontWeight: 600, marginBottom: '6px' }}>%100 Cihaz Üzerinde İşleme</h3>
            <p style={{ fontSize: '13px', color: '#8e95a5', lineHeight: 1.5 }}>
              Fotoğraflarınız sunucularımıza yüklenmez; tüm düzenlemeler doğrudan telefonunuzun GPU/Metal motorunda gerçekleşir.
            </p>
          </div>

          <div
            style={{
              background: 'rgba(255, 255, 255, 0.03)',
              border: '1px solid rgba(255, 255, 255, 0.08)',
              borderRadius: '16px',
              padding: '20px',
            }}
          >
            <EyeOff size={24} color="#10b981" style={{ marginBottom: '12px' }} />
            <h3 style={{ fontSize: '15px', fontWeight: 600, marginBottom: '6px' }}>Sıfır Görsel İzleme</h3>
            <p style={{ fontSize: '13px', color: '#8e95a5', lineHeight: 1.5 }}>
              Düzenlediğiniz veya dışa aktardığınız fotoğraflar reklam ağları veya 3. parti şirketlerle asla paylaşılmaz.
            </p>
          </div>

          <div
            style={{
              background: 'rgba(255, 255, 255, 0.03)',
              border: '1px solid rgba(255, 255, 255, 0.08)',
              borderRadius: '16px',
              padding: '20px',
            }}
          >
            <UserX size={24} color="#ef4444" style={{ marginBottom: '12px' }} />
            <h3 style={{ fontSize: '15px', fontWeight: 600, marginBottom: '6px' }}>Kalıcı Hesap Silme</h3>
            <p style={{ fontSize: '13px', color: '#8e95a5', lineHeight: 1.5 }}>
              Uygulama içerisinden tek dokunuşla Firebase hesabınızı ve oturum verilerinizi kalıcı olarak silebilirsiniz.
            </p>
          </div>
        </div>

        {/* Detailed Sections */}
        <div style={{ display: 'flex', flexDirection: 'column', gap: '32px', lineHeight: 1.7, fontSize: '14px', color: '#cbd5e1' }}>
          <section>
            <h2 style={{ fontSize: '20px', fontWeight: 700, color: '#ffffff', marginBottom: '12px', display: 'flex', alignItems: 'center', gap: '10px' }}>
              <Lock size={18} color="#60a5fa" />
              1. Toplanan Veriler ve Kullanım Amaçları
            </h2>
            <p>
              <strong>Phonla</strong> (&quot;Uygulama&quot;), kullanıcı gizliliğini temel tasarım prensibi olarak kabul eder. Uygulamayı kullandığınızda aşağıdaki sınırlı veriler işlenebilir:
            </p>
            <ul style={{ paddingLeft: '20px', marginTop: '8px' }}>
              <li>
                <strong>Kimlik Doğrulama Bilgileri:</strong> Apple Sign-In veya Google Sign-In ile giriş yaptığınızda sağlanan ad-soyad, e-posta adresi ve benzersiz kullanıcı kimliği (UID). Bu veriler yalnızca oturumunuzu yönetmek ve abonelik durumunuzu eşleştirmek için Firebase Authentication altyapısında güvenle saklanır.
              </li>
              <li>
                <strong>Fotoğraf Verileri:</strong> Düzenlemek için seçtiğiniz fotoğraflar yalnızca cihazınızın geçici belleğinde (RAM) işlenir. <u>Fotoğraflarınız hiçbir sunucuya yüklenmez, kaydedilmez veya analiz edilmez.</u>
              </li>
              <li>
                <strong>Abonelik ve Satın Alma Verileri:</strong> Phonla Pro abonelikleri Apple StoreKit 2 altyapısı üzerinden güvenle işlenir. Ödeme ve kredi kartı bilgileriniz doğrudan Apple tarafından yönetilir ve Phonla sunucularına asla ulaşmaz.
              </li>
            </ul>
          </section>

          <section>
            <h2 style={{ fontSize: '20px', fontWeight: 700, color: '#ffffff', marginBottom: '12px', display: 'flex', alignItems: 'center', gap: '10px' }}>
              <Database size={18} color="#60a5fa" />
              2. Üçüncü Taraf Servisler ve SDK&apos;lar
            </h2>
            <p>
              Phonla, uygulamanın temel işlevlerini sağlamak amacıyla yalnızca aşağıdaki güvenilir servis sağlayıcıları kullanır:
            </p>
            <ul style={{ paddingLeft: '20px', marginTop: '8px' }}>
              <li>
                <strong>Google Firebase Authentication:</strong> Güvenli oturum açma, jeton yönetimi ve kullanıcı hesap altyapısı.
              </li>
              <li>
                <strong>Google AdMob (Rewarded Ads):</strong> Free (Ücretsiz) kullanıcılarımızın dışa aktarma öncesi ödüllü reklam izleyebilmesi için kullanılır. Reklam servisinde çocuk koruma (COPPA) ve muhafazakar gizlilik ayarları aktiftir. Fotoğraflarınız veya kişisel görselleriniz asla reklam SDK&apos;sına iletilmez.
              </li>
              <li>
                <strong>Apple StoreKit:</strong> Uygulama içi abonelik ve satın alma yönetimi.
              </li>
            </ul>
          </section>

          <section>
            <h2 style={{ fontSize: '20px', fontWeight: 700, color: '#ffffff', marginBottom: '12px', display: 'flex', alignItems: 'center', gap: '10px' }}>
              <UserX size={18} color="#60a5fa" />
              3. Veri Saklama ve Hesap Silme Hakları
            </h2>
            <p>
              Kullanıcılar diledikleri zaman uygulamamız içerisindeki <strong>Profil &amp; Ayarlar &gt; Hesabımı Sil</strong> seçeneğini kullanarak Firebase Authentication hesaplarını ve tüm yerel oturum verilerini anında ve kalıcı olarak silebilirler.
            </p>
          </section>

          <section>
            <h2 style={{ fontSize: '20px', fontWeight: 700, color: '#ffffff', marginBottom: '12px', display: 'flex', alignItems: 'center', gap: '10px' }}>
              <Mail size={18} color="#60a5fa" />
              4. İletişim
            </h2>
            <p>
              Gizlilik politikamız veya veri haklarınız ile ilgili her türlü soru, öneri veya talepleriniz için bizimle iletişime geçebilirsiniz:
            </p>
            <p style={{ marginTop: '8px' }}>
              <strong>E-posta:</strong> <a href="mailto:destek@phonla.app" style={{ color: '#60a5fa', textDecoration: 'none' }}>destek@phonla.app</a>
            </p>
          </section>
        </div>
      </div>
    </div>
  );
};
