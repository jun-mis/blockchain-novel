import { ethers } from "hardhat";

async function main() {
  const NovelContract = await ethers.getContractFactory("NovelContract");
  const novelContract = await NovelContract.deploy("BlockchainNovel", "BCN");

  await novelContract.deployed();

  const MarketPlace = await ethers.getContractFactory("MarketPlace");
  const marketPlace = await MarketPlace.deploy(
    novelContract.address,
    ethers.utils.parseEther("25") // this number represents 25/1000 = 2.5 for the fee (25000000000000000000)
  );

  await marketPlace.deployed();

  console.log("NovelContract deployed to:", novelContract.address);
  console.log("MarketPlace deployed to:", marketPlace.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
