const Hre = require("hardhat");

async function main() {
  await Hre.run("verify:verify", {
    //address of the Root tunnel
    address: "0x4e4Cd2D446A350edD1c2f3c0750177A86B9519DD",
    //Pass arguments as string and comma seprated values
    constructorArguments: ["0x0c30D3d66bc7C73A83fdA929888c34dcb24FD599"],
    //Path of your main contract.
    contract: "contracts/Tradix.sol:Tradix",
  });
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
