// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
// To be removed import "hardhat/console.sol";

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
    string uri;
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
    event NovelCreated(uint256 indexed tokenId, string uri);
    event NovelCompleted(uint256 indexed tokenId);
    event ContentAdded(uint256 indexed tokenId);

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
    mapping(address => uint256[]) private creatorToTokenIds;
    Novel[] private novels;
    mapping(uint256 => string) uris;
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
    function createNovel(uint256 _amount, string memory _uri)
        external
        isNotEmpty(_uri)
    {
        uint256 tokenId = novels.length;
        // bytes32 novelHash = keccak256(
        //     abi.encodePacked(msg.sender, _amount, tokenId)
        // );
        novels.push(
            Novel({
                tokenId: tokenId, //novels.length
                creator: msg.sender,
                uri: _uri,
                isCompleted: false,
                createdAt: block.timestamp,
                updatedAt: block.timestamp
            })
        );
        _mint(msg.sender, tokenId, _amount, "");
        _setNovelUri(tokenId, _uri);
        emit NovelCreated(tokenId, _uri);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public virtual override {}

    function modifyContent(uint256 _tokenId, string memory _uri)
        external
        onlyCreator(_tokenId)
        novelNotCompleted(_tokenId)
    {
        Novel storage novelToModify = novels[_tokenId];
        //How to update metadata ?
        novelToModify.uri = _uri;
        novelToModify.updatedAt = block.timestamp;
        _setNovelUri(_tokenId, _uri);
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

        emit ContentAdded(_tokenId);
    }

    function completeNovel(uint256 _tokenId) external onlyCreator(_tokenId) {
        novels[_tokenId].isCompleted = true;
        emit NovelCompleted(_tokenId);
    }

    /**
     *
     */
    function _setNovelUri(uint256 _tokenId, string memory _uri) private {
        Novel storage novel = novels[_tokenId];
        novel.uri = _uri;
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
