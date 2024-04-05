// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Etherise {
    
    // STRUCT TO HOLD ALL ETHERISE CAMPAIGNS
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

    // STRUCT TO HOLD ALL TRANSACTIONS
    struct Transaction {
        uint256 transactionID;
        uint256 amount;
        address contractAddress;
        address transactor;
        uint256 campaignID;
        bool isDeposit; // true if money in, false if money out
    }

    // MAPPING TO STORE CAMPAIGNS BY THEIR CAMPAIGN ID
    mapping(uint256 => Campaign) public campaigns;

    // MAPPING TO STORE TRANSACTIONS BY THE CAMPAIGNS THEY BELONG TO
    mapping(uint256 => Transaction[]) public transactionsByCampaign;

    // STATE TO STORE CAMPAIGN COUNT
    uint256 public campaignCounter;

    // FUNCTION TO ADD A NEW CAMPAIGN: ETH RAISED IS SET TO 0 AND CREATOR'S WALLET IS SET TO MSG.SENDER
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

    // FUNCTION TO GET ALL SINGLE CAMPAIGN DETAILS BY ITS ID
    function getCampaign(uint256 _campaignID) external view returns (Campaign memory) {
        return campaigns[_campaignID];
    }

    // FUNCTION TO RETURN ALL CAMPAIGNS
    function getAllCampaigns() external view returns (Campaign[] memory) {
        Campaign[] memory allCampaigns = new Campaign[](campaignCounter);
        for (uint256 i = 1; i <= campaignCounter; i++) {
            allCampaigns[i - 1] = campaigns[i];
        }
        return allCampaigns;
    }
    

    // FUNCTION TO DELETE A CAMPAIGN BY ITS ID - CAN ONLY BE CALLED BY ITS CREATOR
    function deleteCampaign(uint256 _campaignID) external {
        require(msg.sender == campaigns[_campaignID].creatorWallet, "Only the creator can delete the campaign");
        delete campaigns[_campaignID];
    }

    // FUNCTION TO WITHDRAW FUNDS FROM A CAMPAIGN - CAN ONLY BE CALLED BY ITS CREATOR
    function withdrawFromCampaign(uint256 _campaignID, uint256 _amount) external {
        require(msg.sender == campaigns[_campaignID].creatorWallet, "Only the creator can withdraw from the campaign");
        require(_amount <= campaigns[_campaignID].ethRaised, "Withdrawal amount exceeds raised funds");
        payable(msg.sender).transfer(_amount);
        campaigns[_campaignID].ethRaised -= _amount;
    }

    // FUNCTION TO GET TRANSACTIONS BY THE CAMPAIGN THEY BELONG TO
    function getTransactionsByCampaign(uint256 _campaignID) external view returns (Transaction[] memory) {
        return transactionsByCampaign[_campaignID];
    }

    // FUNCTION TO DONATE TO AN ETHERISE CAMPAIGN
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
