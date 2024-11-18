const hre = require("hardhat");
const fs = require('fs');

async function main() {
  const TokenContract = await hre.ethers.getContractFactory("Token");
  const tokenContract = await TokenContract.deploy();
  await tokenContract.deployed();
  try {
    fs.writeFileSync('./token_address.txt',`${tokenContract.address}`, (error) => {
      console.log(`Failed to write to file`);
      console.log(`Manually input token address: ${tokenContract.address}`);
    });
    console.log(`Successfully wrote token address ${tokenContract.address} to token_address.txt`)

  } catch(error) {
    console.log(`Failed to write to file`);
    console.log(`Manually input token address: ${tokenContract.address}`);
  }
}

main()
  .then(() => process.exit(0))
  .catch(err => {
    console.error(err);
    process.exit(1);
  });
