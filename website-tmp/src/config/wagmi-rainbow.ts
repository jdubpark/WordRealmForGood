'use client'

import { getDefaultWallets, lightTheme } from '@rainbow-me/rainbowkit'
import { configureChains, createConfig } from 'wagmi'
import { baseGoerli, sepolia } from 'wagmi/chains'
// import { alchemyProvider } from 'wagmi/providers/alchemy';
import { publicProvider } from 'wagmi/providers/public'

export const wagmiChains = [baseGoerli, sepolia]

const { chains, publicClient } = configureChains(wagmiChains, [
  // alchemyProvider({ apiKey: process.env.ALCHEMY_ID }),
  publicProvider()
])

const { connectors } = getDefaultWallets({
  appName: 'ProactivePGF',
  projectId: 'proactivepgf',
  chains
})

export const wagmiConfig = createConfig({
  autoConnect: true,
  connectors,
  publicClient
})

export const rainbowTheme = lightTheme({
  ...lightTheme.accentColors.green
})
