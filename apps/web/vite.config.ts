import { defineConfig, type Plugin } from 'vite'
import react from '@vitejs/plugin-react'
import fs from 'fs'
import path from 'path'

function spaFallbackPlugin(): Plugin {
  return {
    name: 'spa-fallback-plugin',
    closeBundle() {
      const distDir = path.resolve(process.cwd(), 'dist')
      const indexPath = path.join(distDir, 'index.html')
      if (fs.existsSync(indexPath)) {
        const indexHtml = fs.readFileSync(indexPath, 'utf-8')

        // 1. /404.html
        fs.writeFileSync(path.join(distDir, '404.html'), indexHtml)

        // 2. /privacy.html and /privacy/index.html
        const privacyDir = path.join(distDir, 'privacy')
        if (!fs.existsSync(privacyDir)) fs.mkdirSync(privacyDir, { recursive: true })
        fs.writeFileSync(path.join(privacyDir, 'index.html'), indexHtml)
        fs.writeFileSync(path.join(distDir, 'privacy.html'), indexHtml)

        // 3. /user-privacy.html and /user-privacy/index.html
        const userPrivacyDir = path.join(distDir, 'user-privacy')
        if (!fs.existsSync(userPrivacyDir)) fs.mkdirSync(userPrivacyDir, { recursive: true })
        fs.writeFileSync(path.join(userPrivacyDir, 'index.html'), indexHtml)
        fs.writeFileSync(path.join(distDir, 'user-privacy.html'), indexHtml)

        // 4. Aliases: /privacy-policy and /user-privacy-rights
        const privacyPolicyDir = path.join(distDir, 'privacy-policy')
        if (!fs.existsSync(privacyPolicyDir)) fs.mkdirSync(privacyPolicyDir, { recursive: true })
        fs.writeFileSync(path.join(privacyPolicyDir, 'index.html'), indexHtml)

        const userRightsDir = path.join(distDir, 'user-privacy-rights')
        if (!fs.existsSync(userRightsDir)) fs.mkdirSync(userRightsDir, { recursive: true })
        fs.writeFileSync(path.join(userRightsDir, 'index.html'), indexHtml)
      }
    },
  }
}

// https://vite.dev/config/
export default defineConfig({
  plugins: [react(), spaFallbackPlugin()],
})

