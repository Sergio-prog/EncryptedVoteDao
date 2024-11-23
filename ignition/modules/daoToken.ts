import { buildModule } from "@nomicfoundation/hardhat-ignition";

export const deployDAOToken = buildModule("DAOToken", async (m) => {
    const initialSupply = 1000000; // 1 million tokens

    const daoToken = await m.contract("DAOToken", [initialSupply]);

    return { daoToken };
});
