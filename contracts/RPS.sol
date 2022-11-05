// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract RPS {

    constructor () {}

    mapping(address=>address) public opponent;
    mapping(address=>bytes32) public commitHashes;

    mapping(address=>bool) public playingNow; 
    mapping(address=>bool) public alreadyRevealed;

    event GameStarted(address, address);

    function startGame(address otherPlayer) external {
        require(opponent[msg.sender] == address(0), 'You already have an opponent');
        require(playingNow[otherPlayer] == false, 'This player is in game already');

        opponent[msg.sender] = otherPlayer;  
        playingNow[msg.sender] = true;
        playingNow[otherPlayer] = true;

        emit GameStarted(msg.sender, otherPlayer);
    }

    function makeCommit(bytes32 hashFromVote, address otherPlayer) external {
        require(playingNow[msg.sender] == true, 'You have not started the game');
        require(opponent[msg.sender] == otherPlayer || opponent[otherPlayer] == msg.sender,
        'You can not start a round with this player');

        commitHashes[msg.sender] = hashFromVote;
    }

    function makeReveal(string calldata actualVote, address otherPlayer) external {
        require(opponent[msg.sender] == otherPlayer || opponent[otherPlayer] == msg.sender,
        'That is not your actual opponent');

        require(commitHashes[msg.sender] != 0, 'You should make a commit at first');
        require(commitHashes[otherPlayer] != 0, 'Your opponent haven\'t made a commit yet');

        alreadyRevealed[msg.sender] = true;
        if (alreadyRevealed[msg.sender] && alreadyRevealed[otherPlayer]) 
            finishGame(msg.sender, otherPlayer);
    }

    function finishGame(address pl1, address pl2) private {
        emit GameStarted(pl1, pl2);
    }
}