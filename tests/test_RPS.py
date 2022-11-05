from asyncio.constants import ACCEPT_RETRY_DELAY
from brownie import RPS, accounts
import brownie, pytest

@pytest.fixture
def contract():
    return RPS.deploy({'from' : accounts[0]})

def test_startGame(contract):
    tx1 = contract.startGame(accounts[1], {'from' : accounts[0]})

    assert contract.opponent(accounts[0]) == accounts[1]
    assert "GameStarted" in tx1.events.keys() 

def test_startAnotherGameBySameAccount(contract):
    contract.startGame(accounts[1], {'from' : accounts[0]})
    with brownie.reverts('You already have an opponent'):
        contract.startGame(accounts[1], {'from' : accounts[0]})

def test_opponentInGameAlready(contract):
    contract.startGame(accounts[1], {'from' : accounts[0]})
    with brownie.reverts('This player is in game already'):
        contract.startGame(accounts[1], {'from' : accounts[3]})

def test_makeCommitWithoutStartingGame(contract):
    with brownie.reverts('You have not started the game'):
        hash4Commit = '6362ca2c8185d05dd5aa73afffe3abde3e88b9c06abc045b6061f18bc9dfdf90' 
        contract.makeCommit(hash4Commit, accounts[1].address)

def test_makeCommitWithoutOpponent(contract):
    contract.startGame(accounts[0], {'from' : accounts[1]})
    contract.startGame(accounts[2], {'from' : accounts[3]})

    with brownie.reverts('You can not start a round with this player'):
        contract.makeCommit('6362ca2c8185d05dd5aa73afffe3abde3e88b9c06abc045b6061f18bc9dfdf90',
        accounts[0], {'from' : accounts[3]})

def test_makeNormalCommit(contract):
    contract.startGame(accounts[0], {'from' : accounts[1]})
    contract.makeCommit('6362ca2c8185d05dd5aa73afffe3abde3e88b9c06abc045b6061f18bc9dfdf90',
        accounts[1], {'from' : accounts[0]})
    
    assert contract.commitHashes(accounts[0]) == '0x6362ca2c8185d05dd5aa73afffe3abde3e' \
        '88b9c06abc045b6061f18bc9dfdf90'
