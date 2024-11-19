# CS251 Project 4 - Decentralized Exchange (DEX)

<p align="center">
<a href="https://git.io/typing-svg"><img src="https://readme-typing-svg.demolab.com?font=Fira+Code&pause=1000&center=true&vCenter=true&random=false&width=450&lines=CS251+Project4" alt="Typing SVG" /></a>
</p>
<div align="center">
<img alt="Static Badge" src="https://img.shields.io/badge/Astar-group-blue?labelColor=EE4E4E&color=151515">
<img alt="Static Badge" src="https://img.shields.io/badge/Security-Research-blue?labelColor=e7ec89&color=3ddd2b&label=Security">
<img alt="GitHub code size in bytes" src="https://img.shields.io/github/languages/code-size/CptDat9/CS251-Project4?labelColor=7AA2E3&color=97E7E1">
</div>

This project demonstrates a **Decentralized Exchange (DEX)** implementation. It includes smart contracts for DEX functionality, a web application for interacting with the blockchain, and essential configurations for deployment.

Try running some of the following tasks:

```bash
npx hardhat help
npx hardhat test
npx hardhat node
npx hardhat run scripts/deploy.js
```
## Project 4 - DEX
## Mục lục
- [Giới thiệu](#giới-thiệu)
- [Yêu cầu hệ thống](#yêu-cầu-hệ-thống)
- [Cài đặt project](#cài-đặt-project)
- [Chức năng chính của DEX](#chức-năng-chính-của-dex)
- [Các lệnh cơ bản](#các-lệnh-cơ-bản)
- [Ứng dụng Web](#ứng-dụng-web)
- [Thông tin bổ sung](#thông-tin-bổ-sung)
- [Minh họa](#minh-họa)
## Giới thiệu
 - Dự án này xây dựng một sàn giao dịch phi tập trung (DEX) với các chức năng cơ bản như cung cấp thanh khoản (liquidity), hoán đổi token (swap), và rút thanh khoản. Hệ thống được triển khai trên BSC Testnet, kèm theo một giao diện web đơn giản để tương tác với hợp đồng thông minh.

 ### Dự án này gồm:
+ Hợp đồng thông minh quản lý pool thanh khoản và giao dịch.
+ Các bài kiểm thử để đảm bảo tính đúng đắn của hệ thống.
+ Cấu hình Hardhat cho phát triển, triển khai và kiểm thử.
+ Giao diện web để tương tác trực tiếp với DEX.
## Yêu cầu hệ thống
- **Node.js** và **npm** phiên bản mới nhất.
- **Hardhat** để triển khai và quản lý project.
- **Git** để quản lý mã nguồn.
## Cài đặt project
### Bước 1: Sao chép repository
```bash
git clone https://github.com/CptDat9/CS251-Project4.git
cd CS251-Project4
```
### Bước 2: Cài đặt các thư viện
```bash
npm install
npm install --save-dev hardhat
```
### Bước 3: Cấu hình mạng và thông tin nhạy cảm
- Tạo file .env để lưu thông tin API và khóa cá nhân:
```plaintext

API_URL=https://<Infura_or_Alchemy_URL>
PRIVATE_KEY=<Your_Private_Key>
```
- Cập nhật hardhat.config.js:
```javascript

require("dotenv").config();
module.exports = {
  solidity: "0.8.17",
  networks: {
    bscTestnet: {
      url: process.env.API_URL,
      accounts: [process.env.PRIVATE_KEY],
    },
  },
};
```
## Chức năng chính của DEX
### Cung cấp thanh khoản (Add Liquidity):
- Người dùng có thể gửi ETH và token vào pool để nhận lại Liquidity Tokens.
- Giá trị gửi được điều chỉnh dựa trên tỷ lệ hiện tại của pool.
### Hoán đổi token (Swap):

- Người dùng có thể hoán đổi ETH lấy token hoặc ngược lại.
- Giá hoán đổi được xác định bằng công thức `x * y = k` (Constant Product Market Maker).
### Rút thanh khoản (Remove Liquidity):
- Người dùng có thể rút ETH và token khỏi pool bằng cách trả lại Liquidity Tokens.
- Giá trị nhận lại dựa trên tỷ lệ thanh khoản trong pool.
### Phí giao dịch:
- Một phần phí giao dịch được tính vào mỗi lần swap để đảm bảo sự cân bằng và khuyến khích nhà cung cấp thanh khoản.
## Các lệnh cơ bản
- Hiển thị trợ giúp:
```bash

npx hardhat help
```
- Kiểm thử hợp đồng:
```bash

npx hardhat test
```
- Khởi động mạng Hardhat:
```bash

npx hardhat node
```
- Triển khai hợp đồng:
```bash

npx hardhat run scripts/deploy.js
```
## Ứng dụng Web
### Ứng dụng web này cho phép người dùng:

- Cung cấp thanh khoản và nhận lại token thanh khoản.
- Thực hiện giao dịch hoán đổi giữa ETH và token.
- Rút thanh khoản đã gửi vào pool.
### Cấu trúc ứng dụng web:
- Frontend (web_app/):
- index.html: Giao diện chính.
- style.css: Thiết kế giao diện.
- script.js: Tương tác với blockchain thông qua Web3.js hoặc Ethers.js.
### Smart Contracts (contracts/):
- Các hợp đồng DEX triển khai bằng Solidity.
- Bao gồm hợp đồng quản lý thanh khoản và swap.
## Thông tin bổ sung
- Git: Dùng để quản lý và theo dõi các thay đổi của project.
- Hardhat Network: Cho phép thử nghiệm tính năng mà không cần sử dụng phí gas thực.
- BSC Testnet: Là môi trường triển khai chính của dự án này.
## Minh họa
![image](https://github.com/user-attachments/assets/46909f7b-a20a-4ebe-a7cf-dfff0d90b6b5)
![image](https://github.com/user-attachments/assets/b02dd1e5-4a53-4b2f-a8a3-3b71b727ed59)




