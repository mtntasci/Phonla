import React, { useEffect } from 'react';
import { ArrowLeft, ShieldCheck, FileText } from 'lucide-react';
import { PhotonLogo } from './PhotonLogo';

interface PrivacyPolicyProps {
  onBack: () => void;
  onNavigateUserPrivacy?: () => void;
}

export const PrivacyPolicy: React.FC<PrivacyPolicyProps> = ({ onBack, onNavigateUserPrivacy }) => {
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

          {onNavigateUserPrivacy && (
            <button
              onClick={onNavigateUserPrivacy}
              style={{
                display: 'flex',
                alignItems: 'center',
                gap: '6px',
                background: 'transparent',
                border: 'none',
                color: '#60a5fa',
                fontSize: '13px',
                fontWeight: 500,
                cursor: 'pointer',
                padding: '8px 12px',
              }}
            >
              <FileText size={15} />
              <span>User Privacy Rights</span>
            </button>
          )}
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
            <ShieldCheck size={14} color="#10b981" />
            <span>Legal & Privacy</span>
          </div>

          <h1 style={{ fontSize: '36px', fontWeight: 800, letterSpacing: '-0.02em', marginBottom: '8px' }}>
            Privacy Policy
          </h1>
          <p style={{ color: '#8e95a5', fontSize: '14px', marginBottom: '24px' }}>
            Last Updated: August 15, 2026
          </p>
          <p style={{ fontSize: '16px', color: '#cbd5e1', lineHeight: 1.6, borderLeft: '3px solid #3b82f6', paddingLeft: '16px' }}>
            photonla respects your privacy and is designed to process your photos primarily on your device.
          </p>
        </div>

        {/* Policy Body */}
        <div style={{ display: 'flex', flexDirection: 'column', gap: '32px', lineHeight: 1.7, fontSize: '15px', color: '#cbd5e1' }}>
          
          {/* Section 1 */}
          <section>
            <h2 style={{ fontSize: '20px', fontWeight: 700, color: '#ffffff', marginBottom: '12px' }}>
              1. Photo Processing
            </h2>
            <p>
              Photos selected for editing in photonla are processed locally on your device using native and hardware-accelerated image processing technologies.
            </p>
            <p style={{ marginTop: '8px' }}>
              photonla does not upload your photos to our servers for the standard photo editing features available in the application.
            </p>
            <p style={{ marginTop: '8px' }}>
              Edited photos are saved to your device&apos;s photo library only when you request an export.
            </p>
          </section>

          {/* Section 2 */}
          <section>
            <h2 style={{ fontSize: '20px', fontWeight: 700, color: '#ffffff', marginBottom: '12px' }}>
              2. Account Information
            </h2>
            <p>
              photonla uses Firebase Authentication to provide account and session functionality.
            </p>
            <p style={{ marginTop: '8px' }}>
              Depending on your selected sign-in provider, we may process limited account information such as:
            </p>
            <ul style={{ paddingLeft: '24px', marginTop: '8px', display: 'flex', flexDirection: 'column', gap: '4px' }}>
              <li>Name</li>
              <li>Email address</li>
              <li>Profile image</li>
              <li>Authentication provider information</li>
              <li>User identifier required for authentication</li>
            </ul>
            <p style={{ marginTop: '8px' }}>
              photonla supports authentication providers such as Sign in with Apple and Google where available.
            </p>
          </section>

          {/* Section 3 */}
          <section>
            <h2 style={{ fontSize: '20px', fontWeight: 700, color: '#ffffff', marginBottom: '12px' }}>
              3. Advertising
            </h2>
            <p>
              The free version of photonla may display rewarded advertisements before certain actions, such as exporting an edited photo.
            </p>
            <p style={{ marginTop: '8px' }}>
              We use Google AdMob to provide advertisements.
            </p>
            <p style={{ marginTop: '8px' }}>
              Google and its advertising partners may process information such as device identifiers, advertising data, product interaction information and technical or diagnostic information in accordance with their own privacy policies and applicable consent requirements.
            </p>
            <p style={{ marginTop: '8px' }}>
              Where required, photonla will request appropriate privacy or tracking consent before enabling relevant advertising functionality.
            </p>
            <p style={{ marginTop: '8px' }}>
              Users who do not grant tracking permission can continue using photonla. Advertising functionality may operate with limited or non-personalized advertising where applicable.
            </p>
          </section>

          {/* Section 4 */}
          <section>
            <h2 style={{ fontSize: '20px', fontWeight: 700, color: '#ffffff', marginBottom: '12px' }}>
              4. Subscriptions
            </h2>
            <p>
              photonla may offer paid subscriptions such as photonla Pro.
            </p>
            <p style={{ marginTop: '8px' }}>
              Subscriptions and payments on iOS are processed by Apple through the App Store and StoreKit.
            </p>
            <p style={{ marginTop: '8px' }}>
              photonla does not receive or store your complete payment card information.
            </p>
            <p style={{ marginTop: '8px' }}>
              Subscription status may be processed to determine whether features such as an ad-free experience should be enabled.
            </p>
          </section>

          {/* Section 5 */}
          <section>
            <h2 style={{ fontSize: '20px', fontWeight: 700, color: '#ffffff', marginBottom: '12px' }}>
              5. Notifications
            </h2>
            <p>
              photonla may request permission to send notifications.
            </p>
            <p style={{ marginTop: '8px' }}>
              Notifications may be used to inform users about:
            </p>
            <ul style={{ paddingLeft: '24px', marginTop: '8px', display: 'flex', flexDirection: 'column', gap: '4px' }}>
              <li>New features</li>
              <li>Product updates</li>
              <li>Important application information</li>
              <li>Relevant photonla announcements</li>
            </ul>
            <p style={{ marginTop: '8px' }}>
              Notification permission is optional and can be changed through your device settings.
            </p>
          </section>

          {/* Section 6 */}
          <section>
            <h2 style={{ fontSize: '20px', fontWeight: 700, color: '#ffffff', marginBottom: '12px' }}>
              6. Photo Library Access
            </h2>
            <p>
              photonla may request permission to add edited photos to your photo library.
            </p>
            <p style={{ marginTop: '8px' }}>
              We request only the access necessary for application functionality whenever technically possible.
            </p>
            <p style={{ marginTop: '8px' }}>
              Your original photo is not intentionally overwritten during the normal editing and export process.
            </p>
          </section>

          {/* Section 7 */}
          <section>
            <h2 style={{ fontSize: '20px', fontWeight: 700, color: '#ffffff', marginBottom: '12px' }}>
              7. Analytics, Diagnostics and Device Information
            </h2>
            <p>
              Third-party services integrated with photonla, including Firebase and Google advertising technologies, may process limited technical information required for application functionality, diagnostics, security, advertising or performance measurement.
            </p>
            <p style={{ marginTop: '8px' }}>
              This may include device identifiers, application interactions, crash information and performance information depending on the services enabled and permissions granted.
            </p>
          </section>

          {/* Section 8 */}
          <section>
            <h2 style={{ fontSize: '20px', fontWeight: 700, color: '#ffffff', marginBottom: '12px' }}>
              8. Tracking and Consent
            </h2>
            <p>
              Where required by applicable law or platform rules, photonla asks for consent before using information for tracking or personalized advertising.
            </p>
            <p style={{ marginTop: '8px' }}>
              On Apple platforms, users may also be presented with Apple&apos;s App Tracking Transparency permission.
            </p>
            <p style={{ marginTop: '8px' }}>
              Refusing tracking permission does not prevent access to the core photo editing functionality of photonla.
            </p>
          </section>

          {/* Section 9 */}
          <section>
            <h2 style={{ fontSize: '20px', fontWeight: 700, color: '#ffffff', marginBottom: '12px' }}>
              9. Children and Young Users
            </h2>
            <p>
              photonla is a general-audience photo editing application and is not specifically designed or marketed as an application for children.
            </p>
            <p style={{ marginTop: '8px' }}>
              We seek to minimize personal information collection and do not require unnecessary personal information to use the photo editing functionality.
            </p>
          </section>

          {/* Section 10 */}
          <section>
            <h2 style={{ fontSize: '20px', fontWeight: 700, color: '#ffffff', marginBottom: '12px' }}>
              10. Data Security
            </h2>
            <p>
              We use reasonable technical and organizational safeguards designed to protect information processed through photonla and its supporting services.
            </p>
            <p style={{ marginTop: '8px' }}>
              Photos used with the standard editing tools are processed locally on the user&apos;s device and are not intentionally uploaded to photonla servers.
            </p>
          </section>

          {/* Section 11 */}
          <section>
            <h2 style={{ fontSize: '20px', fontWeight: 700, color: '#ffffff', marginBottom: '12px' }}>
              11. Account Deletion
            </h2>
            <p>
              Users can request deletion of their photonla account directly from within the application.
            </p>
            <p style={{ marginTop: '8px' }}>
              Go to:
            </p>
            <p style={{ fontWeight: 600, color: '#ffffff', padding: '8px 14px', background: 'rgba(255, 255, 255, 0.05)', borderRadius: '8px', display: 'inline-block', margin: '6px 0' }}>
              Profile / Settings → Delete My Account
            </p>
            <p style={{ marginTop: '8px' }}>
              Deleting an account removes the associated photonla authentication account and applicable account data under our control, subject to information we may be legally required to retain.
            </p>
            <p style={{ marginTop: '8px' }}>
              Deleting a photonla account does not automatically cancel an active App Store subscription. App Store subscriptions are managed through the user&apos;s Apple account.
            </p>
          </section>

          {/* Section 12 */}
          <section>
            <h2 style={{ fontSize: '20px', fontWeight: 700, color: '#ffffff', marginBottom: '12px' }}>
              12. Third-Party Services
            </h2>
            <p>
              photonla may use services provided by third parties, including:
            </p>
            <ul style={{ paddingLeft: '24px', marginTop: '8px', display: 'flex', flexDirection: 'column', gap: '4px' }}>
              <li>Apple App Store / StoreKit</li>
              <li>Sign in with Apple</li>
              <li>Google Firebase</li>
              <li>Google Authentication services</li>
              <li>Google AdMob</li>
            </ul>
            <p style={{ marginTop: '8px' }}>
              These providers process information according to their respective privacy policies and terms.
            </p>
          </section>

          {/* Section 13 */}
          <section>
            <h2 style={{ fontSize: '20px', fontWeight: 700, color: '#ffffff', marginBottom: '12px' }}>
              13. Changes to This Policy
            </h2>
            <p>
              We may update this Privacy Policy as photonla evolves or when legal, platform or technical requirements change.
            </p>
            <p style={{ marginTop: '8px' }}>
              The latest version will be published on the photonla website.
            </p>
          </section>

          {/* Section 14 */}
          <section>
            <h2 style={{ fontSize: '20px', fontWeight: 700, color: '#ffffff', marginBottom: '12px' }}>
              14. Contact
            </h2>
            <p>
              For privacy questions, data requests or account-related privacy matters, please contact us through the contact information published on:
            </p>
            <p style={{ marginTop: '8px' }}>
              <a href="https://photonla.com" style={{ color: '#60a5fa', textDecoration: 'none', fontWeight: 600 }}>
                https://photonla.com
              </a>
            </p>
          </section>

        </div>
      </div>
    </div>
  );
};
