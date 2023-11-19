import { IDKitWidget, type ISuccessResult } from '@worldcoin/idkit'
import axios from 'axios'
import { ethers } from 'ethers'
import { useCallback, useState } from 'react'
import { useAccount, useContractWrite, usePrepareContractWrite } from 'wagmi'

import ABI_NFT from '~/abi/NFT.json'
import { decode } from '~/utils/wld'

type Selections = {
  landmark: string
  cuisine: string
  carpet: string
}

type CategorySelectorProps = {
  category: string
  items: string[]
  selection: string
  updateSelection: (category: string, value: string) => void
}

function CategorySelector({ category, items, selection, updateSelection }: CategorySelectorProps) {
  return (
    <div className='bg-white p-4 rounded shadow'>
      <h2 className='text-xl font-semibold mb-2'>{category.charAt(0).toUpperCase() + category.slice(1)}</h2>
      <div className='space-y-1'>
        {items.map((item) => (
          <div
            key={item}
            className={`cursor-pointer p-2 hover:bg-gray-200 rounded ${selection === item ? 'bg-blue-300' : ''}`}
            onClick={() => updateSelection(category, item)}
          >
            {item}
          </div>
        ))}
      </div>
    </div>
  )
}

interface AdventureSelectorProps {
  items: {
    landmark: string[]
    cuisine: string[]
    carpet: string[]
  }
}

export default function AdventureSelector(props: AdventureSelectorProps) {
  const { items } = props

  const { address } = useAccount()

  const [selections, setSelections] = useState<Selections>({
    landmark: '',
    cuisine: '',
    carpet: ''
  })

  const [worldIdProof, setWorldIdProof] = useState<ISuccessResult | null>(null)

  const [ipfsUrl, setIpfsUrl] = useState<string | undefined>()
  const [isCIDLoading, setIsCIDLoading] = useState(false)
  const [CIDError, setCIDError] = useState<any>(null)

  const updateSelection = (category: string, value: string): void => {
    setSelections({ ...selections, [category]: value })
  }

  const { config: mintConfig } = usePrepareContractWrite({
    address: process.env.NEXT_PUBLIC_CONTRACT_ADDR_NFT as `0x${string}`,
    abi: ABI_NFT,
    enabled: worldIdProof != null && address != null,
    functionName: 'mint',
    args: [
      ipfsUrl,
      {
        signal: address,
        root: worldIdProof?.merkle_root ? decode<bigint>('uint256', worldIdProof?.merkle_root ?? '') : BigInt(0),
        nullifierHash: worldIdProof?.nullifier_hash
          ? decode<bigint>('uint256', worldIdProof?.nullifier_hash ?? '')
          : BigInt(0),
        proof: worldIdProof?.proof
          ? decode<[bigint, bigint, bigint, bigint, bigint, bigint, bigint, bigint]>(
              'uint256[8]',
              worldIdProof?.proof ?? ''
            )
          : [BigInt(0), BigInt(0), BigInt(0), BigInt(0), BigInt(0), BigInt(0), BigInt(0), BigInt(0)]
      }
    ],
    value: ethers.utils.parseEther('0.01').toBigInt()
  })

  const { write: mintWrite } = useContractWrite(mintConfig)

  const mintNFT = useCallback(
    (prompt: string) => {
      if (!prompt || !mintWrite) return

      const fn = async () => {
        let CID = ''

        setIsCIDLoading(true)
        try {
          const response = await axios.post<string>(
            'http://127.0.0.1:5000/process_string',
            { image_prompt: prompt },
            { headers: { 'Content-Type': 'application/json' } }
          )

          CID = response.data
          setIpfsUrl(`https://${CID}.ipfs.nftstorage.link/`)
        } catch (error) {
          setCIDError(error)
          throw error
        } finally {
          setIsCIDLoading(false)
        }

        console.log('CID', CID)
        if (!CID) {
          throw new Error('CID is undefined!')
        }
      }

      fn()
    },
    [mintWrite]
  )

  if (!address) return <>Loading address...</>

  return (
    <div className='flex flex-col items-center justify-center gap-4 p-2'>
      <div className='text-center'>
        <h1 className='text-3xl font-bold text-gray-800 mb-6'>Select Your Turkish Adventure</h1>
        <div className='grid grid-cols-1 md:grid-cols-3 gap-4'>
          <CategorySelector
            category='landmark'
            items={items.landmark}
            selection={selections.landmark}
            updateSelection={updateSelection}
          />
          <CategorySelector
            category='cuisine'
            items={items.cuisine}
            selection={selections.cuisine}
            updateSelection={updateSelection}
          />
          <CategorySelector
            category='carpet'
            items={items.carpet}
            selection={selections.carpet}
            updateSelection={updateSelection}
          />
        </div>
        <div className='mt-6'>
          <div className='text-lg p-4 bg-gray-100 rounded shadow'>
            Turkish cat eating <i>{selections.cuisine}</i> on a flying <i>{selections.carpet}</i> carpet inside{' '}
            <i>{selections.landmark}</i>
          </div>
        </div>
        <div className='mt-4'>
          {!worldIdProof ? (
            <IDKitWidget
              signal={address}
              action='mint-nft'
              onSuccess={setWorldIdProof}
              app_id={process.env.NEXT_PUBLIC_WORLDCOIN_APP_ID!}
            >
              {({ open }) => (
                <button className='btn btn-secondary' onClick={open}>
                  Prove thy with World ID
                </button>
              )}
            </IDKitWidget>
          ) : (
            <>
              <button
                className='btn btn-primary'
                onClick={() =>
                  ipfsUrl
                    ? mintWrite?.()
                    : mintNFT(
                        `Turkish cat eating ${selections.cuisine} on a flying ${selections.carpet} carpet inside ${selections.landmark}`
                      )
                }
                disabled={isCIDLoading}
              >
                {isCIDLoading ? 'Drawing Meow...' : ipfsUrl ? 'Click to Mint Meow!' : 'Meow Meow~~'}
              </button>
              <div>{ipfsUrl && `${ipfsUrl}`}</div>
            </>
          )}
          {/* <button
          className='mt-4 px-6 py-2 bg-green-500 text-white rounded hover:bg-green-600 transition duration-300'
        >
          Mint Cat Button
        </button> */}
        </div>
      </div>
    </div>
  )
}
