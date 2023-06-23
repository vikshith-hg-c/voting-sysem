// SPDX-License-Identifier: unlicensed
pragma solidity ^0.8.0;

contract election{

    address ADMIN;
    bool electionActive = false;
    address[] candidateAddress;
    address winner;

    constructor() {
        ADMIN = msg.sender;
    }

    struct voter{
        address UID;
        address[] deligatedAddress;
        uint votingPowerCount;
    }

    struct candidate{
        string name;
        string proposal;
        address UID;
        uint votecount;
    }

    mapping(address => candidate) candidates;
    mapping(address => voter) voters;
    mapping(address => uint) votes;


    event eventAddCandidate(address indexed _UID, string _name, string _proposal);
    event voteDeligation(address indexed _voter,address _deligatedvoter);

    

    
    function startElection() internal _isAdmin {
        electionActive = true;
    }

    function endElection() internal _isAdmin {
        electionActive = false;
    }

    function showResult() public {
        

    }

    function addVoter(address _UID) internal _isAdmin{
        voters[_UID].UID = _UID;
        voters[_UID].votingPowerCount = 1;
    }

    function addCandiadte(address _UID,string memory _name,string memory _proposal) external _isAdmin{
        candidates[_UID].UID = _UID;
        candidates[_UID].name = _name;
        candidates[_UID].proposal = _proposal;
        candidates[_UID].votecount = 0;
        emit eventAddCandidate(_UID,_name,_proposal);
        candidateAddress.push(_UID);
    } 

    function checkCandidate(address _UID) public view returns(string memory, string memory){
        return(candidates[_UID].name, candidates[_UID].proposal);
    }

    function castVote(address _candidateUID) external _checkVotePower() _isElectionON() {
        candidates[_candidateUID].votecount+= 1;
        votes[_candidateUID]+=1;
    }

    function delegateVote(address _voter) external _isElectionON() _checkVotePower() {
        voters[msg.sender].votingPowerCount-= 1;
        voters[_voter].votingPowerCount+= 1;
        emit voteDeligation(msg.sender,_voter);

    }



    //function deligateVote() external _isVoter {}



    modifier _checkVotePower {
        require(voters[msg.sender].votingPowerCount > 0);
        _;
    }

    modifier _isAdmin {
        require(msg.sender == ADMIN);
        _;
    } 

    modifier _isElectionON {
        require(electionActive == true);
        _;
    }
    


}
