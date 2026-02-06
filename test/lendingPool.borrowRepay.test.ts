import { expect } from "chai";
import { ethers } from "hardhat";

describe("LendingPool Borrow & Repay", function () {
  let pool: any, token: any, user: any;

  beforeEach(async () => {
    [user] = await ethers.getSigners();

    const Token = await ethers.getContractFactory("MockAUSD");
    token = await Token.deploy();

    const Pool = await ethers.getContractFactory("LendingPool");
    pool = await Pool.deploy();

    await token.mint(user.address, ethers.parseEther("1000"));
    await token.approve(pool.target, ethers.parseEther("1000"));
  });

  it("allows borrowing within LTV", async () => {
    await pool.deposit(token.target, ethers.parseEther("100"));
    await pool.borrow(token.target, ethers.parseEther("75"));

    expect(await pool.debtOf(user.address, token.target))
      .to.equal(ethers.parseEther("75"));
  });

  it("reverts borrowing above LTV", async () => {
    await pool.deposit(token.target, ethers.parseEther("100"));

    await expect(
      pool.borrow(token.target, ethers.parseEther("80"))
    ).to.be.revertedWith("INSUFFICIENT_COLLATERAL");
  });

  it("allows repayment", async () => {
    await pool.deposit(token.target, ethers.parseEther("200"));
    await pool.borrow(token.target, ethers.parseEther("100"));

    await token.approve(pool.target, ethers.parseEther("50"));
    await pool.repay(token.target, ethers.parseEther("50"));

    expect(await pool.debtOf(user.address, token.target))
      .to.equal(ethers.parseEther("50"));
  });
});
