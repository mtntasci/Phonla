import React, { useState, useRef } from 'react';
import { Lock, Cpu, EyeOff, CheckCircle2, Heart } from 'lucide-react';
import confetti from 'canvas-confetti';

export const PrivacySection: React.FC = () => {
  const [tapCount, setTapCount] = useState<number>(0);
  const [lastTapTime, setLastTapTime] = useState<number>(0);
  const [showEasterEgg, setShowEasterEgg] = useState<boolean>(false);
  const timerRef = useRef<number | null>(null);

  const triggerEasterEgg = () => {
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
    <section id="technology" style={{ padding: '80px 0', position: 'relative' }}>
      <div className="container">
        
        {/* Main Card with 3-Tap Easter Egg Trigger */}
        <div
          onClick={handleCardClick}
          className="glass-panel"
          style={{
            padding: 'clamp(28px, 6vw, 56px) clamp(16px, 4vw, 40px)',
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
              width: 'min(300px, 80vw)',
              height: '300px',
              background: 'radial-gradient(circle, rgba(16, 185, 129, 0.12) 0%, transparent 70%)',
              filter: 'blur(50px)',
              pointerEvents: 'none',
            }}
          />

          <div style={{ maxWidth: '800px', margin: '0 auto', textAlign: 'center' }}>
            
            <div
              style={{
                width: '56px',
                height: '56px',
                borderRadius: '16px',
                background: 'rgba(16, 185, 129, 0.12)',
                border: '1px solid rgba(16, 185, 129, 0.3)',
                display: 'inline-flex',
                alignItems: 'center',
                justifyContent: 'center',
                marginBottom: '20px',
              }}
            >
              <Lock size={26} color="#10b981" />
            </div>

            <h2 style={{ fontSize: 'clamp(24px, 4vw, 38px)', marginBottom: '14px' }}>
              Gizlilik ve <span className="gradient-text-cyan">Donanım Hızlandırma</span>
            </h2>

            <p style={{ color: 'var(--text-secondary)', fontSize: '15px', lineHeight: 1.6, marginBottom: '32px' }}>
              Fotoğraflarınız yalnızca size aittir. Photonla, tüm düzenleme ve renk hesaplama işlemlerini doğrudan mobil cihazınızın yerel GPU donanımı üzerinde gerçekleştirir.
            </p>

            {/* 3 Pillars */}
            <div
              style={{
                display: 'grid',
                gridTemplateColumns: 'repeat(auto-fit, minmax(220px, 1fr))',
                gap: '16px',
                textAlign: 'left',
              }}
            >
              <div
                style={{
                  background: 'rgba(255, 255, 255, 0.04)',
                  padding: '20px 16px',
                  borderRadius: '14px',
                  border: '1px solid rgba(255, 255, 255, 0.08)',
                }}
              >
                <CheckCircle2 size={18} color="#10b981" style={{ marginBottom: '10px' }} />
                <h4 style={{ fontSize: '15px', color: '#ffffff', marginBottom: '4px' }}>On-Device İşleme</h4>
                <p style={{ fontSize: '12px', color: 'var(--text-secondary)', lineHeight: 1.5 }}>
                  Fotoğraflar doğrudan cihaz üzerinde işlenir ve geçici bellek dışında asla tutulmaz.
                </p>
              </div>

              <div
                style={{
                  background: 'rgba(255, 255, 255, 0.04)',
                  padding: '20px 16px',
                  borderRadius: '14px',
                  border: '1px solid rgba(255, 255, 255, 0.08)',
                }}
              >
                <EyeOff size={18} color="var(--accent-cyan)" style={{ marginBottom: '10px' }} />
                <h4 style={{ fontSize: '15px', color: '#ffffff', marginBottom: '4px' }}>Sıfır Bulut Transferi</h4>
                <p style={{ fontSize: '12px', color: 'var(--text-secondary)', lineHeight: 1.5 }}>
                  Fotoğraflar hiçbir sunucuya yüklenmez ve 3. parti servislere gönderilmez.
                </p>
              </div>

              <div
                style={{
                  background: 'rgba(255, 255, 255, 0.04)',
                  padding: '20px 16px',
                  borderRadius: '14px',
                  border: '1px solid rgba(255, 255, 255, 0.08)',
                }}
              >
                <Cpu size={18} color="var(--accent-amber)" style={{ marginBottom: '10px' }} />
                <h4 style={{ fontSize: '15px', color: '#ffffff', marginBottom: '4px' }}>Mobil GPU Gücü</h4>
                <p style={{ fontSize: '12px', color: 'var(--text-secondary)', lineHeight: 1.5 }}>
                  Donanım hızlandırmalı GPU görüntü motoruyla anlık 60 FPS performans.
                </p>
              </div>
            </div>

            {/* Tap Hint */}
            <div style={{ marginTop: '24px', fontSize: '12px', color: 'var(--text-muted)' }}>
              🔒 Güvenli, Bağımsız ve Tamamen Yerel Mimari
            </div>

          </div>
        </div>

      </div>

      {/* Floating Easter Egg Banner */}
      {showEasterEgg && (
        <div className="easter-egg-toast">
          <Heart size={18} color="#ff4d6d" fill="#ff4d6d" style={{ flexShrink: 0 }} />
          <span style={{ fontSize: '13px', fontWeight: 600, color: '#ffffff', lineHeight: 1.4 }}>
            Bu uygulama Gurbet için Metin tarafından aşkla yapıldı ❤️
          </span>
        </div>
      )}
    </section>
  );
};
