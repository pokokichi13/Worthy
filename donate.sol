// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract DonateContract {
    // Project struct
    struct DonationProject{
        address prjAddress;
        uint totalDonation;
        string url;
    }
    DonationProject [] public prjs;

    // To find out which prj a user donated to by how much
    // There are many users who can donate to many prjs
    struct Donated{
        uint prjid;
        uint donatedAmount;
    }
    mapping(address => Donated[]) public user2Prj;


    // User enters ID of prj
    function donate(uint _id) public payable {
        //find out address
        //address to = prjs[_id].prjAddress;

        // Donate to the to address
        (bool success,) = msg.sender.call{value: msg.value}('');
        require(success, "Failed to send money");

        // Add to total Donation
        // TBD correct calculation
        prjs[_id].totalDonation += msg.value/10^15;

        // Add to User's donation amount against the ID
        // TBD correct calculation
        bool found = false;
        uint userDonatedSize = user2Prj[msg.sender].length;
        
        for(uint i=0; i<userDonatedSize; i++){
            uint id = user2Prj[msg.sender][i].prjid;
            if(id == _id)
            {
                user2Prj[msg.sender][i].donatedAmount += msg.value/10^15;
                found = true;
            }
        }
        if(!found){
            Donated memory newDonated = Donated(_id, msg.value/10^15);
            user2Prj[msg.sender].push(newDonated);
        }
    }

    function getTotalDonations(uint _id) view public returns(uint) {
        return prjs[_id].totalDonation;
    }

    function registerPrj(address _prjOwner, string memory _url) public {
        DonationProject memory newPrj = DonationProject(_prjOwner, 0, _url);
        prjs.push(newPrj);
    }

    function getMyPrj() view external returns (uint256 [] memory _ids, uint256 [] memory _total) {
        uint userDonatedSize = user2Prj[msg.sender].length;
        //uint [userDonatedSize] memory _prjID;
        uint[] memory _prjID = new uint[](userDonatedSize);
        uint[] memory _totalAmount = new uint[](userDonatedSize);
        for(uint i=0; i<userDonatedSize; i++){
            _prjID[i] = user2Prj[msg.sender][i].prjid;
            _totalAmount[i] = user2Prj[msg.sender][i].donatedAmount;
        }
        
        return (_prjID, _totalAmount);
    }
}
