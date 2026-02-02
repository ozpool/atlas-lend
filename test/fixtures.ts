import { ethers } from "hardhat";

export async function setupFixture() {
  const [admin, user, liquidator] = await ethers.getSigners();

  const RateModel = await ethers.getContractFactory(
    "LinearInterestRateModel"
  );
  const rateModel = await RateModel.deploy();

  const Token = await ethers.getContractFactory("MockAUSD");
  const token = await Token.deploy();

  const Pool = await ethers.getContractFactory("LendingPool");
  const pool = await Pool.deploy(rateModel.target);

  await token.mint(user.address, ethers.parseEther("1000"));
  await token.mint(liquidator.address, ethers.parseEther("1000"));

  return { admin, user, liquidator, pool, token, rateModel };
}
