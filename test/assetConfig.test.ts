import { expect } from "chai";
import { ethers } from "hardhat";

describe("AssetConfig Constants", function () {
  it("should have correct LTV and liquidation parameters", async () => {
    const AssetConfig = await ethers.getContractFactory("AssetConfigHarness");
    const config = await AssetConfig.deploy();

    expect(await config.maxLtv()).to.equal(7500);
    expect(await config.liquidationThreshold()).to.equal(8000);
    expect(await config.liquidationBonus()).to.equal(10500);
  });
});
