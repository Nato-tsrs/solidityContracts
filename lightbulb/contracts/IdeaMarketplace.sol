// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract IdeaMarketplace {
  struct Idea {
    address submitter;
    uint256 owner;
    string description;
    bool isPrivate;
    address[] interestedCompanies;
    uint256 votes;
    bool hasNDA;
  }

  mapping(uint256 => Idea) public ideas;
  mapping(address => uint256) public tokens;
  uint256 public nextIdeaId;
  address public owner;

  constructor() public {
    owner = msg.sender;
  }

  event TokensAwarded(address indexed user, uint256 amount);
  event IdeaSubmitted(uint256 indexed ideaId, address indexed submitter);
  event IdeaSubmittedByID(uint256 indexed ideaId, uint256 indexed submitter);
  event IdeaClaimed(uint256 indexed ideaId, address indexed company);
  event Voted(uint256 indexed ideaId, address indexed voter);
  event NDASigned(uint256 indexed ideaId, address indexed company);

  function submitIdea(string memory description, bool isPrivate) public {
    uint256 ideaId = nextIdeaId++;
    ideas[ideaId] = Idea(msg.sender,0, description, isPrivate, new address[](0), 0, false);
    emit IdeaSubmitted(ideaId, msg.sender);
  }

  function submitIdeaWithId(uint256 ownerId, uint256 ideaId, string memory description, bool isPrivate) public {
   // require(ideas[ideaId].submitter == address(0), "Idea ID already used");
    ideas[ownerId] = Idea(msg.sender,ownerId, description, isPrivate, new address[](0), 0, false);
    nextIdeaId = max(nextIdeaId, ideaId + 1); // Ensures nextIdeaId stays ahead
    emit IdeaSubmittedByID(ideaId, ownerId);
  }

  function claimIdea(uint256 ideaId) public {
    require(ideas[ideaId].submitter != address(0), "Idea does not exist");
    require(!ideas[ideaId].isPrivate, "Idea is private");

    ideas[ideaId].interestedCompanies.push(msg.sender);
    emit IdeaClaimed(ideaId, msg.sender);
  }

  function voteForIdea(uint256 ideaId) public {
    require(tokens[msg.sender] > 0, "Not enough tokens to vote");

    ideas[ideaId].votes++;
    tokens[msg.sender]--;
    emit Voted(ideaId, msg.sender);
  }

  function signNDA(uint256 ideaId) public {
    require(!ideas[ideaId].hasNDA, "NDA already signed for this idea");

    ideas[ideaId].hasNDA = true;
    emit NDASigned(ideaId, msg.sender);
  }

  function awardTokens(address user, uint256 amount) public {
    require(msg.sender == owner, "Unauthorized");

    tokens[user] += amount;
    emit TokensAwarded(user, amount);
  }

  // Additional functions for token distribution 

  // Function to retrieve idea owner for a given idea ID
  function getIdeaOwner(uint256 ideaId) public view returns (uint256) {
    require(ideas[ideaId].submitter != address(0), "Idea does not exist");
    return ideas[ideaId].owner;
  }

  // Helper function to get the maximum of two values
  function max(uint256 a, uint256 b) private pure returns (uint256) {
    return a > b ? a : b;
  }
}
