import React from 'react';

interface PhotonLogoProps {
  size?: number;
  showText?: boolean;
  variant?: 'app-icon' | 'vector';
}

export const PhotonLogo: React.FC<PhotonLogoProps> = ({
  size = 36,
  showText = true,
  variant = 'app-icon',
}) => {
  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: '12px', userSelect: 'none' }}>
      {variant === 'app-icon' ? (
        <img
          src="/assets/app_icon.png"
          alt="Photon App Icon"
          style={{
            width: `${size}px`,
            height: `${size}px`,
            borderRadius: `${size * 0.22}px`,
            objectFit: 'cover',
            flexShrink: 0,
            boxShadow: '0 4px 16px rgba(0, 240, 255, 0.2), 0 2px 8px rgba(0, 0, 0, 0.4)',
            border: '1px solid rgba(255, 255, 255, 0.15)',
          }}
        />
      ) : (
        <svg
          width={size}
          height={size}
          viewBox="0 0 100 100"
          fill="none"
          style={{ flexShrink: 0 }}
        >
          {/* Outer Optical Ring */}
          <circle cx="50" cy="50" r="42" stroke="white" strokeWidth="6" opacity="0.95" />
          
          {/* 6 Aperture Blades */}
          {[0, 60, 120, 180, 240, 300].map((angle, i) => {
            const rad = (angle - 30) * (Math.PI / 180);
            const tanRad = (angle + 56) * (Math.PI / 180);
            const startX = 50 + Math.cos(rad) * 18;
            const startY = 50 + Math.sin(rad) * 18;
            const endX = startX + Math.cos(tanRad) * 39;
            const endY = startY + Math.sin(tanRad) * 39;
            return (
              <line
                key={i}
                x1={startX}
                y1={startY}
                x2={endX}
                y2={endY}
                stroke="white"
                strokeWidth="5"
                strokeLinecap="round"
                opacity="0.9"
              />
            );
          })}
          {/* Central Photon Light Core */}
          <circle cx="50" cy="50" r="7" fill="var(--accent-cyan)" />
        </svg>
      )}

      {showText && (
        <span
          style={{
            fontFamily: 'var(--font-display)',
            fontWeight: 800,
            fontSize: `${Math.max(16, size * 0.52)}px`,
            letterSpacing: '2.5px',
            color: '#ffffff',
            lineHeight: 1,
          }}
        >
          PHOTON
        </span>
      )}
    </div>
  );
};
