// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./fhevm/lib/TFHE.sol";
import "./DaoToken.sol";

contract EncryptedVoteDAO {
    DaoToken public daoToken;
    uint256 public proposalCount;
    uint256 public constant DEFAULT_PROPOSAL_DURATION = 3600;

    struct Proposal {
        eaddress description;
        euint64 yesVotes;
        euint64 noVotes;
        eaddress proposer;
        uint256 deadline;
        mapping(address => bool) hasVoted;
    }

    mapping(uint256 => Proposal) public proposals;

    constructor(address _daoToken) {
        daoToken = DaoToken(_daoToken);
    }

    function createProposal(string memory _description) public {
        proposalCount++;

        Proposal storage newProposal = proposals[proposalCount];
        newProposal.description = _description;
        newProposal.yesVotes = TFHE.asEuint64(0); // Initialize votes
        newProposal.noVotes = TFHE.asEuint64(0);
        newProposal.proposer = TFHE.asEaddress(msg.sender);
        msg.sender;
        newProposal.deadline = block.timestamp + DEFAULT_PROPOSAL_DURATION;

        proposals[proposalCount] = newProposal;
    }

    // Submit a vote (encrypted: 1 = YES, 0 = NO)
    function vote(uint256 proposalId, einput encryptedVote, bytes calldata inputProof) public {
        Proposal storage proposal = proposals[proposalId];
        require(block.timestamp < proposal.endTime, "Voting period ended");

        euint64 vote = TFHE.asEuint64(encryptedVote, inputProof);
        ebool isYesVote = TFHE.eq(vote, TFHE.asEuint64(1)); // Check if YES vote

        // Homomorphic vote addition
        proposal.yesVotes = TFHE.add(proposal.yesVotes, TFHE.select(isYesVote, TFHE.asEuint64(1), TFHE.asEuint64(0)));
        proposal.noVotes = TFHE.add(proposal.noVotes, TFHE.select(isYesVote, TFHE.asEuint64(0), TFHE.asEuint64(1)));

        emit VoteSubmitted(proposalId, msg.sender, vote);
    }

    // Allow results access to a specific address
    function allowResults(uint256 proposalId, address allowedAddress) public {
        Proposal storage proposal = proposals[proposalId];
        require(block.timestamp >= proposal.endTime, "Voting period not over");
        require(msg.sender == proposal.proposer, "Only proposer can allow results");

        // Allow access to encrypted results for the specified address
        TFHE.allow(proposal.yesVotes, allowedAddress);
        TFHE.allow(proposal.noVotes, allowedAddress);

        emit ResultsAllowed(proposalId, allowedAddress);
    }
}
