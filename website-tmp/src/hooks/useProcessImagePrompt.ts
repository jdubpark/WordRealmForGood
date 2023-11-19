import axios from 'axios'
import { useEffect, useState } from 'react'

export function useProcessImagePrompt(prompt: string) {
  const [data, setData] = useState<string | undefined>()
  const [isLoading, setIsLoading] = useState(false)
  const [error, setError] = useState<any>(null)

  useEffect(() => {
    if (!prompt) return

    const fetchData = async () => {
      setIsLoading(true)
      try {
        const response = await axios.post<string>(
          'http://127.0.0.1:5000/process_string',
          { image_prompt: prompt },
          { headers: { 'Content-Type': 'application/json' } }
        )
        setData(response.data)
      } catch (error) {
        setError(error)
      } finally {
        setIsLoading(false)
      }
    }

    fetchData()
  }, [prompt])

  return { data: data ? `https://${data}.ipfs.nftstorage.link/` : undefined, isLoading, error }
}
