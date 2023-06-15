// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.7.0 <0.9.0;

contract ProjectContract {
    string public projectName;
    address public projectOwner;
    uint public totalSupply;
    mapping (address => uint) public balances;

    // A struct for proposals
    struct Proposal {
        string description;
        bool executed;
        int currentVote;
        uint voteCount;
        mapping (address => bool) voters;
    }

    Proposal[] public proposals;

    constructor(string memory _projectName, address _projectOwner) {
        projectName = _projectName;
        projectOwner = _projectOwner;
        totalSupply = 100;

        // Issue 100 tokens to the project owner
        balances[projectOwner] = totalSupply;
    }

    function propose(string memory description) public {
        proposals.push();

        Proposal storage newProposal = proposals[proposals.length - 1];

        newProposal.description = description;
        newProposal.executed = false;
        newProposal.currentVote = 0;
        newProposal.voteCount = 0;
    }

    function vote(uint proposalIndex, bool support) public {
        Proposal storage proposal = proposals[proposalIndex];

        // Ensure each address can only vote once
        require(!proposal.voters[msg.sender], "Already voted.");
        require(!proposal.executed, "Proposal already executed.");

        proposal.voters[msg.sender] = true;
        proposal.voteCount += balances[msg.sender];

        if (support) {
            proposal.currentVote += int(balances[msg.sender]);
        } else {
            proposal.currentVote -= int(balances[msg.sender]);
        }

        // Check if all tokens have been used to vote
        if (proposal.voteCount == totalSupply) {
            // If more than 50 tokens voted true, execute the proposal
            if (proposal.currentVote > 0) {
                proposal.executed = true;
            }
        }
    }

    function transfer(address recipient, uint amount) public {
        require(balances[msg.sender] >= amount, "Not enough tokens.");
        balances[msg.sender] -= amount;
        balances[recipient] += amount;
    }
}
