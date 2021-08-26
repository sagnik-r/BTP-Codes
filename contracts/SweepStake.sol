pragma solidity >=0.7.0 <=0.8.5;
pragma abicoder v2;

contract SweepStake{
	
	struct SweepStakeParticipant{
		address _address;
		string name;
		string memID;
	}

	address[] public participants;

	uint public _numParticipants;

	mapping (address => SweepStakeParticipant) _participants;

	// Event to record a new participant entry
	event ParticipantEntry (address _address);

	// Event to record winner
	event RecordWinner (address _address);

	constructor() {
		_numParticipants = 0;
	}

	function enterSweepStake (string memory _name, string memory _memID) public returns (bool success){
		SweepStakeParticipant memory myDetails = SweepStakeParticipant(msg.sender, _name, _memID);
		_participants[msg.sender] = myDetails;
		participants.push(msg.sender);
		_numParticipants += 1;
		emit ParticipantEntry(msg.sender);
		return true;
	}

	function checkMyEntry () public returns (string memory _name, string memory _memID){
		for (uint i=0; i<participants.length; i++)
		{
			if(participants[i] == msg.sender)
			{
				return (_participants[msg.sender].name, _participants[msg.sender].memID);
			}

		}
		return ("No logs exist", "No logs exist");
	}

	function getWinners (string memory bitcoinBlockHash, uint numWinners) public view returns (string[] memory){
		bytes32 random = keccak256(abi.encodePacked(bitcoinBlockHash));

		uint numParticipants = participants.length;

		uint[] memory allNumbers = new uint[](numParticipants);

		uint[] memory winNumbers = new uint[](numWinners);

		for(uint i=0; i<numParticipants; i++)
		{
			allNumbers[i] = i;
		}

		for(uint i=0; i<numWinners; i++)
		{
			uint n = numParticipants - 1;

			uint r = (uint8(random[random.length - i * 4]) + (uint8(random[random.length - i * 4 - 1]) << 8) + (uint8(random[random.length - i * 4 - 2]) << 16) + (uint8(random[random.length - i * 4 - 3]) << 24)) % n;

			winNumbers[i] = allNumbers[r];

            allNumbers[r] = allNumbers[n - 1];

		}

		string[] memory Winners = new string[](numWinners);

		for(uint i=0; i<numWinners; i++)
		{
			Winners[i] = _participants[participants[uint(winNumbers[i])]].name;
		}

		return Winners;

	}

}
