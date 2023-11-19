import { useEffect, useState } from 'react'

export function useGetNFT(address: string | undefined) {
  const [data, setData] = useState<{ tokenId: string; tokenUri: string } | undefined>()
  const [isLoading, setIsLoading] = useState(false)
  const [error, setError] = useState<any>(null)

  useEffect(() => {
    if (!address) return

    const fetchData = async () => {
      setIsLoading(true)
      try {
        const options = { method: 'GET', headers: { accept: 'application/json' } }

        let res = await fetch(
          `https://base-goerli.g.alchemy.com/nft/v3/${process.env.NEXT_PUBLIC_ALCHEMY_API_KEY}/getNFTsForOwner?owner=${address}&contractAddresses[]=${process.env.NEXT_PUBLIC_CONTRACT_ADDR_NFT}&withMetadata=true&pageSize=100`,
          options
        )
        res = await res.json()

        const { tokenId, tokenUri } = res.ownedNfts[0]
        console.log({ tokenId, tokenUri })
        setData({ tokenId, tokenUri })
      } catch (error) {
        console.error(error)
        setError(error)
      } finally {
        setIsLoading(false)
      }
    }

    fetchData()
  }, [address])

  return { data, isLoading, error }
}
