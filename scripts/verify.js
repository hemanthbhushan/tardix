const Hre = require("hardhat");

async function main() {
  await Hre.run("verify:verify", {
    //address of the Root tunnel
    address: "0xE2d09E952B48E71e838294e5Fc792DaaFBc356f7",
    //Pass arguments as string and comma seprated values
    constructorArguments: ["0x38c4092b28dAB7F3d98eE6524549571c283cdfA5","0xB8c1433cd9dF6F07f82E9a79bC8352c1d582f17E"],
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
