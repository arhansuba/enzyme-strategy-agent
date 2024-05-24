const { ethers } = require('hardhat');
const { expect } = require('chai');

describe('EnzymeStrategyAgent', function () {
  let enzymeStrategyAgent;
  let zkmlIntegration;
  let user1;
  let user2;

  beforeEach(async function () {
    // Deploy EnzymeStrategyAgent contract
    const EnzymeStrategyAgent = await ethers.getContractFactory('EnzymeStrategyAgent');
    enzymeStrategyAgent = await EnzymeStrategyAgent.deploy();

    // Deploy ZKMLIntegration contract
    const ZKMLIntegration = await ethers.getContractFactory('ZKMLIntegration');
    zkmlIntegration = await ZKMLIntegration.deploy(enzymeStrategyAgent.address);

    // Get signers
    [owner, user1, user2] = await ethers.getSigners();
  });

  describe('ZKMLIntegration', function () {
    it('should allow user to register for ZKML', async function () {
      // User1 registers for ZKML
      await zkmlIntegration.connect(user1).registerForZKML();

      // Check that user1 is registered
      expect(await zkmlIntegration.isRegistered(user1.address)).to.equal(true);

      // User2 tries to register for ZKML
      await expect(zkmlIntegration.connect(user2).registerForZKML()).to.be.revertedWith('User already registered');
    });

    it('should allow user to submit ZKML data', async function () {
      // User1 registers for ZKML
      await zkmlIntegration.connect(user1).registerForZKML();

      // User1 submits ZKML data
      const data = '0x1234567890abcdef1234567890abcdef12345678';await zkmlIntegration.connect(user1).submitZKMLData(data);

      // Check that ZKML data was stored
      const storedData = await zkmlIntegration.getZKMLData(user1.address);
      expect(storedData).to.equal(data);
    });
  });

  describe('EnzymeStrategyAgent', function () {
    it('should allow owner to set ZKMLIntegration address', async function () {
      // Owner sets ZKMLIntegration address
      await enzymeStrategyAgent.setZKMLIntegrationAddress(zkmlIntegration.address);

      // Check that ZKMLIntegration address was set
      expect(await enzymeStrategyAgent.zkmlIntegrationAddress()).to.equal(zkmlIntegration.address);
    });

    it('should allow user to register for strategy', async function () {
      // User1 registers for strategy
      await enzymeStrategyAgent.connect(user1).registerForStrategy();

      // Check that user1 is registered
      expect(await enzymeStrategyAgent.isRegistered(user1.address)).to.equal(true);

      // User2 tries to register for strategy
      await expect(enzymeStrategyAgent.connect(user2).registerForStrategy()).to.be.revertedWith('User already registered');
    });

    it('should allow user to submit strategy data', async function () {
      // User1 registers for strategy
      await enzymeStrategyAgent.connect(user1).registerForStrategy();

      // User1 submits strategy data
      const data = '0x1234567890abcdef1234567890abcdef12345678';
      await enzymeStrategyAgent.connect(user1).submitStrategyData(data);

      // Check that strategy data was stored
      const storedData = await enzymeStrategyAgent.getStrategyData(user1.address);
      expect(storedData).to.equal(data);
    });
  });
});