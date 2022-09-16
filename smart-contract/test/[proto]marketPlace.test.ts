import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expect } from "chai";
import { BigNumber } from "ethers";
import { ethers } from "hardhat";
// eslint-disable-next-line node/no-missing-import
import { NovelContract, MarketPlace } from "../typechain";
// eslint-disable-next-line node/no-missing-import
import { NEW_NOVEL, ETH_10 } from "./helpers";

describe("MarketPlace", () => {
  let novelContract: NovelContract;
  let marketPlace: MarketPlace;
  let owner: SignerWithAddress;
  let seller: SignerWithAddress;
  let buyer: SignerWithAddress;
  let otherSigners: SignerWithAddress[];

  const tokenId = BigNumber.from(1);

  beforeEach(async () => {
    [owner, seller, buyer, ...otherSigners] = await ethers.getSigners();

    const NovelContractFactory = await ethers.getContractFactory(
      "NovelContract"
    );
    novelContract = await NovelContractFactory.deploy("Novel", "NVL");
    await novelContract.deployed();

    const MarketPlaceFactory = await ethers.getContractFactory("MarketPlace");
    marketPlace = await MarketPlaceFactory.deploy(
      novelContract.address,
      ethers.utils.parseEther("25")
    );
    await marketPlace.deployed();

    // Create novel
    await novelContract.connect(seller).createNovel(NEW_NOVEL);
  });

  describe("listItem", () => {
    beforeEach(async () => {
      await novelContract.connect(seller).approve(marketPlace.address, tokenId);
    });

    it("should list item", async () => {
      let itemCount = await marketPlace.itemCount();
      expect(itemCount).to.equal(BigNumber.from(0));

      await expect(marketPlace.connect(seller).listItem(tokenId, ETH_10)).not.to
        .be.reverted;

      const expected = [
        BigNumber.from(1),
        tokenId,
        ETH_10,
        seller.address,
        false,
      ];

      const item = await marketPlace.items(BigNumber.from(1));

      expect(item).to.deep.equal(expected);

      itemCount = await marketPlace.itemCount();
      expect(itemCount).to.equal(BigNumber.from(1));
    });

    it("should emit ItemListed", async () => {
      const result = await marketPlace
        .connect(seller)
        .listItem(tokenId, ETH_10);

      expect(result)
        .to.emit(marketPlace, "ItemListed")
        .withArgs(BigNumber.from(1), tokenId, ETH_10, seller.address);
    });

    it("should revert NotOwner if not token owner", async () => {
      await expect(
        marketPlace.connect(otherSigners[0]).listItem(tokenId, ETH_10)
      ).to.be.revertedWith("NotOwner");
    });

    it("should revert PriceMustBeAboveZero if price is zero", async () => {
      await expect(
        marketPlace.connect(seller).listItem(tokenId, 0)
      ).to.be.revertedWith("PriceMustBeAboveZero");
    });

    it("should revert AlreadyListed if already listed", async () => {
      await marketPlace.connect(seller).listItem(tokenId, ETH_10);
      await expect(
        marketPlace.connect(seller).listItem(tokenId, ETH_10)
      ).to.be.revertedWith(`AlreadyListed(${tokenId})`);
    });

    it("should revert NotApproved if not approved", async () => {
      const newTokenId = BigNumber.from(2);
      await novelContract.connect(seller).createNovel(NEW_NOVEL);

      await expect(
        marketPlace.connect(seller).listItem(newTokenId, ETH_10)
      ).to.be.revertedWith(`NotApproved(${newTokenId})`);
    });
  });

  describe("updateItem", () => {
    const newPrice = ethers.utils.parseEther("12");

    beforeEach(async () => {
      await novelContract.connect(seller).approve(marketPlace.address, tokenId);
      await marketPlace.connect(seller).listItem(tokenId, ETH_10);
    });

    it("should update item", async () => {
      let item = await marketPlace.items(BigNumber.from(1));

      expect(item).to.deep.equal([
        BigNumber.from(1),
        tokenId,
        ETH_10,
        seller.address,
        false,
      ]);

      await expect(marketPlace.connect(seller).updateItem(tokenId, newPrice))
        .not.to.be.reverted;

      const expected = [
        BigNumber.from(1),
        tokenId,
        newPrice,
        seller.address,
        false,
      ];

      item = await marketPlace.items(BigNumber.from(1));

      expect(item).to.deep.equal(expected);
    });

    it("should emit ItemUpdated", async () => {
      const result = await marketPlace
        .connect(seller)
        .updateItem(tokenId, newPrice);

      expect(result)
        .to.emit(marketPlace, "ItemUpdated")
        .withArgs(BigNumber.from(1), tokenId, newPrice, seller.address);
    });

    it("should revert NotOwner if not token owner", async () => {
      await expect(
        marketPlace.connect(otherSigners[0]).updateItem(tokenId, newPrice)
      ).to.be.revertedWith("NotOwner");
    });

    it("should revert PriceMustBeAboveZero if price is zero", async () => {
      await expect(
        marketPlace.connect(seller).updateItem(tokenId, 0)
      ).to.be.revertedWith("PriceMustBeAboveZero");
    });

    it("should revert NotListed if not listed", async () => {
      const newTokenId = BigNumber.from(2);
      await novelContract.connect(seller).createNovel(NEW_NOVEL);
      await novelContract
        .connect(seller)
        .approve(marketPlace.address, newTokenId);
      await expect(
        marketPlace.connect(seller).updateItem(newTokenId, newPrice)
      ).to.be.revertedWith(`NotListed(${newTokenId})`);
    });
  });

  describe("cancelItem", () => {
    beforeEach(async () => {
      await novelContract.connect(seller).approve(marketPlace.address, tokenId);
      await marketPlace.connect(seller).listItem(tokenId, ETH_10);
      await novelContract
        .connect(seller)
        .approve(ethers.constants.AddressZero, tokenId);
    });

    it("should camcel item", async () => {
      await expect(marketPlace.connect(seller).cancelItem(tokenId)).not.to.be
        .reverted;

      const expected = [
        BigNumber.from(0),
        BigNumber.from(0),
        BigNumber.from(0),
        ethers.constants.AddressZero,
        false,
      ];

      const item = await marketPlace.items(BigNumber.from(1));

      expect(item).to.deep.equal(expected);
    });

    it("should emit ItemCanceled", async () => {
      const result = await marketPlace.connect(seller).cancelItem(tokenId);

      expect(result)
        .to.emit(marketPlace, "ItemCanceled")
        .withArgs(BigNumber.from(1), tokenId);
    });

    it("should revert NotOwner if not token owner", async () => {
      await expect(
        marketPlace.connect(otherSigners[0]).cancelItem(tokenId)
      ).to.be.revertedWith("NotOwner");
    });

    it("should revert NotListed if not listed", async () => {
      const newTokenId = BigNumber.from(2);
      await novelContract.connect(seller).createNovel(NEW_NOVEL);
      await novelContract
        .connect(seller)
        .approve(marketPlace.address, newTokenId);
      await expect(
        marketPlace.connect(seller).cancelItem(newTokenId)
      ).to.be.revertedWith(`NotListed(${newTokenId})`);
    });

    it("should revert ShouldNotApproved if price is zero", async () => {
      const newTokenId = BigNumber.from(2);
      await novelContract.connect(seller).createNovel(NEW_NOVEL);
      await novelContract
        .connect(seller)
        .approve(marketPlace.address, newTokenId);
      await marketPlace.connect(seller).listItem(newTokenId, ETH_10);

      await expect(
        marketPlace.connect(seller).cancelItem(newTokenId)
      ).to.be.revertedWith(`ShouldNotApproved(${newTokenId})`);
    });
  });

  describe("buyItem", () => {
    const INITIAL_BALANCE = ethers.utils.parseEther("10000");
    const newTokenId = BigNumber.from(2);

    beforeEach(async () => {
      await novelContract.connect(seller).approve(marketPlace.address, tokenId);
      await marketPlace.connect(seller).listItem(tokenId, ETH_10);
    });

    it("should buy item", async () => {
      let tokenBalance = await novelContract.balanceOf(buyer.address);
      expect(tokenBalance).to.deep.equal(BigNumber.from(0));
      const sellerBalanceBefore = await ethers.provider.getBalance(
        seller.address
      );

      let buyerBalance = await ethers.provider.getBalance(buyer.address);
      expect(buyerBalance).to.deep.equal(INITIAL_BALANCE);

      await expect(
        marketPlace.connect(buyer).buyItem(tokenId, { value: ETH_10 })
      ).not.to.be.reverted;

      tokenBalance = await novelContract.balanceOf(buyer.address);
      expect(tokenBalance).to.deep.equal(BigNumber.from(1));

      buyerBalance = await ethers.provider.getBalance(buyer.address);
      expect(Number(buyerBalance.toString())).to.lessThan(
        Number(INITIAL_BALANCE.toString())
      );

      const sellerBalanceAfter = await ethers.provider.getBalance(
        seller.address
      );
      expect(Number(sellerBalanceAfter.toString())).to.be.greaterThan(
        Number(sellerBalanceBefore.toString())
      );
    });

    it("should send 2.5%(0.25ETH) to MarketPlce contract", async () => {
      const ownerBalanceBefore = await ethers.provider.getBalance(
        owner.address
      );

      await expect(
        marketPlace.connect(buyer).buyItem(tokenId, { value: ETH_10 })
      ).not.to.be.reverted;

      const ownerBalanceAfter = await ethers.provider.getBalance(owner.address);

      const difference = ownerBalanceAfter.sub(ownerBalanceBefore);
      const fee = ethers.utils.parseEther("25").div(100);
      expect(difference).to.deep.equal(fee);
    });

    it("should emit ItemSold", async () => {
      const result = await marketPlace
        .connect(buyer)
        .buyItem(tokenId, { value: ETH_10 });

      expect(result)
        .to.emit(marketPlace, "ItemSold")
        .withArgs(BigNumber.from(1), tokenId, buyer.address);
    });

    it("should revert NotListed if not listed", async () => {
      await novelContract.connect(seller).createNovel(NEW_NOVEL);
      await novelContract
        .connect(seller)
        .approve(marketPlace.address, newTokenId);
      await expect(
        marketPlace.connect(buyer).buyItem(newTokenId)
      ).to.be.revertedWith(`NotListed(${newTokenId})`);
    });

    it("should revert NotApproved if not approved", async () => {
      await novelContract.connect(seller).createNovel(NEW_NOVEL);
      await novelContract
        .connect(seller)
        .approve(marketPlace.address, newTokenId);
      await marketPlace.connect(seller).listItem(newTokenId, ETH_10);
      await novelContract
        .connect(seller)
        .approve(ethers.constants.AddressZero, newTokenId);

      await expect(
        marketPlace.connect(buyer).buyItem(newTokenId)
      ).to.be.revertedWith(`NotApproved(${newTokenId})`);
    });

    it("should revert PriceNotMet if not enough msg.value", async () => {
      await expect(
        marketPlace
          .connect(buyer)
          .buyItem(tokenId, { value: ethers.utils.parseEther("9") })
      ).to.be.revertedWith(`PriceNotMet(${tokenId}, ${ETH_10})`);
    });

    it("should revert AlreadySold if already sold", async () => {
      marketPlace.connect(buyer).buyItem(tokenId, { value: ETH_10 });

      // To avoid NotApproved error to be thrown
      novelContract.connect(buyer).approve(marketPlace.address, tokenId);

      await expect(
        marketPlace.connect(buyer).buyItem(tokenId, { value: ETH_10 })
      ).to.be.revertedWith(`AlreadySold(${tokenId})`);
    });

    it("should revert BuyerMustNotBeSellor if seller tries to buy", async () => {
      await expect(
        marketPlace.connect(seller).buyItem(tokenId, { value: ETH_10 })
      ).to.be.revertedWith(`BuyerMustNotBeSellor`);
    });
  });
});
