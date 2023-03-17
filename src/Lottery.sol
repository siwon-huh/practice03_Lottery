// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Lottery {

    mapping(address => uint) public map_player_lottery_number;
    uint[] sold_quiz;
    uint16 lottery_winning_number;
    uint256 timestamp;
    bool draw_phase;
    bool claim_phase;
    uint received_msg_value;
    address[] players;
    address[] winners;
    mapping(address => uint256) public map_player_balances;
    constructor () {
        received_msg_value = 0;
        lottery_winning_number = 10;
        timestamp = block.timestamp;
        draw_phase = false;
        claim_phase = false;
    }

    function buy(uint lottery_number) public payable{
        require(msg.value == 0.1 ether);
        if (claim_phase == true){
            // rollover => initialize lottery
            draw_phase = false;
            claim_phase = false;
            timestamp = block.timestamp;
            players = new address[](0);
            winners = new address[](0);
        }
        require(claim_phase == false);
        require(block.timestamp < timestamp + 24 hours);
        require(map_player_lottery_number[msg.sender] != lottery_number+1);
        map_player_lottery_number[msg.sender] = lottery_number+1;

        players.push(msg.sender);
        received_msg_value += msg.value;
    }
    function draw() public {
        require(block.timestamp >= timestamp + 24 hours);
        require(claim_phase == false);

        // pick winners among the players
        for (uint i = 0; i < players.length; i++) {
            address player = players[i];
            if (map_player_lottery_number[player] - 1 == winningNumber()) {
                winners.push(player);
            }
        }

        // distribute lottery prize to the winners
        if (winners.length > 0) {
            uint lottery_prize = received_msg_value / winners.length;
            for (uint i = 0; i < winners.length; i++) {
                address winner = winners[i];
                map_player_balances[winner] += lottery_prize;
            }
        }

        draw_phase = true;
    }

    function claim() public {
        require(draw_phase == true);
        uint winner_prize = map_player_balances[msg.sender];
        map_player_balances[msg.sender] = 0;
        payable(msg.sender).call{value:winner_prize}("");
        received_msg_value -= winner_prize;

        claim_phase = true;
    }

    function winningNumber() public returns(uint16){
        return lottery_winning_number;
    }
}