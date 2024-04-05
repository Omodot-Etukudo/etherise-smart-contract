// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Etherise {
    
    // Struct to represent a Campaign
    struct Campaign {
        uint256 campaignID;
        string campaignTitle;
        string aboutCampaign;
        uint256 ethGoal;
        uint256 ethRaised;
        string businessName;
        address creatorWallet;
        bool isActive;
        string coverImage;
    }

    // Struct to represent a Transaction
    struct Transaction {
        uint256 transactionID;
        uint256 amount;
        address contractAddress;
        address transactor;
        uint256 campaignID;
        bool isDeposit; // true if money in, false if money out
    }

    // Mapping to store campaigns by their ID
    mapping(uint256 => Campaign) public campaigns;

    // Mapping to store transactions by campaign ID
    mapping(uint256 => Transaction[]) public transactionsByCampaign;

    // Campaign counter
    uint256 public campaignCounter;

    // Function to add a new campaign
    function addCampaign(
        string memory _campaignTitle,
        string memory _aboutCampaign,
        uint256 _ethGoal,
        string memory _businessName,
        bool _isActive,
        string memory _coverImage
    ) external {
        campaignCounter++;
        campaigns[campaignCounter] = Campaign(
            campaignCounter,
            _campaignTitle,
            _aboutCampaign,
            _ethGoal,
            0,
            _businessName,
            msg.sender,
            _isActive,
            _coverImage
        );
    }

    // Function to get details of a specific campaign by its ID
    function getCampaign(uint256 _campaignID) external view returns (Campaign memory) {
        return campaigns[_campaignID];
    }

    // Function to retrieve all campaigns
    function getAllCampaigns() external view returns (Campaign[] memory) {
        Campaign[] memory allCampaigns = new Campaign[](campaignCounter);
        for (uint256 i = 1; i <= campaignCounter; i++) {
            allCampaigns[i - 1] = campaigns[i];
        }
        return allCampaigns;
    }
    

    // Function to delete a campaign by its ID (can only be called by the creator)
    function deleteCampaign(uint256 _campaignID) external {
        require(msg.sender == campaigns[_campaignID].creatorWallet, "Only the creator can delete the campaign");
        delete campaigns[_campaignID];
    }

    // Function to withdraw funds from a campaign (can only be called by the creator)
    function withdrawFromCampaign(uint256 _campaignID, uint256 _amount) external {
        require(msg.sender == campaigns[_campaignID].creatorWallet, "Only the creator can withdraw from the campaign");
        require(_amount <= campaigns[_campaignID].ethRaised, "Withdrawal amount exceeds raised funds");
        payable(msg.sender).transfer(_amount);
        campaigns[_campaignID].ethRaised -= _amount;
    }

    // Function to get transactions by campaign ID
    function getTransactionsByCampaign(uint256 _campaignID) external view returns (Transaction[] memory) {
        return transactionsByCampaign[_campaignID];
    }

    // Function to contribute to a campaign
    function contributeToCampaign(uint256 _campaignID) external payable {
        require(campaigns[_campaignID].isActive, "Campaign is not active");
        campaigns[_campaignID].ethRaised += msg.value;
        transactionsByCampaign[_campaignID].push(Transaction(
            transactionsByCampaign[_campaignID].length + 1,
            msg.value,
            address(this),
            msg.sender,
            _campaignID,
            true
        ));
    }
}
