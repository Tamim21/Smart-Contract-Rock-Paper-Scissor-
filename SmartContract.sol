
// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

contract RockPaperScissor {

    struct Participant{
        bool point;
        string move;
        bool canPlay;
        address adres;
        bytes32 hash;
    }

    struct Game{
        address Winneradd;
        uint WinningPrize; // the prize that is deposited at first by the manager
        uint playingTime;
        uint revealingTime;
        bool isGameEnded;
        Participant p1;
        Participant p2;
    }

    Game public game;
    
    

    uint public playMoveTimeEnd;
    uint public revealMoveTimeEnd;

    address public contestManager;




    //the `error` keywords are like a an exception that reverts and rollback transaction if done

    error TooEarly(); 
    error TooLate(); // too late to reveal or to play a move
    error gameNotYetEnded();
    error gameEndAlreadyCalled();
    error wrongMove();
    error alreadyPlayed();
    error didnotpaly();
    error wrongcommitment();

    

    event FundsAdded(address sender, uint amount);



    constructor (address[] memory participantsAdds,uint Prize){
        contestManager = msg.sender; // set the address of the manager
        game.WinningPrize = Prize; // set the prize of the game
        playMoveTimeEnd = block.timestamp + game.playingTime; // the exact time to stop accepting moves
        revealMoveTimeEnd = playMoveTimeEnd + game.revealingTime; // the exact time to stop accepting revals
        game.isGameEnded = false;

        emit FundsAdded(msg.sender, Prize); // add the prize value to the contract balance

        game.p1 = Participant(false,"",true,participantsAdds[0],bytes32(0));
        game.p2 = Participant(false,"",true,participantsAdds[1],bytes32(0));



    }
    function commitToMove(bytes32 playerMove) external   { 
        if (block.timestamp > playMoveTimeEnd)
            revert TooLate();
        if (msg.sender == game.p1.adres) {
            game.p1.hash = playerMove;
            if(game.p1.canPlay == true) revert alreadyPlayed();
             game.p1.canPlay = true;
        }else{
            game.p2.hash = playerMove;
            if(game.p2.canPlay == true) revert alreadyPlayed();
             game.p2.canPlay = false;

        }
        
        

    }
    function revealMove(string memory value,string memory nonce) external {
        if (block.timestamp > revealMoveTimeEnd)
            revert TooLate();

        if (block.timestamp < playMoveTimeEnd)
            revert TooEarly();
        
        if (game.isGameEnded)
            revert gameEndAlreadyCalled();
        
        if (msg.sender == game.p1.adres) {
            if(game.p1.canPlay == false) revert didnotpaly();
            if(game.p1.hash != keccak256(abi.encodePacked(value, nonce))) revert wrongcommitment();
            game.p1.move = value;
             
        }else{
            if(game.p2.canPlay == false) revert didnotpaly();
            if(game.p2.hash != keccak256(abi.encodePacked(value, nonce))) revert wrongcommitment();
            game.p2.move = value;
        }
            
             


        

        

        
        
        

    }


    function calculcateWinner() external payable {

        if (block.timestamp < revealMoveTimeEnd)
            revert gameNotYetEnded();
        if (game.isGameEnded)
            revert gameEndAlreadyCalled();
        if(game.p1.canPlay == true) game.Winneradd = game.p2.adres;
        else if(game.p2.canPlay == true) game.Winneradd = game.p1.adres;
        else{

        bytes memory p1 = abi.encodePacked(game.p1.move);
        bytes memory p2 = abi.encodePacked(game.p2.move);
        bytes memory r = abi.encodePacked("rock");
        bytes memory p = abi.encodePacked("paper");
        bytes memory s = abi.encodePacked("sciccsor");


        if(((keccak256(p1) == keccak256(s)) && (keccak256(p1) == keccak256(s))) ||
          ((keccak256(p1) == keccak256(r)) && (keccak256(p2) == keccak256(s)))  || 
          ((keccak256(p1) == keccak256(p)) && (keccak256(p2) == keccak256(r)))) {
            game.Winneradd = game.p1.adres;
        }else {
            game.Winneradd = game.p2.adres;
        }

        payable(game.Winneradd).transfer(game.WinningPrize);
        }
        game.isGameEnded = true;


            

    // Code to be executed for each element
}
    function winner() external view returns (address) {

        if (block.timestamp < playMoveTimeEnd)
            revert gameNotYetEnded();
        return game.Winneradd;
}


    

    
}