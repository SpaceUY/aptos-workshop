# 🌟 Galactic Sticker Packs Workshop

Welcome to the **Galactic Sticker Packs** workshop! This is a complete project that will teach you how to build a gamified NFT application on Aptos using Move and React.

## 🎯 Concept

**Galactic Sticker Packs** is an NFT collection game where users can:

- **Buy packs** for 0.1 APT each
- **Open packs** to reveal 3 random NFTs
- **Collect galactic characters** with different rarity levels
- **View their collection** in an interactive gallery

### 🎮 Game Features

- **3 unique collections**: Alien, Predator, Yoda
- **6 rarity levels**: Common (30%), Uncommon (25%), Rare (20%), Epic (12%), Legendary (8%), Mythic (5%)

## 🏗️ Project Architecture

```
├── galactic-warriors-web/    //web to interact
├── move/                     //aptos modules
└── README.md
```

## 🚀 Initial Setup

### Prerequisites

1. **Node.js** (version 16 or higher)
2. **Aptos CLI** installed
3. **Petra Wallet** (browser extension)

### Installation

1. **Clone the repository**:

   ```bash
   git clone <repository-url>
   cd galactic-sticker-packs
   ```

2. **Install dependencies**:

   ```bash
   npm install
   ```

3. **Configure Aptos CLI**:
   ```bash
   aptos init --network testnet --profile default --assume-yes
   ```

## 🎯 Workshop Steps

### Step 1: Set Up Wallet

1. **Install Petra Wallet**:

   - Go to [petra.app](https://petra.app)
   - Install the browser extension
   - Create a new account

2. **Get testnet APT**:
   - Go to [aptos.dev/network/faucet](https://aptos.dev/network/faucet)
   - Request testnet APT for your address

### Step 2: Deploy Move Module

1. **Test, compile and deploy the module**:

   ```bash
   aptos move test
   ```

   ```bash
   aptos move compile --named-addresses galactic_workshop=<your_account_address>
   ```

   <!-- https://aptos.dev/build/smart-contracts/deployment -->

   Deploy the compiled code to an object via the command:

   ```bash
   aptos move compile --named-addresses galactic_workshop=<your_account_address>
   ```

   ```bash
   aptos move deploy-object --address-name galactic_workshop
   ```

### Step 3: Run Web Application

1. **Set envireoment vars**:

   - Go to [geomi.dev/](https://geomi.dev/)
   - Create new project
   - Create New API Resource (testnet)
   - Set it as APTOS_API_KEY in .env.local
   - CREATOR_PRIVATE_KEY should be defined in move/.aptos/config.yaml as private_key (after aptos init)

2. **Start development server**:

   ```bash
   npm run dev
   ```

3. **Open your browser** at `http://localhost:3000`

### Step 4: Interact with the Game

1. **Connect your wallet** using the "Connect with Petra" button
2. **Buy a pack** for 0.1 APT
3. **Open the pack** to reveal your NFTs
4. **Explore your gallery** to see your collection

## 🔧 Technical Features

### Move Module (`galactic_packs.move`)

- **`init_module()`**: Initializes the game by creating NFT collections and minting packs
- **`buy_pack()`**: Allows buying a pack for 0.1 APT
- **`open_pack()`**: Opens a pack and generates 3 random NFTs with balanced rarity
- **Rarity system**: tier rarity system with weighted probabilities
- **Supply limit**: Maximum 100 packs available

### React Application

- **Wallet Integration**: Connection with Petra Wallet
- **Mulit-agent Trensaction**: Signatures from server and client

## 🎯 Learning Objectives

After completing this workshop, you will learn:

1. **Move Development**: Structures, functions, and resources
2. **NFT Tokens**: Aptos Token v2 standard
3. **Web3 Integration**: Connection with wallets and blockchain
4. **Blockchain APIs**: GraphQL queries to Indexer

## 📚 Additional Resources

- [Aptos Documentation](https://aptos.dev)
- [Move Guide](https://move-language.github.io/move/)
- [Aptos Token Standard](https://github.com/aptos-labs/aptos-core/blob/main/aptos-move/framework/aptos-token/doc/overview.md)

---

Enjoy building your galactic collection! 🌟🚀
