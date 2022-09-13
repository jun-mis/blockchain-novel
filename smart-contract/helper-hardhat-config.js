const networkConfig = {
    31337: {
        name: "localhost",
        weth: "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2"
    },
    // Price Feed Address, values can be obtained at https://docs.chain.link/docs/reference-contracts
    // Default one is ETH/USD contract on Kovan
    80001: {
        name: "polygonMumbai",
        usdc: "0xe6b8a5CF854791412c1f6EFC7CAf629f5Df1c747",
        weth: "0xA6FA4fB5f76172d178d61B04b0ecd319C5d1C0aa",
    },
    // Price Feed Address, values can be obtained at https://docs.chain.link/docs/reference-contracts
    // Default one is ETH/USD contract on Kovan
    4: {
        name: "rinkeby",
        ethUsdPriceFeed: "0x8A753747A1Fa494EC906cE90E9f37563A8AF630e",
        usdc: "0xeb8f08a975Ab53E34D8a0330E0D34de942C95926",
        weth: "0xc778417E063141139Fce010982780140Aa0cD5Ab",
    },
    5: {
        name: "goerli",
        ethUsdPriceFeed: "0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e",
        usdc: "0x2f3A40A3db8a7e3D09B0adfEfbCe4f6F81927557",
        weth: "0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6",
    }
}

const developmentChains = ["hardhat", "localhost"]

module.exports = {
    networkConfig,
    developmentChains,
}
