// Import the NFTStorage class and File constructor from the 'nft.storage' package
const { NFTStorage, File } = require("nft.storage")
const mime = require("mime")
const fs = require("fs")
const path = require("path")
require("dotenv").config()

const NFT_STORAGE_KEY = process.env.NFT_STORAGE_KEY

/**
 * Reads an image file from `imagePath` and stores an NFT with the given name and description.
 * @param {string} 
 * @param {string} 
 * @param {string} 
 */

async function storeNFT(fullImagePath, title, summary, external_url, category) {
    console.log(fullImagePath)

    console.log("Uploading to IPFS!")
    const image = await fileFromPath(fullImagePath)
    const name = `Ownly tweet ${tweetId}`
    const nftstorage = new NFTStorage({ token: NFT_STORAGE_KEY })

    const response = await nftstorage.store({
        image,
        name: title,
        description: summary,
        external_url: external_url,
        attributes: [{ trait_type: 'category', value: category }]
        // Currently doesn't support attributes 
    })
    return response
}

/**
 * A helper to read a file from a location on disk and return a File object.
 * Note that this reads the entire file into memory and should not be used for
 * very large files.
 * @param {string} filePath the path to a file to store
 * @returns {File} a File object containing the file content
 */
async function fileFromPath(filePath) {
    const content = await fs.promises.readFile(filePath)
    const type = mime.getType(filePath)
    return new File([content], path.basename(filePath), { type })
}

module.exports = {
    storeNFTs, storeNFT
}