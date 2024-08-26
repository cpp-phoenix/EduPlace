import {NFT_CONTRACTS, NFTS_LIST} from '../constants.js'
import { useAccount, useNetwork, useBalance, useWalletClient, usePublicClient } from 'wagmi'
import { NavLink as Link } from 'react-router-dom';
import { ethers } from "ethers";
import NFTABI from '../NFTABI.json';
import ERC20ABI from '../ERC20ABI.json';

function Faucet () {
    const {address} = useAccount()
    const {chain} = useNetwork()

    const { data: signer } = useWalletClient();

    const mintNFT = async (nftContractAddr) => {
        const provider = new ethers.JsonRpcProvider(NFT_CONTRACTS[chain.id].rpc);
        const nftContract = new ethers.Contract(nftContractAddr, NFTABI, provider);

        const signedNFTContract = nftContract.connect(signer)

        try {
            await signedNFTContract.bulkSafeMint(100);
        } catch (e) {

        }
    }

    const mintEDP = async () => {
        const provider = new ethers.JsonRpcProvider(NFT_CONTRACTS[chain.id].rpc);
        const EDPTokenContract = new ethers.Contract(NFT_CONTRACTS[chain.id].EDPToken, ERC20ABI, provider);

        const signedEDPTokenContract = EDPTokenContract.connect(signer)

        try {
            await signedEDPTokenContract.mint(ethers.parseUnits("100","ether"));
        } catch (e) {
            console.log(e)
        }
    }

    return (
        <div className="flex flex-col text-white items-center justify-center w-full h-4/5">
            <div className="border border-white/5 rounded-[16px] flex flex-col items-center justify-center w-[500px] h-[400px] bg-[#304256] text-xl  space-y-8">
                <div className='space-y-8'>
                {
                    NFTS_LIST.map(nft => {
                        return (
                            <div className="flex justify-between items-center w-[450px]">
                                <div onClick={() => {navigator.clipboard.writeText(NFT_CONTRACTS[chain.id][nft].contractAddress)}} className='cursor-pointer text-2xl'>Mint 100 {nft} </div>
                                <button onClick={() => mintNFT(NFT_CONTRACTS[chain.id][nft].contractAddress)} className='rounded-lg hover:border hover:border-[#C7F284] bg-[#121D28] text-[#C7F284] p-4 px-16'>Mint</button>
                            </div>
                        )
                    })
                }
                </div>
                <div className="flex justify-between items-center w-[450px]">
                    <div onClick={() => {navigator.clipboard.writeText(NFT_CONTRACTS[chain.id]["EDPToken"])}} className='cursor-pointer text-2xl'>Mint 100 $EDP Tokens</div>
                    <button onClick={() => mintEDP()} className='rounded-lg hover:border hover:border-[#C7F284] bg-[#121D28] text-[#C7F284] p-4 px-16'>Mint</button>
                </div>
            </div>
        </div>
    )
}

export default Faucet;