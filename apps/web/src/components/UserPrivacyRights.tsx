import React, { useEffect } from 'react';
import { ArrowLeft, UserCheck, Shield } from 'lucide-react';
import { PhotonLogo } from './PhotonLogo';

interface UserPrivacyRightsProps {
  onBack: () => void;
  onNavigatePrivacyPolicy?: () => void;
}

export const UserPrivacyRights: React.FC<UserPrivacyRightsProps> = ({ onBack, onNavigatePrivacyPolicy }) => {
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

          {onNavigatePrivacyPolicy && (
            <button
              onClick={onNavigatePrivacyPolicy}
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
              <Shield size={15} />
              <span>Privacy Policy</span>
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
            <UserCheck size={14} color="#3b82f6" />
            <span>User Rights & Choices</span>
          </div>

          <h1 style={{ fontSize: '36px', fontWeight: 800, letterSpacing: '-0.02em', marginBottom: '8px' }}>
            User Privacy &amp; Data Rights
          </h1>
          <p style={{ color: '#8e95a5', fontSize: '14px', marginBottom: '24px' }}>
            Last Updated: August 15, 2026
          </p>
          <p style={{ fontSize: '16px', color: '#cbd5e1', lineHeight: 1.6, borderLeft: '3px solid #10b981', paddingLeft: '16px' }}>
            phonla gives users control over their account, permissions and privacy choices.
          </p>
        </div>

        {/* Content Sections */}
        <div style={{ display: 'flex', flexDirection: 'column', gap: '32px', lineHeight: 1.7, fontSize: '15px', color: '#cbd5e1' }}>
          
          {/* Your Photos */}
          <section>
            <h2 style={{ fontSize: '20px', fontWeight: 700, color: '#ffffff', marginBottom: '12px' }}>
              Your Photos
            </h2>
            <p>
              Your photos remain on your device during standard phonla photo editing.
            </p>
            <p style={{ marginTop: '8px' }}>
              Standard editing operations are performed locally on the device.
            </p>
            <p style={{ marginTop: '8px' }}>
              phonla does not require your photos to be uploaded to our servers to use the standard editing tools.
            </p>
          </section>

          {/* Your Account */}
          <section>
            <h2 style={{ fontSize: '20px', fontWeight: 700, color: '#ffffff', marginBottom: '12px' }}>
              Your Account
            </h2>
            <p>
              If you sign in to phonla, limited account information may be provided by your authentication provider.
            </p>
            <p style={{ marginTop: '8px' }}>
              This can include:
            </p>
            <ul style={{ paddingLeft: '24px', marginTop: '8px', display: 'flex', flexDirection: 'column', gap: '4px' }}>
              <li>Name</li>
              <li>Email address</li>
              <li>Profile image</li>
              <li>Authentication provider</li>
              <li>Authentication user identifier</li>
            </ul>
            <p style={{ marginTop: '8px' }}>
              We do not require a telephone number for a phonla account.
            </p>
          </section>

          {/* Delete Your Account */}
          <section>
            <h2 style={{ fontSize: '20px', fontWeight: 700, color: '#ffffff', marginBottom: '12px' }}>
              Delete Your Account
            </h2>
            <p>
              You can delete your account directly from the phonla application.
            </p>
            <p style={{ marginTop: '8px' }}>
              Navigate to:
            </p>
            <p style={{ fontWeight: 600, color: '#ffffff', padding: '8px 14px', background: 'rgba(255, 255, 255, 0.05)', borderRadius: '8px', display: 'inline-block', margin: '6px 0' }}>
              Profile / Settings → Delete My Account
            </p>
            <p style={{ marginTop: '8px' }}>
              After confirmation, phonla will initiate deletion of your authentication account and applicable user information controlled by phonla.
            </p>
            <p style={{ marginTop: '8px' }}>
              You may be required to authenticate again before account deletion for security reasons.
            </p>
          </section>

          {/* App Store Subscriptions */}
          <section>
            <h2 style={{ fontSize: '20px', fontWeight: 700, color: '#ffffff', marginBottom: '12px' }}>
              App Store Subscriptions
            </h2>
            <p>
              Deleting your phonla account does not automatically cancel an active Apple App Store subscription.
            </p>
            <p style={{ marginTop: '8px' }}>
              Subscriptions can be managed or cancelled through your Apple account:
            </p>
            <p style={{ fontWeight: 600, color: '#ffffff', padding: '8px 14px', background: 'rgba(255, 255, 255, 0.05)', borderRadius: '8px', display: 'inline-block', margin: '6px 0' }}>
              iPhone Settings → Apple Account → Subscriptions
            </p>
          </section>

          {/* Sign Out */}
          <section>
            <h2 style={{ fontSize: '20px', fontWeight: 700, color: '#ffffff', marginBottom: '12px' }}>
              Sign Out
            </h2>
            <p>
              You can sign out of your phonla account through the Profile / Settings screen.
            </p>
            <p style={{ marginTop: '8px' }}>
              Signing out does not delete your account.
            </p>
          </section>

          {/* Notifications */}
          <section>
            <h2 style={{ fontSize: '20px', fontWeight: 700, color: '#ffffff', marginBottom: '12px' }}>
              Notifications
            </h2>
            <p>
              Notification permission is optional.
            </p>
            <p style={{ marginTop: '8px' }}>
              You can allow or deny notifications and change this permission later through iOS Settings.
            </p>
          </section>

          {/* Photo Library Permission */}
          <section>
            <h2 style={{ fontSize: '20px', fontWeight: 700, color: '#ffffff', marginBottom: '12px' }}>
              Photo Library Permission
            </h2>
            <p>
              phonla requires appropriate system permission when saving an edited photo to your photo library.
            </p>
            <p style={{ marginTop: '8px' }}>
              You can manage photo permissions through iOS Settings.
            </p>
          </section>

          {/* Advertising & Tracking */}
          <section>
            <h2 style={{ fontSize: '20px', fontWeight: 700, color: '#ffffff', marginBottom: '12px' }}>
              Advertising &amp; Tracking
            </h2>
            <p>
              Free users may be offered rewarded advertisements for certain actions such as exporting edited photos.
            </p>
            <p style={{ marginTop: '8px' }}>
              phonla uses Google AdMob for advertising.
            </p>
            <p style={{ marginTop: '8px' }}>
              Where required, you will be provided with privacy choices relating to advertising and tracking.
            </p>
            <p style={{ marginTop: '8px' }}>
              On supported Apple devices, tracking permission may also be controlled through Apple&apos;s App Tracking Transparency system.
            </p>
            <p style={{ marginTop: '8px' }}>
              Declining tracking does not disable phonla&apos;s core photo editing functionality.
            </p>
          </section>

          {/* Paid Users */}
          <section>
            <h2 style={{ fontSize: '20px', fontWeight: 700, color: '#ffffff', marginBottom: '12px' }}>
              Paid Users
            </h2>
            <p>
              Users with an active phonla Pro subscription may receive an ad-free experience according to the benefits displayed in the application.
            </p>
            <p style={{ marginTop: '8px' }}>
              Subscription purchases, renewals and cancellations are managed through Apple&apos;s App Store.
            </p>
          </section>

          {/* Your Privacy Choices */}
          <section>
            <h2 style={{ fontSize: '20px', fontWeight: 700, color: '#ffffff', marginBottom: '12px' }}>
              Your Privacy Choices
            </h2>
            <p>
              Depending on your location and applicable law, you may have rights concerning personal information, including requesting access, correction or deletion of eligible information.
            </p>
            <p style={{ marginTop: '8px' }}>
              The application also provides direct controls for relevant permissions and account deletion.
            </p>
          </section>

          {/* Contact */}
          <section>
            <h2 style={{ fontSize: '20px', fontWeight: 700, color: '#ffffff', marginBottom: '12px' }}>
              Contact
            </h2>
            <p>
              For privacy or data-related requests, contact us using the information available at:
            </p>
            <p style={{ marginTop: '8px' }}>
              <a href="https://phonla.com" style={{ color: '#60a5fa', textDecoration: 'none', fontWeight: 600 }}>
                https://phonla.com
              </a>
            </p>
          </section>

        </div>
      </div>
    </div>
  );
};
