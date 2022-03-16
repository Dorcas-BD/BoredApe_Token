// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Staking {
    struct StakingPlan {
        uint256 period;
    }

    struct Stake {
        bool status;
        address stakeHolder;
        uint256 stakedAmount;
        uint256 periodOfStake;
        uint256 depositDate;
        uint256 withdrawalDate;
    }

    uint256 stakeId = 1;

    mapping(uint256 => Stake) private stakeList;
    mapping(string => StakingPlan) private stakingOptions;
    mapping(address => uint256) private rewards;

    event stake_has_been_plcaed(
        uint256 _stakeId,
        address _stakeHolder,
        uint256 _stakedAmount,
        uint256 _duration
    );
    event stake_has_been_removed(uint256 _stakeId, address _stakeHolder);
    event reward_has_been_credited(address _receipient, uint256 _rewardAmount);

    constructor(uint256 _initialSupply) ERC20("BoredApe Token", "BRT") {
        _mint(msg.sender, _initialSupply);
        stakingOptions["3_days"] = StakingPlan(3 days);
        stakingOptions["30_days"] = StakingPlan(30 days);
        stakingOptions["60_days"] = StakingPlan(60 days);
    }

    function decimals() public view virtual override returns (uint8) {
        return 6;
    }

    function getStakingOptionDetails(string memory _stakingOption)
        public
        view
        returns (StakingPlan memory)
    {
        return stakingOptions[_stakingOption];
    }

    function stakeTokens(uint256 _amountToStake, string memory _stakingOptions)
        public
    {
        require(_amountToStake > 0, "Number of tokens is zero");

        uint256 tokenBalance = balanceOf(msg.sender);

        require(
            tokenBalance >= _amountToStake,
            "You don't have enough funds to stake"
        );
        _burn(msg.sender, _amountToStake);

        stakeList[stakeId] = Stake(
            true,
            msg.sender,
            _amountToStake,
            stakingOptions[_stakingOptions].period,
            block.timestamp,
            block.timestamp + stakingOptions[_stakingOptions].period
        );
        emit stake_has_been_plcaed(
            stakeId,
            msg.sender,
            _amountToStake,
            stakingOptions[_stakingOptions].period
        );
        stakeId += 1;
    }

    function viewStake(uint256 _stakeId) public view returns (Stake memory) {
        return stakeList[_stakeId];
    }

    function removeStake(uint256 _stakeId) public {
        require(stakeList[_stakeId].status == true, "Stake is not present");
        require(
            msg.sender == stakeList[_stakeId].stakeHolder,
            "You do not own this stake"
        );
        require(
            block.timestamp > stakeList[_stakeId].withdrawalDate,
            "You can not remove your stake before predefined date"
        );
        stakeList[_stakeId].status = false;
        uint256 periodicInterestRate;
        uint256 interestOverDuration;
        if (stakeList[_stakeId].periodOfStake == 3 days) {
            interestOverDuration = (periodicInterestRate * (1 / 100));
        }
        if (stakeList[_stakeId].periodOfStake == 30 days) {
            interestOverDuration = (periodicInterestRate * (10 / 100));
        }
        if (stakeList[_stakeId].periodOfStake == 60 days) {
            interestOverDuration = (periodicInterestRate * (20 / 100));
        }
        uint256 reward = stakeList[_stakeId].stakedAmount *
            interestOverDuration;
        rewards[msg.sender] += reward / 10**27;
        _mint(msg.sender, stakeList[_stakeId].stakedAmount);
        emit stake_has_been_removed(_stakeId, stakeList[_stakeId].stakeHolder);
    }

    function viewReward() public view returns (uint256) {
        return rewards[msg.sender];
    }

    function claimReward() public {
        require(rewards[msg.sender] > 0, "You don't have any reward to claim");
        uint256 rewardAmount = rewards[msg.sender];
        rewards[msg.sender] = 0;
        _mint(msg.sender, rewardAmount);
        emit reward_has_been_credited(msg.sender, rewardAmount);
    }
}
