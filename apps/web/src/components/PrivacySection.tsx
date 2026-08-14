import React, { useState, useRef } from 'react';
import { Lock, Cpu, EyeOff, CheckCircle2, Heart } from 'lucide-react';
import confetti from 'canvas-confetti';

export const PrivacySection: React.FC = () => {
  const [tapCount, setTapCount] = useState<number>(0);
  const [lastTapTime, setLastTapTime] = useState<number>(0);
  const [showEasterEgg, setShowEasterEgg] = useState<boolean>(false);
  const timerRef = useRef<number | null>(null);

  const triggerEasterEgg = () => {
    // Fire festive confetti
    confetti({
      particleCount: 80,
      spread: 70,
      origin: { y: 0.8 },
      colors: ['#ff4d6d', '#ff758f', '#00f0ff', '#ffffff'],
    });

    if (timerRef.current) clearTimeout(timerRef.current);
    setShowEasterEgg(true);

    timerRef.current = window.setTimeout(() => {
      setShowEasterEgg(false);
    }, 10000);
  };

  const handleCardClick = () => {
    const now = Date.now();
    if (now - lastTapTime < 1500) {
      const nextCount = tapCount + 1;
      setTapCount(nextCount);
      if (nextCount >= 3) {
        setTapCount(0);
        triggerEasterEgg();
      }
    } else {
      setTapCount(1);
    }
    setLastTapTime(now);
  };

  return (
    <section id="privacy" style={{ padding: '100px 0', position: 'relative' }}>
      <div className="container">
        
        {/* Main Card with 3-Tap Easter Egg Trigger */}
        <div
          onClick={handleCardClick}
          className="glass-panel"
          style={{
            padding: '56px 48px',
            background: 'linear-gradient(135deg, rgba(16, 16, 22, 0.9) 0%, rgba(24, 24, 34, 0.7) 100%)',
            border: '1px solid rgba(255, 255, 255, 0.12)',
            boxShadow: '0 20px 60px rgba(0, 0, 0, 0.6)',
            cursor: 'pointer',
            position: 'relative',
            overflow: 'hidden',
          }}
        >
          {/* Subtle Ambient Shield Glow */}
          <div
            style={{
              position: 'absolute',
              top: '-50px',
              right: '-50px',
              width: '300px',
              height: '300px',
              background: 'radial-gradient(circle, rgba(16, 185, 129, 0.12) 0%, transparent 70%)',
              filter: 'blur(50px)',
              pointerEvents: 'none',
            }}
          />

          <div style={{ maxWidth: '800px', margin: '0 auto', textAlign: 'center' }}>
            
            <div
              style={{
                width: '64px',
                height: '64px',
                borderRadius: '20px',
                background: 'rgba(16, 185, 129, 0.12)',
                border: '1px solid rgba(16, 185, 129, 0.3)',
                display: 'inline-flex',
                alignItems: 'center',
                justifyContent: 'center',
                marginBottom: '24px',
              }}
            >
              <Lock size={30} color="#10b981" />
            </div>

            <h2 style={{ fontSize: 'clamp(28px, 4vw, 42px)', marginBottom: '16px' }}>
              Gizlilik ve <span className="gradient-text-cyan">Donanım Hızlandırma</span>
            </h2>

            <p style={{ color: 'var(--text-secondary)', fontSize: '16px', lineHeight: 1.7, marginBottom: '40px' }}>
              Fotoğraflarınız yalnızca size aittir. Photon, tüm düzenleme ve renk hesaplama işlemlerini doğrudan iPhone'unuzun Metal GPU donanımı üzerinde yerel olarak gerçekleştirir.
            </p>

            {/* 3 Pillars */}
            <div
              style={{
                display: 'grid',
                gridTemplateColumns: 'repeat(auto-fit, minmax(220px, 1fr))',
                gap: '24px',
                textAlign: 'left',
              }}
            >
              <div
                style={{
                  background: 'rgba(255, 255, 255, 0.04)',
                  padding: '24px',
                  borderRadius: '16px',
                  border: '1px solid rgba(255, 255, 255, 0.08)',
                }}
              >
                <CheckCircle2 size={20} color="#10b981" style={{ marginBottom: '12px' }} />
                <h4 style={{ fontSize: '16px', color: '#ffffff', marginBottom: '6px' }}>On-Device İşleme</h4>
                <p style={{ fontSize: '13px', color: 'var(--text-secondary)', lineHeight: 1.5 }}>
                  Fotoğraflar doğrudan cihaz üzerinde işlenir ve geçici bellek dışında asla tutulmaz.
                </p>
              </div>

              <div
                style={{
                  background: 'rgba(255, 255, 255, 0.04)',
                  padding: '24px',
                  borderRadius: '16px',
                  border: '1px solid rgba(255, 255, 255, 0.08)',
                }}
              >
                <EyeOff size={20} color="var(--accent-cyan)" style={{ marginBottom: '12px' }} />
                <h4 style={{ fontSize: '16px', color: '#ffffff', marginBottom: '6px' }}>Sıfır Bulut Transferi</h4>
                <p style={{ fontSize: '13px', color: 'var(--text-secondary)', lineHeight: 1.5 }}>
                  Fotoğraflar hiçbir sunucuya yüklenmez ve 3. parti yapay zeka servislerine gönderilmez.
                </p>
              </div>

              <div
                style={{
                  background: 'rgba(255, 255, 255, 0.04)',
                  padding: '24px',
                  borderRadius: '16px',
                  border: '1px solid rgba(255, 255, 255, 0.08)',
                }}
              >
                <Cpu size={20} color="var(--accent-amber)" style={{ marginBottom: '12px' }} />
                <h4 style={{ fontSize: '16px', color: '#ffffff', marginBottom: '6px' }}>Metal GPU Gücü</h4>
                <p style={{ fontSize: '13px', color: 'var(--text-secondary)', lineHeight: 1.5 }}>
                  Apple Metal donanım hızlandırmalı GPU görüntü motoruyla anlık 60 FPS performans.
                </p>
              </div>
            </div>

            {/* Tap Hint */}
            <div style={{ marginTop: '28px', fontSize: '12px', color: 'var(--text-muted)' }}>
              🔒 Güvenli, Bağımsız ve Tamamen Yerel Mimari
            </div>

          </div>
        </div>

      </div>

      {/* Floating Easter Egg Banner */}
      {showEasterEgg && (
        <div className="easter-egg-toast">
          <Heart size={20} color="#ff4d6d" fill="#ff4d6d" />
          <span style={{ fontSize: '15px', fontWeight: 600, color: '#ffffff' }}>
            Bu uygulama Gurbet için Metin tarafından aşkla yapıldı ❤️
          </span>
        </div>
      )}
    </section>
  );
};
