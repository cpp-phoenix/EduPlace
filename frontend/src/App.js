import logo from './logo.svg';
import './App.css';
import '@rainbow-me/rainbowkit/styles.css';

import {
  getDefaultWallets,
  RainbowKitProvider,
} from '@rainbow-me/rainbowkit';
import { configureChains, createConfig, WagmiConfig } from 'wagmi';
import { publicProvider } from 'wagmi/providers/public';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import Navbar from './components/Navbar';
import Faucet from './pages/Faucet';
import Home from './pages/Home';
import Liquidity from './pages/Liquidity';
import Trade from './pages/Trade';

export const filecoin = {
  id: 656_476,
  name: 'EDU Testnet',
  network: 'EDU',
  iconUrl: 'https://www.opencampus.xyz/static/media/coin-logo.39cbd6c42530e57817a5b98ac7621ca7.svg',
  nativeCurrency: {
    decimals: 18,
    name: 'EDU',
    symbol: 'EDU',
  },
  rpcUrls: {
    public: { http: ['https://rpc.open-campus-codex.gelato.digital'] },
    default: { http: ['https://rpc.open-campus-codex.gelato.digital'] },
  },
  blockExplorers: {
    etherscan: { name: 'opencampus', url: 'https://opencampus-codex.blockscout.com/' },
    default: { name: 'opencampus', url: 'https://opencampus-codex.blockscout.com/' },
  },
}

const { chains, publicClient } = configureChains(
  [filecoin],
  [
    publicProvider()
  ]
);

const { connectors } = getDefaultWallets({
  appName: 'EduPlace',
  projectId: '6160c615f05244c0838315aec9610295',
  chains
});

const wagmiConfig = createConfig({
  autoConnect: true,
  connectors,
  publicClient
})

function App() {
  return (
    <WagmiConfig config={wagmiConfig}>
      <RainbowKitProvider chains={chains}>
        <div className="bg-[#1d2839] w-screen h-screen">
          <Router>
            <Navbar/>  
            <Routes>
              <Route path='/' exact element={<Home/>}/>
              <Route path='/faucet' exact element={<Faucet/>}/>
              <Route path='/liquidity' exact element={<Liquidity/>}/>
              <Route path='/trade' exact element={<Trade/>}/>
            </Routes>
          </Router>
        </div>  
      </RainbowKitProvider>
    </WagmiConfig>
  );
}

export default App;
