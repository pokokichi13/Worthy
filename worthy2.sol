// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
import "@openzeppelin/contracts/access/Ownable.sol";

contract Treasury is Ownable {
    receive() external payable {}

    event Donated(uint id, uint amount);
    event PrjRegistered(uint id);

    // Project struct
    struct DonationProject{
        address prjAddress;
        uint totalDonation;
    }
    DonationProject [] public prjs;

    // Check if address is in allowed list to execute setter
    modifier CheckAllowed(address _addr) {
        require(AllowedAddress[_addr] == true, "Must be in allowed list to execute this function");
        _;
    }

    // Check donated balance and prevent from sending too much
    modifier CheckDonatedAmmount(uint _id, uint _value) {
        require(prjs[_id].totalDonation < _value, "Withdrawal amount exceede donated amount");
        _;
    }

    // Add Donor and Project contract so that they can set values later on
    mapping(address=>bool) AllowedAddress;
    function addAllowedAddress(address _addr) public onlyOwner {
        AllowedAddress[_addr] = true;
    }

    // Update total donation
    function updateDonation(address _addr, uint _id, uint amount) CheckAllowed(_addr) public {
        prjs[_id].totalDonation += amount;
        emit Donated(_id, amount);
    }

    // Get total donation 
    function getTotalDonations(uint _id) view public returns(uint) {
        return prjs[_id].totalDonation;
    }

    // Project calls this to register itself
    function registerPrj(address _prjOwner , address _addr) CheckAllowed(_addr) public returns(uint){
        DonationProject memory newPrj = DonationProject(_prjOwner, 0);
        prjs.push(newPrj);
        emit PrjRegistered(prjs.length-1);
        return prjs.length-1;
    }

    function totalBal() view external returns(uint){
        return address(this).balance;
    }

    // Withdraw from this contract to prj
    function sendToPrj(uint _id) external payable onlyOwner CheckDonatedAmmount(_id, msg.value/10e13) {
        (bool success,) = prjs[_id].prjAddress.call{value: msg.value}('');
        require(success, "Failed to send ether to prj address");
    }
}

contract Donor {
    // To find out which prj a user donated to by how much
    // There are many users who can donate to many prjs
    struct Donated{
        uint prjid;
        uint donatedAmount;
    }
    mapping(address => Donated[]) public user2Prj;

    function donate(address _treasureAddress, uint _id) public payable {

        // Donate to the to address
        (bool success,) = _treasureAddress.call{value: msg.value}('');
        require(success, "Failed to send money");

        // Add to total Donation by calling Treasury contract
        Treasury(payable(_treasureAddress)).updateDonation(address(this), _id, msg.value/10e13);

        // Add to User's donation amount against the ID
        bool found = false;
        uint userDonatedSize = user2Prj[msg.sender].length;
        
        for(uint i=0; i<userDonatedSize; i++){
            uint id = user2Prj[msg.sender][i].prjid;
            if(id == _id)
            {
                user2Prj[msg.sender][i].donatedAmount += msg.value/10e13;
                found = true;
            }
        }
        if(!found){
            Donated memory newDonated = Donated(_id, msg.value/10e13);
            user2Prj[msg.sender].push(newDonated);
        }
    }

    // parameter is temporary. specifying Treasury contract
    function getMyPrj() view external returns (uint256 [] memory _ids, uint256 [] memory _total) {
        uint userDonatedSize = user2Prj[msg.sender].length;
        uint[] memory _prjID = new uint[](userDonatedSize);
        uint[] memory _totalAmount = new uint[](userDonatedSize);

        for(uint i=0; i<userDonatedSize; i++){
            _prjID[i] = user2Prj[msg.sender][i].prjid;
            _totalAmount[i] = user2Prj[msg.sender][i].donatedAmount;
        }
        
        return (_prjID, _totalAmount);
    }
}

// Assuming project evaluation is all done
contract Project {

    event PrjCreated(uint id);

    struct Prj{
        string url;
        address owner;
        bool approved;
        uint treasuryId;
        // TBD add more elements
    }
    Prj [] public prjs;

    // Modifier that checks if project has been approved
    /*
    modifier CheckAllowed(address _addr) {
        require(AllowedAddress[_addr] == true, "Must be in allowed list to execute this function");
        _;
    }
    */
    function createPrj(string memory _url, address _owner) external {
        // There is no null so setting 999
        Prj memory newPrj = Prj(_url, _owner, false, 999);
        prjs.push(newPrj);
        emit PrjCreated(prjs.length-1);
    }

    function register(address _treasureAddress, uint _prjNumber) external {
        uint _treasuryID = Treasury(payable(_treasureAddress)).registerPrj(prjs[_prjNumber].owner , address(this));
        prjs[_prjNumber].treasuryId = _treasuryID;
    }

    function getTotalDonation(address _treasureAddress, uint _prjNumber) external view returns (uint) {
        return Treasury(payable(_treasureAddress)).getTotalDonations(prjs[_prjNumber].treasuryId);
    }
}
