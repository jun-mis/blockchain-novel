// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/* Errors */
error NovelContract__NotAllowedToAddContent(uint256 tokenId);
error NovelContract__NotAllowedToComplete(uint256 tokenId);
error NovelContract__NovelNotExists(uint256 tokenId);
error NovelContract__NovelAlreadyCompleted(uint256 tokenId);
error NovelContract__NotCreator(uint256 tokenId);
error NovelContract__NovelAlreadyExist();
error NovelContract__InvalidInput();

/* Data structures and enums */
struct Novel {
    uint256 tokenId;
    address creator;
    category category;
    string language;
    bool isCompleted;
    uint256 createdAt;
    uint256 updatedAt;
}

enum category {
    ADVENTURE,
    CHICKLICK,
    FANFICTION,
    GENERAL_FICTION,
    HISTORICAL_FICTION,
    HORROR,
    ISEKAI,
    MYSTERY_THRILLER,
    ESSAY,
    POETRY,
    ROMANCE,
    OTHER
}

/**@title Novel contract which allow to issue novels in safe and decentralised way
 * @author Kamil Palenik (xRave110)
 * @dev Based on ERC1155, implements its own URI mapping, Pausable
 */
contract NovelContract is ERC1155, Ownable {
    /* Events */
    event NovelCreated(bytes32 indexed novelId, string title);
    event NovelCompleted(bytes32 indexed novelId);
    event ContentAdded(bytes32 indexed novelId, uint256 indexed tokenId);

    /**IPFS storage
     * Name : novel title
     * Description: summary
     * Image: ipfs link
     * External_url: marketplace website
     */

    /**Centralized server storage (temporary solution - must be visible only for ERC1155 owners)
     * Main content
     */

    /* Blockchain storage */
    uint256 private tokenId;
    mapping(address => uint256[]) private creatorToTokenIds;
    Novel[] private novels;
    string[] private uris;
    uint256 transferFee = 0;

    /* Modifiers */
    modifier onlyCreator(uint256 _tokenId) {
        uint256 idx;
        bool found = false;
        for (idx = 0; idx < creatorToTokenIds[msg.sender].length; idx++) {
            if (creatorToTokenIds[msg.sender][idx] == _tokenId) {
                found = true;
            }
        }
        if (!found) {
            revert NovelContract__NotCreator(_tokenId);
        }
        _;
    }

    // modifier novelExists(uint256 _tokenId) {
    //     uint256[] memory tokenIds = novelHashToTokenIds[_tokenId];
    //     if (tokenIds.length == 0) {
    //         revert NovelContract__NovelNotExists(_novelId);
    //     }
    //     _;
    // }

    modifier isNotEmpty(string memory input) {
        if (bytes(input).length == 0) {
            revert NovelContract__InvalidInput();
        }
        _;
    }

    modifier novelNotCompleted(uint256 _tokenId) {
        if (novels[_tokenId].isCompleted) {
            revert NovelContract__NovelAlreadyCompleted(_tokenId);
        }
        _;
    }

    constructor(string memory _uri) ERC1155(_uri) {}

    /**
     *
     */
    function setTransferFee(uint256 _fee) public onlyOwner {}

    /**
     *
     */
    function createNovel(
        uint256 _amount,
        category _category,
        string memory _language,
        string memory _uri
    ) external isNotEmpty(_language) isNotEmpty(_uri) {
        tokenId++; //novels.length
        creatorToTokenIds[msg.sender].push(tokenId);
        // bytes32 novelHash = keccak256(
        //     abi.encodePacked(msg.sender, _amount, tokenId)
        // );

        novels.push(
            Novel({
                tokenId: tokenId, //novels.length
                creator: msg.sender,
                category: _category,
                language: _language, // can be byte arrays
                isCompleted: false,
                createdAt: block.timestamp,
                updatedAt: block.timestamp
            })
        );

        // NovelContent memory newContent = NovelContent({
        //     tokenId: tokenId,
        //     parentId: FIRST_CONTENT_PARENT_ID,
        //     content: _newNovel.content,
        //     creator: msg.sender,
        //     createdAt: block.timestamp
        // });

        // ??
        // novelHashToTokenIds[novelHash].push(tokenId);

        // novelHashToIndex[novelHash] = tokenId;

        _mint(msg.sender, tokenId, _amount, "");
        _setNovelUri(tokenId, _uri);
        //emit NovelCreated(novelHash, _newNovel.title);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public virtual override {}

    function modifyContent(
        uint256 _tokenId,
        category _category,
        string memory _language,
        string memory _uri
    ) external onlyCreator(_tokenId) novelNotCompleted(_tokenId) {
        Novel storage novelToModify = novels[_tokenId];
        //How to update metadata ?
        novelToModify.category = _category;
        novelToModify.language = _language;
        novelToModify.updatedAt = block.timestamp;
        _setNovelUri(tokenId, _uri);
        // NovelContent memory newContent = NovelContent({
        //     tokenId: tokenId,
        //     parentId: _parentId,
        //     content: _content,
        //     creator: msg.sender,
        //     createdAt: block.timestamp
        // });

        // newContent;
        // novelHashToTokenIds[_novelId].push(tokenId);

        // _safeMint(msg.sender, tokenId);
        // // burn so that token cannot be sold again
        // _burn(_parentId);

        // uint256 novelIndex = novelHashToIndex[_novelId];

        // Novel storage novelToUpdate = novels[novelIndex];
        // novelToUpdate.updatedAt = block.timestamp;

        // emit ContentAdded(_novelId, tokenId);
    }

    function completeNovel(uint256 _tokenId) external onlyCreator(_tokenId) {
        novels[_tokenId].isCompleted = true;
    }

    /**
     *
     */
    function _setNovelUri(uint256 _tokenId, string memory _uri)
        private
        onlyCreator(tokenId)
    {
        uris[_tokenId] = _uri;
    }

    // function canAddContent(uint256 _tokenId) public view returns (bool) {
    //     bool _isContentCreator = isContentCreator(_tokenId);
    //     bool _isTokenOwner = isTokenOwner(_tokenId);

    //     return _isTokenOwner && !_isContentCreator;
    // }

    // function isAllowedToComplete(bytes32 _novelId)
    //     public
    //     view
    //     novelNotCompleted(_novelId)
    //     returns (bool)
    // {
    //     uint256[] memory _tokenIds = novelHashToTokenIds[_novelId];
    //     uint256 lastIndex = _tokenIds.length - 1;

    //     return isTokenOwner(_tokenIds[lastIndex]);
    // }

    function isTokenOwner(address _account, uint256 _tokenId)
        private
        view
        returns (bool)
    {
        return balanceOf(_account, _tokenId) > 0 ? true : false;
    }

    function getAllNovels() external view returns (Novel[] memory) {
        Novel[] memory _novels = novels;
        return _novels;
    }

    function uri(uint256 _tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        return uris[_tokenId];
    }

    function getNovelIdsByCreator(address _creator)
        external
        view
        returns (uint256[] memory)
    {
        return creatorToTokenIds[_creator];
    }
}
