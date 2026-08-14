import React from 'react';

interface PhotonLogoProps {
  size?: number;
  showText?: boolean;
  color?: string;
}

export const PhotonLogo: React.FC<PhotonLogoProps> = ({
  size = 32,
  showText = true,
  color = '#ffffff',
}) => {
  // Exact 6-blade aperture geometry matching iOS PhotonLogoMark
  const bladeCount = 6;
  const radius = 50;
  const strokeWidth = radius * 0.11; // ~5.5px on 100x100 canvas
  const innerRadius = radius * 0.35; // ~17.5px
  const rayLength = radius * 0.76;   // ~38px

  const blades = Array.from({ length: bladeCount }).map((_, i) => {
    const angle = i * ((2 * Math.PI) / bladeCount) - Math.PI / 6;
    const tangentAngle = angle + Math.PI / 3.2;

    const startX = 50 + Math.cos(angle) * innerRadius;
    const startY = 50 + Math.sin(angle) * innerRadius;
    const endX = startX + Math.cos(tangentAngle) * (rayLength - innerRadius);
    const endY = startY + Math.sin(tangentAngle) * (rayLength - innerRadius);

    return { startX, startY, endX, endY };
  });

  return (
    <div style={{ display: 'inline-flex', alignItems: 'center', gap: '10px', userSelect: 'none' }}>
      {/* Transparent White Vector Aperture Brandmark */}
      <svg
        width={size}
        height={size}
        viewBox="0 0 100 100"
        fill="none"
        style={{ flexShrink: 0 }}
      >
        {/* Outer Ring */}
        <circle
          cx="50"
          cy="50"
          r={50 - strokeWidth / 2 - 2}
          stroke={color}
          strokeWidth={strokeWidth}
        />

        {/* 6 Minimalist Aperture Blades */}
        {blades.map((b, i) => (
          <line
            key={i}
            x1={b.startX}
            y1={b.startY}
            x2={b.endX}
            y2={b.endY}
            stroke={color}
            strokeWidth={strokeWidth * 0.9}
            strokeLinecap="round"
          />
        ))}

        {/* Central Core Dot */}
        <circle cx="50" cy="50" r={radius * 0.13} fill={color} />
      </svg>

      {/* Brand Title */}
      {showText && (
        <span
          style={{
            fontFamily: 'var(--font-display)',
            fontWeight: 700,
            fontSize: `${Math.max(16, size * 0.58)}px`,
            letterSpacing: '4px',
            color: color,
            lineHeight: 1,
          }}
        >
          PHOTON
        </span>
      )}
    </div>
  );
};
