// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const { ethers } = require("hardhat");

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

async function main() {
  const Tradix = await ethers.getContractFactory("Tradix");
  const GelatoPineCoreAddress = "0x0c30D3d66bc7C73A83fdA929888c34dcb24FD599";

  const tradix = await Tradix.deploy(GelatoPineCoreAddress);
  await sleep(6000);
  console.log("tradix: ", await tradix.getAddress());

  sleep(6000);

  console.log("COmpleted ");
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
