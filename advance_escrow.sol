pragma solidity ^0.8.0;
contract advance_escrow{
    address payable public buyer;
    address payable public seller;
    uint public timeToExpiry;
    uint public timeToReturn;
    uint public startTime;
    uint public receivedTime;
    uint public deposit;
    string public status;

    //buyer sets up the escrow contract and pays the deposit
    function escrow(address payable _seller, uint _timeToExpiry, uint _timeToReturn) public payable{
        buyer = msg.sender;
        seller = _seller;
        deposit = msg.value;
        timeToExpiry = _timeToExpiry;
        timeToReturn = _timeToReturn;
        startTime = block.timestamp;
        status = "Escrow setup";
    }

    //seller updates item shipment information
    function itemShipped(string memory _status) public{
        if(msg.sender == seller){
            status = _status;
        }
        else{
            revert();
        }
    }

    //buyer release partial deposit to seller
    function itemReceived(string memory _status) public payable{
        if (msg.sender == buyer) {
            status = _status;
            receivedTime == block.timestamp;

            //pay 20 % to seller
            if (!seller.send(deposit/5)) {
                revert();
            }

        }
    }

    //buyer releases balance deposit to seller
    function releaseBalanceToSeller() public{
        if(msg.sender == buyer){

            //finish the contract and send all the funds to seller
            selfdestruct(seller);
        }
        else{
            revert();
        }
    }

    //buyer returns the item
    function itemReturnsToSeller(string memory _status) public{
        if (msg.sender != buyer) {
            revert();
        }

        if (block.timestamp > receivedTime + timeToReturn) {
            revert();
        }
        status = _status;
    }

    //seller release balance to buyer
    function releaseBalanceToBuyer() public{
        if(msg.sender == seller){
            revert();
        }

        //finish contract and send remaining funds to buyer
        //20% restoking penalty previously paid to the seller
        selfdestruct(buyer);
    }

    //buyer can withdraw deposit if escrow is expired
    function withdraw() public{
        if (!isExpired()) {
            revert();
        }

        if(msg.sender == buyer){
            selfdestruct(buyer);  //finish the contract and sell all the funds to buyer
        }
        else{
            revert();
        }
    }

    //seller can cancel escrow and return all the funds to buyer
    function cancel() public{
        if(msg.sender == seller){
            selfdestruct(buyer);
        }
        else{
            revert();
        }
    }

    function isExpired() view public returns (bool) {
        if (block.timestamp > startTime + timeToExpiry){
            return true;
        }
        else{
            return false;
        }
    }

}