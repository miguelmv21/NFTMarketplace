// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");
const ethers = hre.ethers;
async function main() {

  [p1,p2,p3] = await ethers.getSigners();
  const Marketplace = await hre.ethers.getContractFactory("Marketplace");
  const marketplace = await Marketplace.deploy();

  await marketplace.deployed();
  
  console.log("Marketplace deployed to:", marketplace.address);

  const SampleERC721 = await hre.ethers.getContractFactory("SampleERC721");
  const punks = await SampleERC721.deploy("punks","punk");

  await punks.deployed();
  
  console.log("Punks deployed to:", punks.address);

  const Dai = await ethers.getContractFactory("Dai");
  const dai = await Dai.deploy(400000,"Dai",2,"DAI");
  
  await dai.deployed();
  console.log("Dai deployed to:", dai.address);

  await dai.connect(p1).transfer(p3.address,1000);
  console.log("1000 dai transfered from: ",p1.address," to: ",p3.address);


  await punks.connect(p1).mint(p2.address,0);
  console.log("Punk minted to:",p2.address);

  await dai.connect(p3).approve(marketplace.address,10);
  console.log("Dai approved from:",p3.address," to spend on:",marketplace.address,", amount:",10);

  await punks.connect(p2).approve(marketplace.address,0);
  console.log("Punk #0 approved from:",p2.address," to spend on:",marketplace.address);


  await marketplace.connect(p3).deposit(dai.address,10);
  console.log("Dai deposited on:",marketplace.address,",amount:",10)
  await marketplace.connect(p2).list(punks.address,0);
  console.log("Punk listed on marketplace from:", p2.address);

  await marketplace.connect(p2).ask(0,dai.address,8);
  console.log(p2.address," created a sell order for Punk for amount:",8," Dai");

  await marketplace.connect(p3).buy(0,0);
  console.log("Punk bought for 8 Dai");

  await marketplace.connect(p3).withdraw(dai.address,2);
  console.log(p3.address," withdraws remainder of 2 dai");



}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
