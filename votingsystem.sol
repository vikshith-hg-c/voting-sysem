// SPDX-License-Identifier: unlicensed
pragma solidity ^0.8.0;

contract election{

    address ADMIN;
    bool electionActive = false;
    address[] candidateAddress;
    address public winner;

    constructor() {
        ADMIN = msg.sender;
    }

    struct voter{
        string name;
        address UID;
        uint votingPowerCount;
        string voted;
        bool voteDeligated;
    }

    struct candidate{
        string name;
        string proposal;
        address UID;
        uint voteCount;
    }

    mapping(address => candidate) candidates;
    mapping(address => voter) voters;
    mapping(address => address)deligatedAddress;  //deligator ==> deligation 


    event eventAddCandidate(address indexed _UID, string _name, string _proposal);
    event voteDeligation(address indexed _voter,address _deligatedvoter);
    event eventAddvoter(address indexed _UID,string _name);
    event winnerDeclare(address indexed _UID,string _name);

    function startElection() external _isAdmin {
        electionActive = true;
    }

    function endElection() external _isAdmin {
        electionActive = false;
    }

    function showResult(address _UID) public view returns(address _candiadteID,string memory _name,uint _votecount){ 
        return(candidates[_UID].UID,candidates[_UID].name,candidates[_UID].voteCount);
    }

    function getWinner() external _isAdmin  {
        uint _winnerVotes = 0 ;
        address _winnerAddress;
        for(uint i =0; i< candidateAddress.length; i++){
            if (candidates[candidateAddress[i]].voteCount > _winnerVotes)
                {
                    _winnerVotes = candidates[candidateAddress[i]].voteCount; 
                    _winnerAddress = candidateAddress[i];
                }
            else continue;
        }
        winner = _winnerAddress;
        emit winnerDeclare(_winnerAddress,candidates[winner].name);
    }

    function addVoter(address _UID,string memory _name) external _isAdmin{
        voters[_UID].name = _name;
        voters[_UID].UID = _UID;
        voters[_UID].votingPowerCount = 1;
        voters[_UID].voteDeligated = false;
        emit eventAddvoter(_UID, _name);
    }

    function addCandiadte(address _UID,string memory _name,string memory _proposal) external _isAdmin{
        candidates[_UID].UID = _UID;
        candidates[_UID].name = _name;
        candidates[_UID].proposal = _proposal;
        candidates[_UID].voteCount = 0;
        emit eventAddCandidate(_UID,_name,_proposal);
        candidateAddress.push(_UID);
    } 

    function checkCandidate(address _UID) public view returns(string memory, string memory){
        return(candidates[_UID].name, candidates[_UID].proposal);
    }

    function castVote(address _candidateUID) external _checkVotePower() _isElectionON() {
        candidates[_candidateUID].voteCount+= 1;
        voters[msg.sender].votingPowerCount-=1;
        voters[msg.sender].voted = candidates[_candidateUID].name;
    }

    function castDeligatedVote(address _candidateUID, address _deligatorAddresss) external _checkDeligation(_deligatorAddresss,msg.sender) {
        candidates[_candidateUID].voteCount+= 1;
        voters[_deligatorAddresss].votingPowerCount-=1;
        voters[_deligatorAddresss].voted = candidates[_candidateUID].name;
    }

    function delegateVote(address _deligation) external _isElectionON() _checkVotePower() {
        deligatedAddress[msg.sender] = _deligation; 
        voters[msg.sender].voteDeligated = true;
        emit voteDeligation(msg.sender,_deligation);
    }

    function viewVoter(address _UID) public view returns(string memory,string memory,bool){
        return(voters[_UID].name,voters[_UID].voted,voters[_UID].voteDeligated);
    }


    modifier _checkVotePower {
        require(voters[msg.sender].votingPowerCount > 0);
        _;
    }

    modifier _checkDeligation(address _deligatorAddresss,address _voterAddress) {
        require(deligatedAddress[_deligatorAddresss] == _voterAddress);
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
