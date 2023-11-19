import { RainbowKitProvider } from '@rainbow-me/rainbowkit'
import { type Metadata } from 'next/types'
import { WagmiConfig } from 'wagmi'

import '@rainbow-me/rainbowkit/styles.css'
import '~/styles/globals.css'

// import { chakraTheme } from '~/config/theme'
import { rainbowTheme, wagmiChains, wagmiConfig } from '~/config/wagmi-rainbow'

export const metadata: Metadata = {
  description: 'ProactivePGF',
  manifest: '/manifest.json',
  title: 'ProactivePGF',
  viewport: {
    initialScale: 1,
    maximumScale: 1,
    width: 'device-width'
  }
}

// const rubikFont = Rubik({
//   display: 'swap',
//   subsets: ['latin'],
//   variable: '--explorer-default-font',
//   weight: ['300', '400', '700']
// })

export default function SuperGovRootLayout({
  // analytics,
  children
}: {
  // analytics?: React.ReactNode
  children: React.ReactNode
}) {
  return (
    // <html lang='en' className={`${rubikFont.variable}`}>
    <html lang='en'>
      <body>
        <WagmiConfig config={wagmiConfig}>
          <RainbowKitProvider chains={wagmiChains} theme={rainbowTheme}>
            <div className='main-content pb-4'>{children}</div>
          </RainbowKitProvider>
        </WagmiConfig>
      </body>
    </html>
  )
}
