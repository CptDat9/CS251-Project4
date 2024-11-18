// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import './token.sol';
import "hardhat/console.sol";


contract TokenExchange is Ownable {
    string public exchange_name = 'CDSwap';

    // TODO: paste token contract address here
    // e.g. tokenAddr = 0x5FbDB2315678afecb367f032d93F642f64180aa3
    
    address tokenAddr = 0x5FbDB2315678afecb367f032d93F642f64180aa3;                                  // TODO: paste token contract address here
    Token public token = Token(tokenAddr);                                

    // Liquidity pool for the exchange
    uint private token_reserves = 0;
    uint private eth_reserves = 0;

    // Fee Pools
    uint private token_fee_reserves = 0;
    uint private eth_fee_reserves = 0;

    // Liquidity pool shares
    mapping(address => uint) private lps;

    // For Extra Credit only: to loop through the keys of the lps mapping
    address[] private lp_providers;      

    // Total Pool Shares
    uint private total_shares = 0;

    // liquidity rewards
    uint private swap_fee_numerator = 3;                
    uint private swap_fee_denominator = 100;
    // Constant: x * y = k
    uint private k;

    uint private multiplier = 10**18;
    event paymentRecieve(uint number);
    modifier canTransferToken(){
        require(token_reserves >=1, "Exhausted");
        _;
    }
    modifier canTransferETH(){
        require(eth_reserves >=1, "Exhausted");
        _;
    }
    constructor() Ownable() {
        
    }

    

    // Function createPool: Initializes a liquidity pool between your Token and ETH.
    // ETH will be sent to pool in this transaction as msg.value
    // amountTokens specifies the amount of tokens to transfer from the liquidity provider.
    // Sets up the initial exchange rate for the pool by setting amount of token and amount of ETH.
    function createPool(uint amountTokens) external payable onlyOwner
    {
        // This function is already implemented for you; no changes needed.

        // require pool does not yet exist:
        require (token_reserves == 0, "Token reserves was not 0");
        require (eth_reserves == 0, "ETH reserves was not 0.");

        // require nonzero values were sent
        require (msg.value > 0, "Need eth to create pool.");
        uint tokenSupply = token.balanceOf(msg.sender);
        require(amountTokens <= tokenSupply, "Not have enough tokens to create the pool");
        require (amountTokens > 0, "Need tokens to create pool.");

        token.transferFrom(msg.sender, address(this), amountTokens);
        token_reserves = token.balanceOf(address(this));
        eth_reserves = msg.value;
        k = token_reserves * eth_reserves;



        // Pool shares set to a large value to minimize round-off errors
        total_shares = 10**5;
        // Pool creator has some low amount of shares to allow autograder to run
        lps[msg.sender] = 100;
    }

    // For use for ExtraCredit ONLY
    // Function removeLP: removes a liquidity provider from the list.
    // This function also removes the gap left over from simply running "delete".
    function removeLP(uint index) private {
        require(index < lp_providers.length, "specified index is larger than the number of lps");
        lp_providers[index] = lp_providers[lp_providers.length - 1];
        lp_providers.pop();
    }

    // Function getSwapFee: Returns the current swap fee ratio to the client.
    function getSwapFee() public view returns (uint, uint) {
        return (swap_fee_numerator, swap_fee_denominator);
    }

    // Function getReserves
    function getReserves() public view returns (uint, uint) {
        return (eth_reserves, token_reserves);
    }

    // ============================================================
    //                    FUNCTIONS TO IMPLEMENT
    // ============================================================
    
    /* ========================= Liquidity Provider Functions =========================  */ 

    // Function addLiquidity: Adds liquidity given a supply of ETH (sent to the contract as msg.value).
    // You can change the inputs, or the scope of your function, as needed.

    function addLiquidity(uint min_rate, uint max_rate) 
    external payable
    {
        
        // I add max exchagne rate and min exchange rate as parameters to avoid 
        // Sandwich attack, Front-run and back-run
       /******* TODO: Implement this function *******/
        uint ETHamount = msg.value;
        // This function below check user's token and pool.
        require(ETHamount > 0, "Error: ETH amount need to positive.");
        require(eth_reserves > 0 && token_reserves > 0, "Error: Pool not initialized.");
        // Detect the token that need to add to stablize formula: x*y = k (token_reserves*eth_reserves=k constant)
        uint tokenreq = (ETHamount * token_reserves)/eth_reserves;
        // Dùng tỉ lệ giữa delta x, delta y so với x,y để tính x
        // Check balance of user
        require(tokenreq <= token.balanceOf(msg.sender),"Error: User doesn't have enough token." );
        uint rate = (ETHamount * 1e18)/tokenreq; // Token đang dùng có 18 decimals
        require(rate >= min_rate, "Error. Slippage!");
        require(rate <= max_rate, "Error. Slippage!");
        //Avoid slippage.

        token.transferFrom(msg.sender, address(this), tokenreq);
        token_reserves += tokenreq;
        eth_reserves += ETHamount;
        // Cập nhật thanh khoản trong pool và lệnh nạp thanh khoản
        uint old_reserves = token_reserves - tokenreq;    
        // Hàm bên dưới sẽ cập nhất cổ phần của từng lp_provider bao gồm cả người chưa có trong danh sách.
        bool providerExist = false;
        for (uint i = 0; i < lp_providers.length; i++){
            if(lp_providers[i] == msg.sender){
                providerExist = true;
                lps[msg.sender] = ((old_reserves*lps[msg.sender])+tokenreq*1e18)/token_reserves;
            }else{
                lps[lp_providers[i]] = (old_reserves*lps[lp_providers[i]])/token_reserves;
            }
        }
        if(!providerExist){
            lp_providers.push(msg.sender);
            lps[msg.sender] = (tokenreq*1e18)/token_reserves;
        }
        
    }


    // Function removeLiquidity: Removes liquidity given the desired amount of ETH to remove.
    // You can change the inputs, or the scope of your function, as needed.
    function removeLiquidity(uint amountETH, uint min_rate, uint max_rate)
     public payable canTransferToken canTransferETH
    {
        /******* TODO: Implement this function *******/
        require(amountETH > 0, "Error, amount need to be greater than 0.");
        uint amount_token = (amountETH * token_reserves)/eth_reserves;
        require(amount_token * 1e18 <= lps[msg.sender] * token_reserves, "Error, user does not have enough token.");
        require((amountETH * 1e18)/amount_token >= min_rate, "Error, lower than min rate.");
        require((amountETH * 1e18)/amount_token <= max_rate, "Error, bigger than max rate.");
        // Check để tránh Slippage.        
        require(eth_reserves - amountETH >0, "Error, can not remove your liquid from the pool.");
        require(token_reserves - amount_token > 0, "Error, can not remove your liquid from the pool."); 
        // Nếu thanh khoản trong pool ko đủ thì ko thực hiện được việc rút.
        uint old_reserves = token_reserves;
        //Chuyển cổ phần của người dùng về tài khoản của họ 
        token.transfer(msg.sender, amount_token);
        token_reserves = token.balanceOf(address(this));
        payable(msg.sender).transfer(amountETH);
        //Chuyen ETH tu hop dong den nguoi dung (co the dung call, send nhung k toi uu bang cach nay).
        // Dung cach nay neeus giao dich that bai se rever toan bo giao dich ve trang thai chua giao dich
        /* Vi du ve dung .send
        bool success = payable(msg.sender).send(amountETH);
        require(success, "ETH transfer failed");
        */
        eth_reserves = address(this).balance;
        //Update LPS
        uint new_lps = (lps[msg.sender] * old_reserves - amount_token * 1e18 ) /token_reserves;
        // Neu gia tri LPS quy doi ra nho hon decimals cua token trong pool thi dua lps ve =0
        if(new_lps* (token_reserves - amount_token)/100 < 1e18 || new_lps*(eth_reserves - amountETH)/100 < 1e18){
            lps[msg.sender] = 0;
        }else{
            lps[msg.sender] = new_lps;
        }
        //Cap nhat lps cua tat ca moi nguoi.
        uint sender_index;
        for(uint i = 0; i < lp_providers.length; i++){
        if(lp_providers[i] == msg.sender){
            sender_index = i;
        }else{
            lps[lp_providers[i]] = (lps[lp_providers[i]]*old_reserves)/token_reserves;
        }
        }
        // neu lps cua msg.sender = 0 thi bo khoi danh sach qua viec su dung removeLP dduoc cai tu truoc.
        if(lps[msg.sender] == 0){
            removeLP(sender_index);
        } 
    }

    // Function removeAllLiquidity: Removes all liquidity that msg.sender is entitled to withdraw
    // You can change the inputs, or the scope of your function, as needed.
    function removeAllLiquidity(uint min_rate, uint max_rate)
    external payable
    {
        /******* TODO: Implement this function *******/
        //TInh lai luong ETH theo co phan cua nguoi dung trong pool
       uint amountETH = (lps[msg.sender] * eth_reserves)/1e18;
       emit paymentRecieve(amountETH);
       // Su dung ham removLiquidity truoc do.
       removeLiquidity(amountETH, min_rate, max_rate);
    }
    /***  Define additional functions for liquidity fees here as needed ***/


    /* ========================= Swap Functions =========================  */ 

    // Function swapTokensForETH: Swaps your token with ETH
    // You can change the inputs, or the scope of your function, as needed.
    function swapTokensForETH(uint amountTokens, uint max_rate)
     external payable canTransferETH
    {
        /******* TODO: Implement this function *******/
        require(amountTokens > 0, "Error, amount tokens must be positive.");
        require(token.balanceOf(msg.sender) >= amountTokens, "User does not have enough token." );
        //Bảo vệ người dùng khỏi bị hoán đổi với tỷ giá bất lợi.
        //max_rate là tỷ giá trao đổi tối đa mà người dùng chấp nhận, được xác định trước khi thực hiện giao dịch.
        // đảm bảo tỉ giá trong pool k vượt ngưỡng.
        require(eth_reserves*1e18/token_reserves <= max_rate, "Exchange rate greater than specified rate.");
        // Cong thuc swap AMM (Automated Market Maker)
        // amount eth = eth_reserves - (eth_ tinh theo phan con lai sau khi swap)
        // su dung x * y = k; x_new * y_new = k
        uint amountETH = eth_reserves - (token_reserves * eth_reserves) / (token_reserves +((100 - swap_fee_numerator) * amountTokens) / 100);
        if(eth_reserves == amountETH) amountETH -=1;
        token.transferFrom(msg.sender, address(this), amountTokens);
        // Cap nhat lai so luong token trong contract
        token_reserves = token.balanceOf(address(this));
        //Chuyen ETH cho msg.sender
        payable(msg.sender).transfer(amountETH);
        // Cap nhat lai so luong ETH trong contract
        eth_reserves = address(this).balance;
    }



    // Function swapETHForTokens: Swaps ETH for your tokens
    // ETH is sent to contract as msg.value
    // You can change the inputs, or the scope of your function, as needed.
    // ko can cho amountETH vao tham so vi no la msg.value dc dinh nghiax san trong hop dong r.
    function swapETHForTokens(uint max_rate) 
    external payable canTransferToken
    {
        /******* TODO: Implement this function *******/
        require(msg.value > 0, "Error, amount ETH must be positive.");
        // Ko can ktra so du tai khoan ETH cua nguoi dùng do msg.value tự động đại diện 
        // cho số lượng ETH người dùng gửi, nếu ko đu ETH thì sẽ bị lỗi do cơ thể của Etherum.
        //Bảo vệ người dùng khỏi bị hoán đổi với tỷ giá bất lợi.
        //max_rate là tỷ giá trao đổi tối đa mà người dùng chấp nhận, được xác định trước khi thực hiện giao dịch.
        // đảm bảo tỉ giá trong pool k vượt ngưỡng.
        require(eth_reserves*1e18/token_reserves <= max_rate, "Exchange rate greater than specified rate.");
        uint amount_token = token_reserves - (token_reserves * eth_reserves)/(eth_reserves + ((100 - swap_fee_numerator) * msg.value)/100);
        eth_reserves = address(this).balance;
        // Gui token cho msg.sender.
        token.transfer(msg.sender, amount_token);
        token_reserves = token.balanceOf(address(this));
     }
}
/*
Co the them modifiers de tranh loi re-entrancy.
*/