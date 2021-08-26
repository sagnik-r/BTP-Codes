pragma solidity >=0.7.0 <=0.8.5;
pragma abicoder v2;

contract SweepStake{
	
	struct SweepStakeParticipant{
		string name;
		string memID;
	}

	address payable[] public _participants;

	address public _owner;
	
	uint public _numParticipants;

	mapping (address => SweepStakeParticipant) _mapParticipants;

	// Event to record a new participant entry
	event ParticipantEntry (address _address);

	// Event to record winner
	event RecordWinner (address _address);
	
	// Event to record Addition of Price addPrizePool
	event AddPrize (uint value);
	
	//Debugging event
	event RandomNumber (uint value);

	constructor() payable {
		_numParticipants = 0;
		_owner = msg.sender;
	}

	function enterSweepStake (string memory _name, string memory _memID) public returns (bool ){
		SweepStakeParticipant memory myDetails = SweepStakeParticipant(_name, _memID);
		_mapParticipants[msg.sender] = myDetails;
		_participants.push(payable(msg.sender));
		_numParticipants += 1;
		emit ParticipantEntry(msg.sender);
		return true;
	}

	function checkMyEntry () public view returns (string memory _name, string memory _memID){
		for (uint i=0; i<_participants.length; i++)
		{
			if(_participants[i] == msg.sender)
			{
				return (_mapParticipants[msg.sender].name, _mapParticipants[msg.sender].memID);
			}

		}
		return ("No logs exist", "No logs exist");
	}

	function getWinners (string memory bitcoinBlockHash, uint numWinners) public returns (uint[] memory){
		bytes32 random = keccak256(abi.encodePacked(bitcoinBlockHash));

		uint[] memory allNumbers = new uint[](_numParticipants);

		uint[] memory winNumbers = new uint[](numWinners);

		for(uint i=0; i<_numParticipants; i++)
		{
			allNumbers[i] = i;
		}

		for(uint i=0; i<numWinners; i++)
		{
			uint n = _numParticipants - 1;

			uint r = (uint8(random[i * 4]) + (uint8(random[i * 4 + 1]) << 8) + (uint8(random[i * 4 + 2]) << 16) + (uint8(random[i * 4 + 3]) << 24)) % n;

			emit RandomNumber(r);
			
			winNumbers[i] = allNumbers[r];

            allNumbers[r] = allNumbers[n - 1];

		}

		/*string[] memory Winners = new string[](numWinners);

		for(uint i=0; i<numWinners; i++)
		{
			Winners[i] = _mapParticipants[_participants[uint(winNumbers[i])]].name;
		}*/
        
		return winNumbers;

	}
	
	function addPrizePool () public payable OnlyOwner returns (bool success){
	    emit AddPrize(msg.value);
	    return true;
	}
	
	modifier OnlyOwner (){
	    require (msg.sender == _owner, "This can be performed only by the Owner");
	    _;
	}
	
	function getBalance () public view returns (uint){
	    return address(this).balance;
	}
	
	function payWinners (string memory bitcoinBlockHash, uint numWinners) public OnlyOwner returns (string[] memory) {
	    uint[] memory winnerIndices = getWinners(bitcoinBlockHash, numWinners);
	    
	    string[] memory Winners = new string[](numWinners);
	    
	    for(uint i=0; i<numWinners; i++)
	    {
	        Winners[i] = _mapParticipants[_participants[winnerIndices[i]]].memID;
	    }
	    
	    uint transferAmt = (address(this).balance)/numWinners;
	    
	    for(uint i=0; i<numWinners; i++)
	    {
	        //account payable payee = _participants[winnerIndices[i]];
	        //require(_participants[winnerIndices[i]].call.value(transferAmt).gas(35000)());
	        (bool success, ) = _participants[winnerIndices[i]].call{value:transferAmt}("Winnings");
            require(success, "Transfer failed.");
	    }
	    
	    return Winners;
	    
	    //_participants[winnerIndices[0]].transfer(transfer1);
	}

}