import React, { useState } from 'react';
import { SlidersHorizontal, RotateCcw, Sun, Thermometer, Contrast, Droplet } from 'lucide-react';

export const AdjustmentSimulator: React.FC = () => {
  const [exposure, setExposure] = useState<number>(0);
  const [temperature, setTemperature] = useState<number>(6500);
  const [contrast, setContrast] = useState<number>(1);
  const [saturation, setSaturation] = useState<number>(1);
  const [brightness, setBrightness] = useState<number>(1);
  const [selectedImage, setSelectedImage] = useState<string>('/assets/portrait_sample.jpg');

  const handleReset = () => {
    setExposure(0);
    setTemperature(6500);
    setContrast(1);
    setSaturation(1);
    setBrightness(1);
  };

  // Convert simulator parameters into dynamic CSS filter
  const getSimulatedFilter = () => {
    const expFactor = 1 + exposure * 0.35;
    const tempHue = ((temperature - 6500) / 3500) * -18;
    const tempSepia = temperature > 6500 ? ((temperature - 6500) / 3500) * 0.35 : 0;
    const bright = brightness * expFactor;

    return `
      brightness(${bright.toFixed(2)}) 
      contrast(${contrast.toFixed(2)}) 
      saturate(${saturation.toFixed(2)}) 
      hue-rotate(${tempHue.toFixed(1)}deg)
      sepia(${tempSepia.toFixed(2)})
    `;
  };

  const isModified =
    exposure !== 0 ||
    temperature !== 6500 ||
    contrast !== 1 ||
    saturation !== 1 ||
    brightness !== 1;

  return (
    <section id="simulator" style={{ padding: '100px 0', background: 'rgba(12, 12, 16, 0.6)' }}>
      <div className="container">
        
        {/* Section Header */}
        <div style={{ textAlign: 'center', marginBottom: '48px' }}>
          <div className="badge-pill badge-pill-cyan" style={{ marginBottom: '16px' }}>
            <SlidersHorizontal size={14} />
            <span>Canlı Ayar Motoru</span>
          </div>
          <h2 style={{ fontSize: 'clamp(32px, 4vw, 48px)', marginBottom: '16px' }}>
            Photon <span className="gradient-text-amber">Adjustment Deck</span>
          </h2>
          <p style={{ color: 'var(--text-secondary)', fontSize: '16px', maxWidth: '600px', margin: '0 auto' }}>
            Aşağıdaki sürgüleri hareket ettirerek Photon'un anlık renk ve ışık işleme tepkisini tarayıcınızda deneyimleyin.
          </p>
        </div>

        {/* Deck Grid */}
        <div
          style={{
            display: 'grid',
            gridTemplateColumns: '1.2fr 0.8fr',
            gap: '40px',
            alignItems: 'center',
          }}
          className="deck-grid"
        >
          {/* Live Preview Screen */}
          <div className="glass-panel" style={{ padding: '16px', position: 'relative', overflow: 'hidden' }}>
            <div style={{ position: 'relative', width: '100%', aspectRatio: '4/3', borderRadius: '16px', overflow: 'hidden' }}>
              <img
                src={selectedImage}
                alt="Simulator Live Output"
                style={{
                  width: '100%',
                  height: '100%',
                  objectFit: 'cover',
                  filter: getSimulatedFilter(),
                  transition: 'filter 0.05s ease',
                }}
              />

              {/* Status Indicator */}
              <div
                style={{
                  position: 'absolute',
                  top: '16px',
                  left: '16px',
                  background: 'rgba(0, 0, 0, 0.75)',
                  backdropFilter: 'blur(10px)',
                  padding: '6px 12px',
                  borderRadius: 'var(--radius-full)',
                  fontSize: '11px',
                  fontWeight: 600,
                  color: 'var(--accent-cyan)',
                  border: '1px solid rgba(255, 255, 255, 0.1)',
                }}
              >
                ● 60 FPS Metal GPU Simülatörü
              </div>
            </div>

            {/* Photo Selector */}
            <div style={{ display: 'flex', gap: '8px', marginTop: '14px', justifyContent: 'center' }}>
              {[
                { src: '/assets/portrait_sample.jpg', label: 'Portre' },
                { src: '/assets/cinema.jpg', label: 'Sinema' },
                { src: '/assets/nature.jpg', label: 'Doğa' },
                { src: '/assets/urban.jpg', label: 'Şehir' },
              ].map((p, idx) => (
                <button
                  key={idx}
                  onClick={() => setSelectedImage(p.src)}
                  style={{
                    background: selectedImage === p.src ? '#ffffff' : 'rgba(255, 255, 255, 0.08)',
                    color: selectedImage === p.src ? '#000000' : '#ffffff',
                    border: 'none',
                    padding: '4px 12px',
                    borderRadius: '10px',
                    fontSize: '11px',
                    fontWeight: 600,
                    cursor: 'pointer',
                    transition: 'all 0.2s',
                  }}
                >
                  {p.label}
                </button>
              ))}
            </div>
          </div>

          {/* Interactive Sliders Panel */}
          <div className="glass-panel" style={{ padding: '32px', display: 'flex', flexDirection: 'column', gap: '24px' }}>
            
            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
              <span style={{ fontFamily: 'var(--font-display)', fontSize: '18px', fontWeight: 700 }}>
                Işık & Renk Kontrolleri
              </span>
              
              {isModified && (
                <button
                  onClick={handleReset}
                  style={{
                    background: 'rgba(255, 255, 255, 0.1)',
                    border: '1px solid rgba(255, 255, 255, 0.2)',
                    color: '#ffffff',
                    padding: '6px 14px',
                    borderRadius: 'var(--radius-full)',
                    fontSize: '12px',
                    fontWeight: 600,
                    cursor: 'pointer',
                    display: 'flex',
                    alignItems: 'center',
                    gap: '6px',
                  }}
                >
                  <RotateCcw size={12} />
                  <span>Sıfırla</span>
                </button>
              )}
            </div>

            {/* Pozlama (Exposure) */}
            <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '13px' }}>
                <span style={{ display: 'flex', alignItems: 'center', gap: '6px', color: 'var(--text-secondary)' }}>
                  <Sun size={14} color="var(--accent-amber)" /> Pozlama (Exposure)
                </span>
                <span style={{ fontWeight: 600 }}>{exposure > 0 ? `+${exposure.toFixed(2)} EV` : `${exposure.toFixed(2)} EV`}</span>
              </div>
              <input
                type="range"
                min="-1.5"
                max="1.5"
                step="0.05"
                value={exposure}
                onChange={(e) => setExposure(parseFloat(e.target.value))}
                className="photon-range-input"
              />
            </div>

            {/* Sıcaklık (Temperature) */}
            <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '13px' }}>
                <span style={{ display: 'flex', alignItems: 'center', gap: '6px', color: 'var(--text-secondary)' }}>
                  <Thermometer size={14} color="var(--accent-cyan)" /> Sıcaklık (Kelvin)
                </span>
                <span style={{ fontWeight: 600 }}>{temperature}K {temperature === 6500 ? '(Nötr)' : ''}</span>
              </div>
              <input
                type="range"
                min="3000"
                max="10000"
                step="50"
                value={temperature}
                onChange={(e) => setTemperature(parseInt(e.target.value))}
                className="photon-range-input"
              />
            </div>

            {/* Kontrast (Contrast) */}
            <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '13px' }}>
                <span style={{ display: 'flex', alignItems: 'center', gap: '6px', color: 'var(--text-secondary)' }}>
                  <Contrast size={14} /> Kontrast (Contrast)
                </span>
                <span style={{ fontWeight: 600 }}>{Math.round((contrast - 1) * 100)}%</span>
              </div>
              <input
                type="range"
                min="0.5"
                max="1.6"
                step="0.02"
                value={contrast}
                onChange={(e) => setContrast(parseFloat(e.target.value))}
                className="photon-range-input"
              />
            </div>

            {/* Doygunluk (Saturation) */}
            <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '13px' }}>
                <span style={{ display: 'flex', alignItems: 'center', gap: '6px', color: 'var(--text-secondary)' }}>
                  <Droplet size={14} color="var(--accent-purple)" /> Doygunluk (Saturation)
                </span>
                <span style={{ fontWeight: 600 }}>{Math.round((saturation - 1) * 100)}%</span>
              </div>
              <input
                type="range"
                min="0"
                max="2.0"
                step="0.02"
                value={saturation}
                onChange={(e) => setSaturation(parseFloat(e.target.value))}
                className="photon-range-input"
              />
            </div>

          </div>

        </div>

      </div>

      <style>{`
        @media (max-width: 900px) {
          .deck-grid {
            grid-template-columns: 1fr !important;
            gap: 28px !important;
          }
        }
      `}</style>
    </section>
  );
};
