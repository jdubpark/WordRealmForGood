'use client'

import { ConnectButton } from '@rainbow-me/rainbowkit'
import { ethers } from 'ethers'
import Image from 'next/image'
import { useAccount, useContractRead, useContractWrite, usePrepareContractWrite } from 'wagmi'

import ABI_NFT from '~/abi/NFT.json'
import wordsRealmCat from '~/assets/WordsRealmCat.gif'
import AdventureSelector from '~/components/Selector'
import { useGetNFT } from '~/hooks/useGetNFT'

export default function Page() {
  const { address } = useAccount()

  const {
    data: dataGetWords
    // isError: isErrorGetWords,
    // isLoading: isLoadingGetWords
  } = useContractRead({
    address: process.env.NEXT_PUBLIC_CONTRACT_ADDR_NFT as `0x${string}`,
    abi: ABI_NFT,
    functionName: 'getWords',
    args: [address!]
  })

  const {
    data: dataMintWordsCounter
    // isError: isErrorGetWords,
    // isLoading: isLoadingGetWords
  } = useContractRead({
    address: process.env.NEXT_PUBLIC_CONTRACT_ADDR_NFT as `0x${string}`,
    abi: ABI_NFT,
    functionName: 'mintWordsCounter',
    args: [address!]
  })

  const mintWordsCost = dataMintWordsCounter ? 0.01 * Number((dataMintWordsCounter as bigint).toString()) : 0
  const { config: configMintWords } = usePrepareContractWrite({
    address: process.env.NEXT_PUBLIC_CONTRACT_ADDR_NFT as `0x${string}`,
    abi: ABI_NFT,
    functionName: 'mintWordsV2',
    args: [],
    value: ethers.utils.parseEther(String(mintWordsCost)).toBigInt()
  })

  const { config: configSendTreasuryToMainnetBnM } = usePrepareContractWrite({
    address: process.env.NEXT_PUBLIC_CONTRACT_ADDR_NFT as `0x${string}`,
    abi: ABI_NFT,
    functionName: 'sendTreasuryToMainnetBnM',
    args: [],
    value: ethers.utils.parseEther('0.007').toBigInt()
  })

  const { write: writeMintWords } = useContractWrite(configMintWords)

  const { write: sendTreasuryToMainnetBnM } = useContractWrite(configSendTreasuryToMainnetBnM)

  // console.log('dataMintWordsCounter', dataMintWordsCounter)

  const { data: nftData } = useGetNFT(address)

  return (
    <div className='mt-10 text-center'>
      <div className='hero w-full'>
        <div className='hero-content flex flex-col spacing-3'>
          <h3 className='text-5xl font-bold'>Turkish Magic Carpet Cats</h3>
          {nftData ? (
            <div className='flex flex-col items-center'>
              <Image
                src={nftData.tokenUri}
                alt='Words Realm Cat'
                width={600}
                height={600}
                style={{ borderRadius: 10 }}
              />
            </div>
          ) : (
            <Image src={wordsRealmCat} alt='Words Realm Cat' width={220} height={220} style={{ borderRadius: 10 }} />
          )}
          <ConnectButton showBalance={false} />
        </div>
      </div>
      {!nftData ? (
        !dataGetWords || (dataGetWords && !(dataGetWords as string[]).length) ? (
          <button className='btn btn-secondary' onClick={writeMintWords}>
            Get Random Words
          </button>
        ) : (
          <>
            <AdventureSelector
              items={{
                landmark: (dataGetWords as string[]).slice(0, 3),
                cuisine: (dataGetWords as string[]).slice(3, 6),
                carpet: (dataGetWords as string[]).slice(6, 9)
              }}
            />
            <div className='flex flex-col spacing-2 items-center'>
              <button className='btn btn-ghost' onClick={writeMintWords}>
                Get Random Words Again
              </button>
              ({typeof dataMintWordsCounter === 'number' ? 2 - dataMintWordsCounter : 0} attempts left)
            </div>
          </>
        )
      ) : (
        <div className='mt-2'>
          <button className="btn btn-info" onClick={sendTreasuryToMainnetBnM}>Send Treasury</button>
        </div>
      )}
    </div>
  )
}
