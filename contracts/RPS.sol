// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract RPS {

    constructor () {}

    mapping(address=>address) public opponent;
    mapping(address=>bytes32) public commitHashes;

    mapping(address=>bool) public playingNow; 

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

    function makeReveal() external {


    }

}