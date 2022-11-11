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
    event AnnounceWinner(address);
    event AnnounceDraw(address, address);

    bytes32 internal kecForZero =  keccak256(abi.encode(bytes('0')));
    bytes32 internal kecForOne  =  keccak256(abi.encode(bytes('1')));
    bytes32 internal kecForTwo  =  keccak256(abi.encode(bytes('2')));


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

    /* 
        0 - Rock
        1 - Paper
        2 - Scissors
    */

    function finishGame(address otherPlayer) checkOpponent(otherPlayer) external {

        bool senderFlag = alreadyRevealed[msg.sender];        

        require(senderFlag == true, 'You haven\'t revealed yet');
        require(alreadyRevealed[otherPlayer] == true, 'Your opponent haven\'t revealed');

        require(commitHashes[msg.sender] == getKeccak(revealedValues[msg.sender]), 
        'You\'ve send an incorrect revealed value');

        require(commitHashes[otherPlayer] == getKeccak(revealedValues[otherPlayer]),
        'It seems like your opponent send an incorrect revealed value' );

        bytes32 senderVote = keccak256(abi.encode(bytes(revealedValues[msg.sender])[0]));
        bytes32 opponentVote = keccak256(abi.encode(bytes(revealedValues[otherPlayer])[0]));
 
 
        if (senderVote == opponentVote)
            emit AnnounceDraw(msg.sender, otherPlayer);
        else if ( (senderVote == kecForZero && opponentVote == kecForTwo) || 
                  (senderVote == kecForOne && opponentVote == kecForZero) || 
                  (senderVote == kecForTwo && opponentVote == kecForOne ) )
            emit AnnounceWinner(msg.sender);
        else
            emit AnnounceWinner(otherPlayer);
    }

    function getKeccak(string memory someValue) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(someValue));
    }
}