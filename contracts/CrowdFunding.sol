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

    constructor(address _token) {
        token = IERC20(_token);
    }

    function Launch(uint32 _startAt, uint32 _endAt, uint256 _goal) public {
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
}
