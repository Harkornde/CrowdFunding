//SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "./IErc20.sol";

contract CrowdFunding {
    event launch(
        uint _count,
        address indexed _owner,
        uint32 _startAt,
        uint32 _endAt
    );

    event cancel(uint _id);
    event pledge(uint256 _id, address _address, uint256 _amount);
    event unPledge(uint256 _id, address indexed _address, uint _amount);
    event claim(uint256 _id);

    struct Campaign {
        address campaignOwner;
        uint32 startAt;
        uint32 endAt;
        uint256 pledge;
        uint256 goal;
        bool claimed;
    }

    IERC20 public immutable token;
    uint256 public count;
    mapping(uint256 => Campaign) public Campaigns;
    mapping(uint256 => mapping(address => uint)) pledgedAmount;

    constructor(address _token) {
        token = IERC20(_token);
    }

    function Launch(uint32 _startAt, uint32 _endAt, uint256 _goal) external {
        require(_startAt >= block.timestamp, "Start at < now");
        require(_endAt >= _startAt, "end at < start at");
        require(_endAt <= block.timestamp + 7 days);

        count += 1;

        Campaigns[count] = Campaign({
            campaignOwner: msg.sender,
            startAt: _startAt,
            endAt: _endAt,
            pledge: 0,
            goal: _goal,
            claimed: false
        });

        emit launch(count, msg.sender, _startAt, _endAt);
    }

    function Cancel(uint _Id) external {
        Campaign memory campaign = Campaigns[_Id];
        require(msg.sender == campaign.campaignOwner, "Only owner can call");
        require(block.timestamp > campaign.startAt, "Not started");

        delete Campaigns[_Id];
        emit cancel(_Id);
    }

    function Pledge(uint _id, uint _amount) external {
        Campaign storage campaign = Campaigns[_id];
        require(block.timestamp >= campaign.startAt, "Not started");
        require(block.timestamp <= campaign.endAt, "Ended");
        campaign.pledge += _amount;
        pledgedAmount[_id][msg.sender] += _amount;
        token.transferFrom(msg.sender, address(this), _amount);
        emit pledge(_id, msg.sender, _amount);
    }

    function UnPledge(uint256 _id, uint256 _amount) external {
        Campaign storage campaign = Campaigns[_id];
        require(block.timestamp > campaign.startAt, "Not started");
        require(block.timestamp < campaign.endAt, "Ended");
        campaign.pledge -= _amount;
        pledgedAmount[_id][msg.sender] -= _amount;

        emit unPledge(_id, msg.sender, _amount);
    }

    function Claimed(uint256 _id) external {
        Campaign storage campaign = Campaigns[_id];
        require(campaign.campaignOwner == msg.sender);
        require(block.timestamp >= campaign.endAt, "ongoing campaign");
        require(campaign.pledge >= campaign.goal, "goal not reached");
        require(!campaign.claimed, "claimed");

        campaign.claimed = true;
        token.transfer(msg.sender, campaign.pledge);
        emit claim(_id);
    }
}
