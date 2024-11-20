
import hre from "hardhat";
import { ethers } from "hardhat";
import { TokenExchange__factory, Token__factory } from "../../typechain-types";
//Chua dung dc typechain
// Gói
async function main(){
    const [deployer] = await hre.ethers.getSigners();
    // Xac thuc nguoi giao dich, dung khi can test nhieu tai khoan cung luc.
    /*
    const deployer = await hre.ethers.provider.getSigner(0);
    // Lay nguoi giao dich dau danh sách.
    */
   //Tao mot Instance cuar TokenExchange.(đối tượng)
    const tokenAddress = "0x5FbDB2315678afecb367f032d93F642f64180aa3";
    const exchangeAddress = "0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512";
    const exchange = TokenExchange__factory.connect(exchangeAddress, deployer);
   //Kiểm tra tên của DEX
    const exchangeName = await exchange.exchange_name();
    console.log(`Exchange Name: ${exchangeName}`); //    string public exchange_name = 'CDSwap';

    // kiem tra so du trong pool
    const [ethReserves, tokenReserves] = await exchange.getReserves();
    console.log(`ETH Reserves in pool (Tổng ETH's liquid trong pool): ${ethers.utils.formatEther(ethReserves)}`);
    console.log(`Token Reserves in pool (Tổng Token's liquid trong pool): ${ethers.utils.formatUnits(tokenReserves, 18)}`);
    // // Lấy tỷ lệ phí swap
    const [swapFeeNumerator, swapFeeDenominator] = await exchange.getSwapFee();
    console.log(`Swap Fee: ${swapFeeNumerator}/${swapFeeDenominator}`);
    // Kiem tra so du nguoi dung
    const token = Token__factory.connect(tokenAddress, deployer);
    const userBalance = await token.balanceOf(deployer.address);
    console.log(`User balance (số dư người dùng) là: ${ethers.utils.formatUnits(userBalance, 18)} tokens`);
    // them ETH vao pool.
    const amountEth = ethers.utils.parseEther("1.0"); // 1 ETH
    const minRate = ethers.utils.parseUnits("3000", 18); // Min rate
    const maxRate = ethers.utils.parseUnits("3500", 18); // Max rate

    // tính toán lượng token cần để duy trì tỉ lệ trong pool.
    const [ethReserve, tokenReserve] = await exchange.getReserves();
    const tokenAmount = amountEth.mul(tokenReserve).div(ethReserve);

    console.log(`Adding liquidity with:
    ETH: ${ethers.utils.formatEther(amountEth)} ETH
    Tokens: ${ethers.utils.formatUnits(tokenAmount, 18)} tokens
    Min Rate: ${ethers.utils.formatUnits(minRate, 18)}
    Max Rate: ${ethers.utils.formatUnits(maxRate, 18)}`);   

// Gửi giao dịch thêm thanh khoản
const txAddLiquidity = await exchange.addLiquidity(minRate, maxRate, {
    value: amountEth,
  });
  console.log(`Adding liquidity... Tx Hash: ${txAddLiquidity.hash}`);
  await txAddLiquidity.wait();
  console.log("Liquidity added!");
  
  
    // swap ETH lấy tokens
    const swapAmountEth = ethers.utils.parseEther("0.1"); // 0.1 ETH
    const txSwap = await exchange.swapETHForTokens(maxRate, {
      value: swapAmountEth,
    });
    console.log(`Swapping ETH for tokens... Tx Hash: ${txSwap.hash}`);
    await txSwap.wait();
    console.log("Swap thành công!");
  }
  
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });
  
