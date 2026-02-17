import { expect } from "chai";
import { ethers } from "hardhat";

describe("LendingPool Liquidation", function () {
  let pool: any, token: any, user: any, liquidator: any;

  beforeEach(async () => {
    [user, liquidator] = await ethers.getSigners();

    const Token = await ethers.getContractFactory("MockAUSD");
    token = await Token.deploy();

    const RateModel = await ethers.getContractFactory(
      "LinearInterestRateModel"
    );
    const model = await RateModel.deploy();

    const Pool = await ethers.getContractFactory("LendingPool");
    pool = await Pool.deploy(model.target);

    await token.mint(user.address, ethers.parseEther("1000"));
    await token.mint(liquidator.address, ethers.parseEther("1000"));

    await token.connect(user).approve(pool.target, ethers.parseEther("1000"));
    await token.connect(liquidator).approve(pool.target, ethers.parseEther("1000"));

    await pool.connect(user).deposit(token.target, ethers.parseEther("100"));
    await pool.connect(user).borrow(token.target, ethers.parseEther("90"));
  });

  it("allows liquidation when health factor < 1", async () => {
    await pool.connect(liquidator).liquidate(
      user.address,
      token.target,
      ethers.parseEther("50")
    );

    const debt = await pool.debtOf(user.address, token.target);
    expect(debt).to.be.lt(ethers.parseEther("90"));
  });

  it("reverts liquidation when health factor >= 1", async () => {
    await pool.connect(user).repay(token.target, ethers.parseEther("40"));

    await expect(
      pool.connect(liquidator).liquidate(
        user.address,
        token.target,
        ethers.parseEther("10")
      )
    ).to.be.revertedWith("NOT_LIQUIDATABLE");
  });
});
