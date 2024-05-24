const { ethers } = require('ethers');
const { abi, bytecode } = require('./contracts/EnzymeStrategyAgent.json');
const { abi: zkmlAbi, bytecode: zkmlBytecode } = require('./contracts/ZKMLIntegration.json');

async function deploy() {
  // Set up provider and wallet
  const provider = new ethers.providers.AlchemyProvider('mainnet', 'YOUR_ALCHEMY_API_KEY');
  const wallet = new ethers.Wallet('YOUR_PRIVATE_KEY', provider);

  // Deploy EnzymeStrategyAgent contract
  const strategyAgentFactory = new ethers.ContractFactory(abi, bytecode, wallet);
  const strategyAgent = await strategyAgentFactory.deploy();

  console.log(`EnzymeStrategyAgent deployed to: ${strategyAgent.address}`);

  // Wait for deployment to be mined
  await strategyAgent.deployTransaction.wait();

  console.log(`EnzymeStrategyAgent deployed and mined!`);

  // Deploy ZKMLIntegration contract
  const zkmlIntegrationFactory = new ethers.ContractFactory(zkmlAbi, zkmlBytecode, wallet);
  const zkmlIntegration = await zkmlIntegrationFactory.deploy(strategyAgent.address);

  console.log(`ZKMLIntegration deployed to: ${zkmlIntegration.address}`);

  // Wait for deployment to be mined
  await zkmlIntegration.deployTransaction.wait();

  console.log(`ZKMLIntegration deployed and mined!`);
}

deploy().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});