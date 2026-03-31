const hre = require("hardhat");

async function main() {
  const BASE_TOKEN = "0x..."; 
  const QUOTE_TOKEN = "0x..."; 

  const DEX = await hre.ethers.getContractFactory("OrderbookDEX");
  const dex = await DEX.deploy(BASE_TOKEN, QUOTE_TOKEN);

  await dex.waitForDeployment();
  console.log("Orderbook DEX deployed to:", await dex.getAddress());
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
