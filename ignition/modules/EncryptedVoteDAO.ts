import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export const deployEncryptedVoteDAO = buildModule("EncryptedVoteDAO", (m, { daoToken }) => {
    const dao = await m.contract("EncryptedVoteDAO", [daoToken.address]);
    return { dao };
});
