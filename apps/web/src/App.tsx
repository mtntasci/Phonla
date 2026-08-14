import { Navbar } from './components/Navbar';
import { HeroSection } from './components/HeroSection';
import { FeaturesSection } from './components/FeaturesSection';
import { InteractiveComparison } from './components/InteractiveComparison';
import { AdjustmentSimulator } from './components/AdjustmentSimulator';
import { PresetsShowcase } from './components/PresetsShowcase';
import { PrivacySection } from './components/PrivacySection';
import { PricingSection } from './components/PricingSection';
import { Footer } from './components/Footer';

export function App() {
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
      <Footer />
    </div>
  );
}

export default App;
