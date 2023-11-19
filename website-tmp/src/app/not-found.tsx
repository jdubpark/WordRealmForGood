import { ErrorCard } from '~/components/common/ErrorCard'

export default function NotFoundPage() {
  return (
    <div className='mt-n3 container'>
      <ErrorCard text='Page not found' />
    </div>
  )
}
