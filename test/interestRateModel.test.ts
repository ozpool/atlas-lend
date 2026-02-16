import { expect } from "chai";
import { ethers } from "hardhat";

describe("LinearInterestRateModel", function () {
  let model: any;

  beforeEach(async () => {
    const Model = await ethers.getContractFactory(
      "LinearInterestRateModel"
    );
    model = await Model.deploy();
  });

  it("returns base rate at zero utilization", async () => {
    const rate = await model.getBorrowRate(0, 100);
    expect(rate).to.equal(ethers.parseEther("0.02"));
  });

  it("increases rate with utilization", async () => {
    const rate = await model.getBorrowRate(
      ethers.parseEther("50"),
      ethers.parseEther("100")
    );

    expect(rate).to.be.gt(ethers.parseEther("0.02"));
  });
});
