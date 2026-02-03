import { ethers } from "hardhat";

export async function deployRateModel() {
  const RateModel = await ethers.getContractFactory(
    "LinearInterestRateModel"
  );

  const model = await RateModel.deploy();
  await model.waitForDeployment();

  console.log("InterestRateModel deployed at:", model.target);

  return model.target;
}
