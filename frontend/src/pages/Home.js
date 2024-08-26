import { NavLink as Link } from 'react-router-dom';

function Home () {
    return (
        <div className="flex flex-col text-white text-6xl items-center justify-center w-full h-4/5">
            <div className="space-y-4 flex items-center flex-col">
                <div className="text-center">Sell / Re-Sell with 1 click</div>
                <div className="text-3xl">Sell or buy educational content in free market powered by fair price</div>
            </div>
            <div className="flex justify-center items-center h-40 w-full">
                <Link className='rounded-lg text-lg p-4 text-[#C7F284] bg-[#304256] font-semibold px-6' to='/swap'>Start Trading Now</Link>
            </div>
        </div>
    )
}

export default Home;