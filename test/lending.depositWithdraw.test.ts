import { expect } from "chai";
import { setupFixture } from "./fixtures";

describe("Deposit & Withdraw", function () {
  it("allows user to deposit and withdraw", async () => {
    const { user, pool, token } = await setupFixture();

    await token.connect(user).approve(pool.target, 100);
    await pool.connect(user).deposit(100);

    expect(await pool.balances(user.address)).to.equal(100);

    await pool.connect(user).withdraw(100);
    expect(await pool.balances(user.address)).to.equal(0);
  });

  it("reverts withdraw when balance is insufficient", async () => {
    const { user, pool } = await setupFixture();

    await expect(
      pool.connect(user).withdraw(1)
    ).to.be.revertedWith("INSUFFICIENT_BALANCE");
  });
});
