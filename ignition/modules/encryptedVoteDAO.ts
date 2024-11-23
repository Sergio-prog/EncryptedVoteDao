import { buildModule } from "@nomicfoundation/hardhat-ignition";

export const deployEncryptedVoteDAO = buildModule("EncryptedVoteDAO", async (m, { daoToken }) => {
    const dao = await m.contract("EncryptedVoteDAO", [daoToken.address]);
    return { dao };
});
