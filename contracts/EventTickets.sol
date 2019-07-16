pragma solidity ^0.5.0;

    /*
        The EventTickets contract keeps track of the details and ticket sales of one event.
     */

contract EventTickets {

    /*
        Create a public state variable called owner.
        Use the appropriate keyword to create an associated getter function.
        Use the appropriate keyword to allow ether transfers.
     */
    address payable public owner;

    uint TICKET_PRICE = 100 wei;

    /*
        Create a struct called "Event".
        The struct has 6 fields: description, website (URL), totalTickets, sales, buyers, and isOpen.
        Choose the appropriate variable type for each field.
        The "buyers" field should keep track of addresses and how many tickets each buyer purchases.
    */

    struct Event {
        string description;
        string url;
        uint totalTickets;
        uint sales;
        mapping(address => uint) buyers;
        bool isOpen;
    }

    Event myEvent;

    /*
        Define 3 logging events.
        LogBuyTickets should provide information about the purchaser and the number of tickets purchased.
        LogGetRefund should provide information about the refund requester and the number of tickets refunded.
        LogEndSale should provide infromation about the contract owner and the balance transferred to them.
    */
    event LogBuyTickets(address buyer, uint tickets);
    event LogGetRefund (address refundRequester, uint refundedTickets);
    event LogEndSale (address _owner, uint _sales);

    /*
        Create a modifier that throws an error if the msg.sender is not the owner.
    */
    modifier isOwner{
        require(owner == msg.sender);
        _;
    }

    /*
        Define a constructor.
        The constructor takes 3 arguments, the description, the URL and the number of tickets for sale.
        Set the owner to the creator of the contract.
        Set the appropriate myEvent details.
    */
    constructor (string memory _description, string memory _url, uint ticketsForSale) public {
        owner = msg.sender;
        myEvent.description = _description;
        myEvent.url = _url;
        myEvent.totalTickets = ticketsForSale;
        myEvent.isOpen = true;
    }

    /*
        Define a function called readEvent() that returns the event details.
        This function does not modify state, add the appropriate keyword.
        The returned details should be called description, website, uint totalTickets, uint sales, bool isOpen in that order.
    */
    function readEvent() public view returns(string memory description, string memory website, uint totalTickets, uint sales, bool isOpen) {
        description = myEvent.description;
        website = myEvent.url;
        totalTickets = myEvent.totalTickets;
        sales = myEvent.sales;
        isOpen = myEvent.isOpen;
    }

    /*
        Define a function called getBuyerTicketCount().
        This function takes 1 argument, an address and
        returns the number of tickets that address has purchased.
    */
    function getBuyerTicketCount(address buyer) public view returns(uint) {
            return myEvent.buyers[buyer];
        }

    /*
        Define a function called buyTickets().
        This function allows someone to purchase tickets for the event.
        This function takes one argument, the number of tickets to be purchased.
        This function can accept Ether.
        Be sure to check:
            - That the event isOpen
            - That the transaction value is sufficient for the number of tickets purchased
            - That there are enough tickets in stock
        Then:
            - add the appropriate number of tickets to the purchasers count
            - account for the purchase in the remaining number of available tickets
            - refund any surplus value sent with the transaction
            - emit the appropriate event
    */
    function buyTickets(uint tickets) public payable {
        require(myEvent.isOpen == true, 'Event is not open');
        require(msg.value >= tickets*TICKET_PRICE, 'Insufficient Ether deposited');
        require(myEvent.totalTickets >= tickets, 'Not enough tickets in stock');

        myEvent.buyers[msg.sender] += tickets;
        myEvent.totalTickets -= tickets;
        myEvent.sales += tickets;
        msg.sender.transfer(msg.value - tickets*TICKET_PRICE);
        emit LogBuyTickets(msg.sender, tickets);

    }

    /*
        Define a function called getRefund().
        This function allows someone to get a refund for tickets for the account they purchased from.
        TODO:
            - Check that the requester has purchased tickets.
            - Make sure the refunded tickets go back into the pool of avialable tickets.
            - Transfer the appropriate amount to the refund requester.
            - Emit the appropriate event.
    */
    function getRefund() public payable{
        uint tickets = myEvent.buyers[msg.sender];
        require(tickets!=0, 'No tickets have been purchased');
        myEvent.buyers[msg.sender] = 0;
        myEvent.totalTickets += tickets;
        myEvent.sales -= tickets;
        msg.sender.transfer(tickets*TICKET_PRICE);

        emit LogGetRefund(msg.sender, tickets);
    }

    /*
        Define a function called endSale().
        This function will close the ticket sales.
        This function can only be called by the contract owner.
        TODO:
            - close the event
            - transfer the contract balance to the owner
            - emit the appropriate event
    */
    function endSale() public isOwner{
        myEvent.isOpen = false;
        uint amount = address(this).balance;
        owner.transfer(amount);
        emit LogEndSale(owner, amount);
    }
}
