pragma solidity ^0.5.0;

    /*
        The EventTicketsV2 contract keeps track of the details and ticket sales of multiple events.
     */
contract EventTicketsV2 {

    /*
        Define an public owner variable. Set it to the creator of the contract when it is initialized.
    */
    address payable public owner;
    uint PRICE_TICKET = 100 wei;

    /*
        Create a variable to keep track of the event ID numbers.
    */
    uint public eventId;
    uint public idGenerator;

    /*
        Define an Event struct, similar to the V1 of this contract.
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

    /*
        Create a mapping to keep track of the events.
        The mapping key is an integer, the value is an Event struct.
        Call the mapping "events".
    */
    mapping (uint => Event) events;

    event LogEventAdded(string desc, string url, uint ticketsAvailable, uint eventId);
    event LogBuyTickets(address buyer, uint eventId, uint numTickets);
    event LogGetRefund(address accountRefunded, uint eventId, uint numTickets);
    event LogEndSale(address owner, uint balance, uint eventId);

    /*
        Create a modifier that throws an error if the msg.sender is not the owner.
    */
    modifier isOwner(){
        require(owner == msg.sender);
        _;
    }

    constructor() public{
        owner = msg.sender;
        eventId = 0;
    }

    /*
        Define a function called addEvent().
        This function takes 3 parameters, an event description, a URL, and a number of tickets.
        Only the contract owner should be able to call this function.
        In the function:
            - Set the description, URL and ticket number in a new event.
            - set the event to open
            - set an event ID
            - increment the ID
            - emit the appropriate event
            - return the event's ID
    */
    function addEvent(string memory _description, string memory _url, uint tickets) public isOwner{
        events[eventId].description = _description;
        events[eventId].url = _url;
        events[eventId].totalTickets = tickets;
        events[eventId].isOpen = true;
        eventId += 1;
        emit LogEventAdded(_description, _url, tickets, eventId-1);
     }

    /*
        Define a function called readEvent().
        This function takes one parameter, the event ID.
        The function returns information about the event this order:
            1. description
            2. URL
            3. tickets available
            4. sales
            5. isOpen
    */
    function readEvent(uint _eventId) public view
    returns(string memory _description, string memory _website, uint ticketsAvailable, uint _sales, bool _isOpen) {
        _description = events[_eventId].description;
        _website = events[_eventId].url;
        ticketsAvailable = events[_eventId].totalTickets;
        _sales = events[_eventId].sales;
        _isOpen = events[_eventId].isOpen;
    }

    /*
        Define a function called buyTickets().
        This function allows users to buy tickets for a specific event.
        This function takes 2 parameters, an event ID and a number of tickets.
        The function checks:
            - that the event sales are open
            - that the transaction value is sufficient to purchase the number of tickets
            - that there are enough tickets available to complete the purchase
        The function:
            - increments the purchasers ticket count
            - increments the ticket sale count
            - refunds any surplus value sent
            - emits the appropriate event
    */
    function buyTickets(uint _eventId, uint ticketsCount) public payable{
        require(events[_eventId].isOpen, 'Event is not open');
        require(msg.value >= PRICE_TICKET*ticketsCount, 'Insufficient Ether deposite');
        require(events[_eventId].totalTickets >= ticketsCount, 'Not enough tickets in stock');

        events[_eventId].buyers[msg.sender] += ticketsCount;
        events[_eventId].sales += ticketsCount;
        events[_eventId].totalTickets -= ticketsCount;
        msg.sender.transfer(msg.value - PRICE_TICKET*ticketsCount);

        emit LogBuyTickets (msg.sender, _eventId, ticketsCount);
    }

    /*
        Define a function called getRefund().
        This function allows users to request a refund for a specific event.
        This function takes one parameter, the event ID.
        TODO:
            - check that a user has purchased tickets for the event
            - remove refunded tickets from the sold count
            - send appropriate value to the refund requester
            - emit the appropriate event
    */
    function getRefund(uint _eventId) public{
        uint ticket = events[_eventId].buyers[msg.sender];
        require(ticket != 0, 'No tickets have been purchased');
        events[_eventId].sales -= ticket;
        events[_eventId].buyers[msg.sender] = 0;
        events[_eventId].totalTickets += ticket;
        msg.sender.transfer(ticket*PRICE_TICKET);

        emit LogGetRefund (msg.sender, _eventId, ticket);
    }

    /*
        Define a function called getBuyerNumberTickets()
        This function takes one parameter, an event ID
        This function returns a uint, the number of tickets that the msg.sender has purchased.
    */
    function getBuyerNumberTickets(uint _eventId) public view returns(uint){
        return events[_eventId].buyers[msg.sender];
    }

    /*
        Define a function called endSale()
        This function takes one parameter, the event ID
        Only the contract owner can call this function
        TODO:
            - close event sales
            - transfer the balance from those event sales to the contract owner
            - emit the appropriate event
    */
    function endSale(uint _eventId) public payable isOwner{
        events[_eventId].isOpen = false;
        uint amount = address(this).balance;
        owner.transfer(amount);

        emit LogEndSale(owner, amount, _eventId);
    }
}
