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
import { UserPrivacyRights } from './components/UserPrivacyRights';

export function App() {
  const [currentPage, setCurrentPage] = useState<'home' | 'privacy' | 'user-privacy'>('home');

  useEffect(() => {
    const handleNavigation = () => {
      const hash = window.location.hash.toLowerCase();
      const rawPath = window.location.pathname.toLowerCase();
      const cleanPath = rawPath.replace(/\/+$/, '') || '/';

      if (
        hash === '#privacy' ||
        hash === '#privacy-policy' ||
        cleanPath === '/privacy' ||
        cleanPath === '/privacy-policy' ||
        cleanPath === '/privacy.html'
      ) {
        setCurrentPage('privacy');
      } else if (
        hash === '#user-privacy' ||
        hash === '#user-privacy-rights' ||
        cleanPath === '/user-privacy' ||
        cleanPath === '/user-privacy-rights' ||
        cleanPath === '/user-privacy.html'
      ) {
        setCurrentPage('user-privacy');
      } else {
        setCurrentPage('home');
      }
    };

    handleNavigation();
    window.addEventListener('hashchange', handleNavigation);
    window.addEventListener('popstate', handleNavigation);

    return () => {
      window.removeEventListener('hashchange', handleNavigation);
      window.removeEventListener('popstate', handleNavigation);
    };
  }, []);

  const navigateToPrivacy = () => {
    try {
      window.history.pushState(null, '', '/privacy');
    } catch {
      window.location.hash = '#privacy';
    }
    setCurrentPage('privacy');
  };

  const navigateToUserPrivacy = () => {
    try {
      window.history.pushState(null, '', '/user-privacy');
    } catch {
      window.location.hash = '#user-privacy';
    }
    setCurrentPage('user-privacy');
  };

  const navigateToHome = () => {
    try {
      window.history.pushState(null, '', '/');
    } catch {
      window.location.hash = '';
    }
    setCurrentPage('home');
  };

  if (currentPage === 'privacy') {
    return <PrivacyPolicy onBack={navigateToHome} onNavigateUserPrivacy={navigateToUserPrivacy} />;
  }

  if (currentPage === 'user-privacy') {
    return <UserPrivacyRights onBack={navigateToHome} onNavigatePrivacyPolicy={navigateToPrivacy} />;
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
      <Footer onPrivacyClick={navigateToPrivacy} onUserPrivacyClick={navigateToUserPrivacy} />
    </div>
  );
}

export default App;


