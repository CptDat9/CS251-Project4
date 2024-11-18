const hre = require("hardhat");
const fs = require('fs');

async function main() {
  const ExchangeContract = await hre.ethers.getContractFactory("TokenExchange");
  const exchangeContract = await ExchangeContract.deploy();
  await exchangeContract.deployed();
  try {
    fs.writeFileSync('./exchange_address.txt',`${exchangeContract.address}`, (error) => {
      console.log(`Failed to write to file`);
      console.log(`Manually input contract address: ${exchangeContract.address}`);
    });
    console.log(`Successfully wrote exchange address ${exchangeContract.address} to exchange_address.txt`)

  } catch(error) {
    console.log(`Failed to write to file`);
    console.log(`Manually input exchange address: ${exchangeContract.address}`);
  }
}

main()
  .then(() => process.exit(0))
  .catch(err => {
    console.error(err);
    process.exit(1);
  });
