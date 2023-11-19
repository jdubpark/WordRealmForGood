import { utils } from 'ethers'

export const decode = <T>(type: string, encodedString: string): T => {
  // @ts-ignore
  return utils.defaultAbiCoder.decode([type], encodedString)[0]
}
