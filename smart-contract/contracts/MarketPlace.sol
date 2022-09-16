// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
//import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "./NovelContract.sol";

error MarketPlace__NotOwner();
error MarketPlace__PriceNotMet(uint256 tokenId, uint256 price);
error MarketPlace__PriceMustBeAboveZero();
error MarketPlace__NotApproved(uint256 tokenId);
error ShouldNotApproved(uint256 tokenId);
error MarketPlace__NotListed(uint256 tokenId);
error AlreadyListed(uint256 tokenId);
error MarketPlace__AlreadySold(uint256 tokenId);
error MarketPlace__BuyerMustNotBeSeller();

contract MarketPlace is ReentrancyGuard {
    struct Item {
        uint256 itemId;
        uint256 tokenId;
        uint256 price;
        address payable seller;
        bool isSold;
    }

    address payable public immutable feeAccount;
    uint256 public immutable feePercentage;

    // Item count
    // Also represents itemId
    uint256 public itemCount;

    NovelContract private novelContract;

    // itemId => Item
    mapping(uint256 => Item) public items;

    // tokenId => itemId
    mapping(uint256 => uint256) public tokenIdToItemId;

    event ItemListed(
        uint256 indexed itemId,
        uint256 tokenId,
        uint256 price,
        address indexed seller
    );
    event ItemUpdated(
        uint256 indexed itemId,
        uint256 tokenId,
        uint256 price,
        address indexed seller
    );
    event ItemCanceled(uint256 indexed itemId, uint256 tokenId);
    event ItemSold(
        uint256 indexed itemId,
        uint256 tokenId,
        address indexed buyer
    );

    constructor(address contractAddress, uint256 _feePercentage) {
        feeAccount = payable(msg.sender);
        feePercentage = _feePercentage;
        novelContract = NovelContract(contractAddress);
    }

    modifier onlyTokenOwner(uint256 _tokenId) {
        uint256 senderBalance = novelContract.balanceOf(msg.sender, _tokenId);
        if (senderBalance > 0) {
            revert MarketPlace__NotOwner();
        }
        _;
    }

    modifier isItemListed(uint256 _tokenId) {
        uint256 itemId = tokenIdToItemId[_tokenId];
        if (itemId == 0) {
            revert MarketPlace__NotListed(_tokenId);
        }
        _;
    }

    modifier isPriceValid(uint256 _price) {
        if (_price == 0) {
            revert MarketPlace__PriceMustBeAboveZero();
        }
        _;
    }

    // modifier isTransferApproved(uint256 _tokenId) {
    //     if (novelContract.isApprovedForAll(novelContract.tokenIdToItemId[_tokenId]) != address(this)) {
    //         revert MarketPlace__NotApproved(_tokenId);
    //     }
    //     _;
    // }

    function listItem(uint256 _tokenId, uint256 _price)
        external
        onlyTokenOwner(_tokenId)
        isPriceValid(_price)
    {
        //novelContract.setApprovedForAll(address(this), true);
        uint256 itemId = tokenIdToItemId[_tokenId];
        if (itemId != 0) {
            revert AlreadyListed(_tokenId);
        }

        itemCount++;

        tokenIdToItemId[_tokenId] = itemCount;

        items[itemCount] = Item({
            itemId: itemCount,
            tokenId: _tokenId,
            price: _price,
            seller: payable(msg.sender),
            isSold: false
        });

        emit ItemListed(itemCount, _tokenId, _price, msg.sender);
    }

    function updateItem(uint256 _tokenId, uint256 _price)
        external
        onlyTokenOwner(_tokenId)
        isItemListed(_tokenId)
        isPriceValid(_price)
    {
        uint256 itemId = tokenIdToItemId[_tokenId];

        Item storage item = items[itemId];

        item.price = _price;

        emit ItemUpdated(itemId, _tokenId, _price, msg.sender);
    }

    function cancelItem(uint256 _tokenId)
        external
        onlyTokenOwner(_tokenId)
        isItemListed(_tokenId)
    {
        // // To make sure this contract can NOT transfer token when it is sold
        // if (novelContract.getApproved(_tokenId) != address(0)) {
        //     revert ShouldNotApproved(_tokenId);
        // }

        uint256 itemId = tokenIdToItemId[_tokenId];

        delete items[itemId];
        delete tokenIdToItemId[_tokenId];

        emit ItemCanceled(itemId, _tokenId);
    }

    function buyItem(uint256 _tokenId)
        external
        payable
        isItemListed(_tokenId)
        //isTransferApproved(_tokenId)
        nonReentrant
    {
        uint256 itemId = tokenIdToItemId[_tokenId];

        Item storage item = items[itemId];

        if (msg.value < item.price) {
            revert MarketPlace__PriceNotMet(_tokenId, item.price);
        }
        if (item.isSold) {
            revert MarketPlace__AlreadySold(_tokenId);
        }
        if (item.seller == msg.sender) {
            revert MarketPlace__BuyerMustNotBeSeller();
        }

        novelContract.safeTransferFrom(
            item.seller,
            msg.sender,
            _tokenId,
            1,
            ""
        );
        item.isSold = true;

        uint256 marketFee = calculateFee(item.price);

        item.seller.transfer(msg.value - marketFee);
        feeAccount.transfer(marketFee);

        emit ItemSold(itemId, _tokenId, msg.sender);
    }

    function calculateFee(uint256 _price) public view returns (uint256) {
        uint256 fee = ((_price / (1000)) * feePercentage) / (1 ether);
        //uint256 fee = _price(1000).mul(feePercentage.div(1 ether));

        return fee;
    }
}
