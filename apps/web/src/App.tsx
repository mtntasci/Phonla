import { useState, useEffect } from 'react';
import { Navbar } from './components/Navbar';
import { HeroSection } from './components/HeroSection';
import { FeaturesSection } from './components/FeaturesSection';
import { InteractiveComparison } from './components/InteractiveComparison';
import { AdjustmentSimulator } from './components/AdjustmentSimulator';
import { PresetsShowcase } from './components/PresetsShowcase';
import { PrivacySection } from './components/PrivacySection';
import { PricingSection } from './components/PricingSection';
import { Footer } from './components/Footer';
import { PrivacyPolicy } from './components/PrivacyPolicy';

export function App() {
  const [currentPage, setCurrentPage] = useState<'home' | 'privacy'>('home');

  useEffect(() => {
    const handleHashChange = () => {
      const hash = window.location.hash;
      const pathname = window.location.pathname;
      if (hash === '#privacy' || hash === '#privacy-policy' || pathname === '/privacy') {
        setCurrentPage('privacy');
      } else {
        setCurrentPage('home');
      }
    };

    handleHashChange();
    window.addEventListener('hashchange', handleHashChange);
    window.addEventListener('popstate', handleHashChange);

    return () => {
      window.removeEventListener('hashchange', handleHashChange);
      window.removeEventListener('popstate', handleHashChange);
    };
  }, []);

  const navigateToPrivacy = () => {
    window.location.hash = '#privacy';
    setCurrentPage('privacy');
  };

  const navigateToHome = () => {
    window.location.hash = '';
    setCurrentPage('home');
  };

  if (currentPage === 'privacy') {
    return <PrivacyPolicy onBack={navigateToHome} />;
  }

  return (
    <div className="photon-app-root">
      {/* Navigation Bar */}
      <Navbar />

      <main>
        {/* Hero Showcase with Interactive Phone Preview */}
        <HeroSection />

        {/* 4 Core Pillars of Photon */}
        <FeaturesSection />

        {/* Live Interactive Before / After Split Slider Studio */}
        <InteractiveComparison />

        {/* Live Adjustment Deck Simulator */}
        <AdjustmentSimulator />

        {/* Preset Collections Grid */}
        <PresetsShowcase />

        {/* Privacy & Hardware Acceleration with 3-Tap Easter Egg */}
        <PrivacySection />

        {/* Memberships & Pricing */}
        <PricingSection />
      </main>

      {/* Footer */}
      <Footer onPrivacyClick={navigateToPrivacy} />
    </div>
  );
}

export default App;

