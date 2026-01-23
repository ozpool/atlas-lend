import { expect } from "chai";
import { ethers } from "hardhat";

describe("MockAUSD", function () {
  async function deployToken() {
    const [owner, user, attacker] = await ethers.getSigners();
    const Token = await ethers.getContractFactory("MockAUSD");
    const token = await Token.deploy();
    return { token, owner, user, attacker };
  }

  it("allows owner to mint tokens", async function () {
    const { token, user } = await deployToken();

    await token.mint(user.address, ethers.parseEther("100"));

    expect(await token.balanceOf(user.address)).to.equal(
      ethers.parseEther("100")
    );
  });

  it("prevents non-owner from minting", async function () {
    const { token, attacker } = await deployToken();

    await expect(
      token.connect(attacker).mint(attacker.address, 1)
    ).to.be.revertedWith("Ownable: caller is not the owner");
  });

  it("reverts on zero amount mint", async function () {
    const { token, user } = await deployToken();

    await expect(
      token.mint(user.address, 0)
    ).to.be.revertedWith("ZERO_AMOUNT");
  });
});
