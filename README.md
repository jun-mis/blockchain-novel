# Functionality 
NovelContract:
- [ ] Base token will be ERC1155 which allows to mint series of tokens. 
- [ ] Number of tokens in certain series will be defined by the novel issuer. One novel could be sold with limited supply the same as with the book.
- [ ] Most of the content will be stored in metadata via URI.
- [ ] Metadata will have content which is compliant with OpenSea standard so novels would be able to sell also in OpenSea
- [ ] Availability to store image
- [ ] The content can be updated by novel issuer via storeURI function until it is not completed.
- [ ] The main content of novel will be stored in separated URI which will be mapped to certain tokenId. 
- [ ] The main content will be displayed only to the ERC1155 token owner on our marketplace
- [ ] Potential configurable fees for deployments
- Necessary setter functions:
  - createNovel
  - addContent (setURI)
  - completeNovel

- Neccessary libraries:
  - ERC1155 URI
  - Ownable

- Frontend:
  - [ ] needs to have ability to store metadata in the IPFS (best via NFT storage or pinata) (sripts will be done in smart contract utils)
  - [ ] needs to have ability to read metadata from IPFS 

MarketPlace:
- [ ] Item list storage
- [ ] Listing, modifying and canceling functionality
- [ ] Buying, selling functionality

Vault - smart contract which allows to keep user's funds inside and pay for using protocol without signing transaction every time:
- [ ] deposit native token (matic)
- [ ] withdraw
- [ ] paying system