import { expect } from "chai";
import { ethers } from "hardhat";

describe("LendingPool Deposit & Withdraw", function () {
  let pool: any, token: any, user: any;

  beforeEach(async () => {
    [user] = await ethers.getSigners();

    const MockToken = await ethers.getContractFactory("MockAUSD");
    token = await MockToken.deploy();

    const LendingPool = await ethers.getContractFactory("LendingPool");
    pool = await LendingPool.deploy();

    await token.mint(user.address, ethers.parseEther("1000"));
    await token.approve(pool.target, ethers.parseEther("1000"));
  });

  it("allows user to deposit tokens", async () => {
    await pool.deposit(token.target, ethers.parseEther("100"));

    expect(await pool.balanceOf(user.address, token.target))
      .to.equal(ethers.parseEther("100"));
  });

  it("allows user to withdraw tokens", async () => {
    await pool.deposit(token.target, ethers.parseEther("200"));
    await pool.withdraw(token.target, ethers.parseEther("50"));

    expect(await pool.balanceOf(user.address, token.target))
      .to.equal(ethers.parseEther("150"));
  });

  it("reverts on over-withdraw", async () => {
    await pool.deposit(token.target, ethers.parseEther("10"));

    await expect(
      pool.withdraw(token.target, ethers.parseEther("20"))
    ).to.be.revertedWith("INSUFFICIENT_BALANCE");
  });
});
