require("@nomiclabs/hardhat-waffle")
require("hardhat-gas-reporter")
require("@nomiclabs/hardhat-etherscan")
require("dotenv").config()
require("solidity-coverage")
require("hardhat-deploy")

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more
/**
 * @type import('hardhat/config').HardhatUserConfig
 */

const MAINNET_RPC_URL = process.env.MAINNET_RPC_URL || process.env.ALCHEMY_MAINNET_RPC_URL || ""
const COINMARKETCAP_API_KEY = process.env.COINMARKETCAP_API_KEY || ""
const RINKEBY_RPC_URL =
    process.env.RINKEBY_RPC_URL ||
    "https://eth-mainnet.alchemyapi.io/v2/your-api-key"
const GOERLI_RPC_URL =
    process.env.GOERLI_RPC_URL ||
    "https://eth-mainnet.alchemyapi.io/v2/your-api-key"
const PRIVATE_KEY =
    process.env.PRIVATE_KEY ||
    "0x11111118a03081fe260ecdc106554d09d9d1209bcafd46942555555555666666"
const PRIVATE_KEY1 = process.env.PRIVATE_KEY1 || "0x21111118a03081fe260ecdc106554d09d9d1209bcafd46942555555555666666"
const PRIVATE_KEY2 = process.env.PRIVATE_KEY2 || "0x31111118a03081fe260ecdc106554d09d9d1209bcafd46942555555555666666"
const ETHERSCAN_API_KEY = process.env.ETHERSCAN_API_KEY || ""
const POLYGONSCAN_API_KEY = process.env.POLYGONSCAN_API_KEY || ""

module.exports = {
    defaultNetwork: "hardhat",
    networks: {
        hardhat: {
            chainId: 31337,
            forking: {
                url: MAINNET_RPC_URL,
            },
        },
        rinkeby: {
            url: RINKEBY_RPC_URL,
            accounts: [PRIVATE_KEY, PRIVATE_KEY1, PRIVATE_KEY2],
            chainId: 4,
            blockConfirmations: 6,
        },
        goerli: {
            url: GOERLI_RPC_URL,
            accounts: [PRIVATE_KEY, PRIVATE_KEY1, PRIVATE_KEY2],
            chainId: 5,
            blockConfirmations: 6,
        },
        polygonMumbai: {
            url: "https://rpc-mumbai.maticvigil.com",
            accounts: [PRIVATE_KEY, PRIVATE_KEY1, PRIVATE_KEY2],
            chainId: 80001,
            blockConfirmations: 6,
        },

    },
    solidity: {
        // multiple versions of compilers
        compilers: [
            {
                version: "0.8.9",
            },
            {
                version: "0.6.2",
            },
        ],
    },
    etherscan: {
        apiKey: {
            rinkeby: ETHERSCAN_API_KEY,
            polygonMumbai: POLYGONSCAN_API_KEY
        }
    },
    gasReporter: {
        enabled: true,
        currency: "USD",
        outputFile: "gas-report.txt",
        noColors: true,
        // coinmarketcap: COINMARKETCAP_API_KEY,
    },
    namedAccounts: {
        deployer: {
            default: 0,
            1: 0,
        },
    },
    mocha: {
        timeout: 500000, // 500 seconds max for running tests
    },
}
