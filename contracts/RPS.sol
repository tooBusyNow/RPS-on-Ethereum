// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract RPS {

    constructor () {}

    mapping(address=>address) public opponent;
    mapping(address=>bytes32) public commitHashes;

    mapping(address=>bool) public playingNow; 
    mapping(address=>bool) public alreadyRevealed;
    mapping(address=>string) private revealedValues;

    event GameStarted(address, address);
    event FinishGame(address);

    modifier checkOpponent (address otherPlayer){
        require(opponent[msg.sender] == otherPlayer || opponent[otherPlayer] == msg.sender,
        'That is not your actual opponent');
        _;
    }

    function startGame(address otherPlayer) external {
        require(opponent[msg.sender] == address(0), 'You already have an opponent');
        require(playingNow[otherPlayer] == false, 'This player is in game already');

        opponent[msg.sender] = otherPlayer;  
        playingNow[msg.sender] = true;
        playingNow[otherPlayer] = true;

        emit GameStarted(msg.sender, otherPlayer);
    }

    function makeCommit(bytes32 hashFromVote, address otherPlayer) checkOpponent(otherPlayer) external {
        require(playingNow[msg.sender] == true, 'You have not started the game');
        commitHashes[msg.sender] = hashFromVote;
    }

    function makeReveal(string calldata actualVote, address otherPlayer) checkOpponent(otherPlayer) external {
        require(commitHashes[msg.sender] != 0, 'You should make a commit at first');
        require(commitHashes[otherPlayer] != 0, 'Your opponent haven\'t made a commit yet');

        alreadyRevealed[msg.sender] = true;
        revealedValues[msg.sender] = actualVote;
    }

    function finishGame(address otherPlayer) checkOpponent(otherPlayer) external {
        require(alreadyRevealed[msg.sender] == true, 'You haven\'t revealed et');
        require(alreadyRevealed[otherPlayer] == true, 'Your opponent haven\'t revealed');

        /* TODO keccak and cases*/
    }

    function getKeccak(string calldata someValue) private pure returns (bytes32) {
        return keccak256(abi.encodePacked(someValue));
    }
}