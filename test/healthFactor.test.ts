import { expect } from "chai";
import { ethers } from "hardhat";

describe("HealthFactor Library", function () {
  let pool: any, token: any, user: any;

  beforeEach(async () => {
    [user] = await ethers.getSigners();

    const Token = await ethers.getContractFactory("MockAUSD");
    token = await Token.deploy();

    const Pool = await ethers.getContractFactory("LendingPool");
    pool = await Pool.deploy(ethers.ZeroAddress); // model not needed

    await token.mint(user.address, ethers.parseEther("1000"));
    await token.approve(pool.target, ethers.parseEther("1000"));
  });

  it("returns max value when no debt", async () => {
    await pool.deposit(token.target, ethers.parseEther("100"));

    const hf = await pool.getHealthFactor(user.address, token.target);
    expect(hf).to.equal(ethers.MaxUint256);
  });

  it("returns HF > 1 when safe", async () => {
    await pool.deposit(token.target, ethers.parseEther("200"));
    await pool.borrow(token.target, ethers.parseEther("100"));

    const hf = await pool.getHealthFactor(user.address, token.target);
    expect(hf).to.be.gt(ethers.parseEther("1"));
  });

  it("returns HF < 1 when unsafe", async () => {
    await pool.deposit(token.target, ethers.parseEther("100"));
    await pool.borrow(token.target, ethers.parseEther("90"));

    const hf = await pool.getHealthFactor(user.address, token.target);
    expect(hf).to.be.lt(ethers.parseEther("1"));
  });
});
