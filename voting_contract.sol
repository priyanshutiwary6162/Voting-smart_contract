//SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
contract Vote {
    address electionComision;
    address public winner;
    
    struct Voter {
        string name;
        uint age;
        uint voterId;
        string gender;
        uint voteCandidateId;
        address voterAddress;
    }
    struct Candidate {
        string name;
        string party;
        uint age;
        string gender;
        uint candidateId;
        address candidateAddress;
        uint votes;
    }
    uint nextVoterId = 1;
    uint nextCandidateId = 1;
    uint startTime;
    uint endTime;
    mapping(uint => Voter) voterDetails;
    mapping(uint => Candidate) candidateDetails;
    bool stopVoting;

    constructor() {
        electionComision = msg.sender;
    }

    modifier isVotingOver() {
        require(block.timestamp > endTime || stopVoting == true, "Voting is not over");
        _;
    }
    modifier onlyCommisioner() {
        require(electionComision == msg.sender, "Not from election commission");
        _;
    }
    function candidateRegister(string calldata _name, string calldata _party, uint _age, string calldata _gender) external {
        require(msg.sender != electionComision, "You are from election commission");
        require(candidateVerification(msg.sender) == true, "Candidate Already Registered");
        require(_age >=18, "You are not eligible");
        require(nextCandidateId < 3, "Candidate Registration Full");
        candidateDetails[nextCandidateId] = Candidate(_name, _party, _age, _gender, nextCandidateId, msg.sender, 0);
        nextCandidateId++;
     }
    function candidateVerification(address _person) internal view returns (bool) {
        for(uint i = 1; i< nextCandidateId; i++){
            if(candidateDetails[i].candidateAddress == _person) {
                return false;
            }
        }
        return true;
     }
    function candidateList() public view returns (Candidate[] memory) {
        Candidate[] memory array = new Candidate[](nextCandidateId - 1);
        for(uint i = 1; i < nextCandidateId; i++) {
        array[i-1] = candidateDetails[i];
        }
        return array;
     }
    function voterRegister(string calldata _name, uint _age, string calldata _gender) external {
        require(voterVerification(msg.sender) == true, "Voter Already Registered");
        require(_age >= 18, "You are not eligible to vote");
        voterDetails[nextVoterId] = Voter(_name, _age, nextVoterId, _gender, 0, msg.sender);
        nextVoterId++;
     }
    function voterVerification(address _person) internal view returns(bool) {
        for(uint i = 1; i< nextVoterId; i++) {
            if(voterDetails[i].voterAddress == _person) {
                return false;
            }
        }
        return true;
     }
    function voterList() public view returns (Voter[] memory) {
        Voter[] memory array = new Voter[](nextVoterId - 1);
        for(uint i = 1; i< nextVoterId; i++) {
            array[i-1] = voterDetails[i];
        }
        return array;
     }
    function vote(uint _voterId, uint _id) external {
        require(voterDetails[_voterId].voteCandidateId == 0, "Already voted");
        require(voterDetails[_voterId].voterAddress == msg.sender, "You are not a voter");
        require(startTime != 0, "Voting not started");
        require(nextCandidateId == 3, "Candidate registration not done yet");
        require(_id > 0 && _id < 3, "Invalid Candidate Id");
        voterDetails[_voterId].voteCandidateId = _id;
        candidateDetails[_id].votes++;
     }
    function voteTime(uint _startTime, uint _endTime) external onlyCommisioner() {
        startTime = block.timestamp + _startTime;
        endTime = _startTime + _endTime;
     }
    function votingStatus() public view returns (string memory) {
        if(startTime == 0) {
            return "Voting has not started";
        }
        else if ((startTime != 0 && endTime > block.timestamp) && stopVoting == false) {
        return "In progress";
        } else {
            return "Ended";
        }
     }
    function result() external onlyCommisioner(){
        require(nextCandidateId > 1, "No candidates registered");
        uint maximumVotes = 0;
        address currentWinner;
        for(uint i = 1; i< nextCandidateId; i++) {
            if(candidateDetails[i].votes > maximumVotes) {
                maximumVotes = candidateDetails[i].votes;
                currentWinner = candidateDetails[i].candidateAddress;
            }
        }
        winner = currentWinner;
     }
    function emergency() public onlyCommisioner(){
        stopVoting = true;
     }
}