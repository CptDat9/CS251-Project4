const hre = require("hardhat");
const fs = require("fs");

async function main() {
  // Deploy Token contract
  const TokenContract = await hre.ethers.getContractFactory("Token");
  const tokenContract = await TokenContract.deploy();
  await tokenContract.deployed();
  console.log(`Token deployed at: ${tokenContract.address}`);
  try {
    fs.writeFileSync("./token_address.txt", `${tokenContract.address}`);
    console.log(`Successfully wrote token address to token_address.txt`);
  } catch (error) {
    console.log("Failed to write token address to file");
  }

  // Deploy TokenExchange contract
  const ExchangeContract = await hre.ethers.getContractFactory("TokenExchange");
  const exchangeContract = await ExchangeContract.deploy();
  await exchangeContract.deployed();
  console.log(`TokenExchange deployed at: ${exchangeContract.address}`);
  try {
    fs.writeFileSync("./exchange_address.txt", `${exchangeContract.address}`);
    console.log(`Successfully wrote exchange address to exchange_address.txt`);
  } catch (error) {
    console.log("Failed to write exchange address to file");
  }
}

main()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error(err);
    process.exit(1);
  });


  /*
  require("dotenv").config();
const hre = require("hardhat");
const fs = require("fs");

async function main() {
  // Deploy Token contract
  const TokenContract = await hre.ethers.getContractFactory("Token");
  const tokenContract = await TokenContract.deploy();
  await tokenContract.deployed();
  console.log(`Token deployed at: ${tokenContract.address}`);

  try {
    fs.writeFileSync("./token_address.txt", `${tokenContract.address}`);
    console.log("Successfully wrote token address to token_address.txt");
  } catch (error) {
    console.error("Failed to write token address to file");
  }

  // Deploy TokenExchange contract
  const ExchangeContract = await hre.ethers.getContractFactory("TokenExchange");
  const exchangeContract = await ExchangeContract.deploy();
  await exchangeContract.deployed();
  console.log(`TokenExchange deployed at: ${exchangeContract.address}`);

  try {
    fs.writeFileSync("./exchange_address.txt", `${exchangeContract.address}`);
    console.log("Successfully wrote exchange address to exchange_address.txt");
  } catch (error) {
    console.error("Failed to write exchange address to file");
  }
}

main()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error(err);
    process.exit(1);
  });

  */
