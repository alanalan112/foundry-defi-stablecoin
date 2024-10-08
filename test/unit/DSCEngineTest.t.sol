// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {DeployDSCEngine} from "script/DeployDSCEngine.s.sol";
import {DecentralizedStableCoin} from "src/DecentralizedStableCoin.sol";
import {DSCEngine} from "src/DSCEngine.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";

contract DSCEngineTest is Test {
    DeployDSCEngine deployer;
    DecentralizedStableCoin dscCoin;
    DSCEngine dscEngine;
    HelperConfig helperConfig;
    address ethUSDPriceFeed;
    address btcUSDPriceFeed;
    address weth;
    address wbtc;

    address public USER = makeAddr("user");
    uint256 public constant STARTING_BALANCE = 100e18;
    uint256 public constant STARTING_ERC20_BALANCE = 100 ether;
    uint256 public constant AMOUNT_COLLATERAL = 10 ether;

    function setUp() public {
        deployer = new DeployDSCEngine();
        (dscCoin, dscEngine, helperConfig) = deployer.run();
        (ethUSDPriceFeed, btcUSDPriceFeed, weth, wbtc,) = helperConfig.activeNetworkConfig();
        console.log("DSCEngine Address: ", address(dscEngine));
        console.log("DSCCoin Owner Address: ", dscCoin.owner());

        vm.deal(USER, STARTING_BALANCE);
        ERC20Mock(weth).mint(USER, STARTING_BALANCE);
    }

    /*//////////////////////////////////////////////////////////////
                               PRICE TEST
    //////////////////////////////////////////////////////////////*/

    function testGetUSDValue() public view {
        uint256 ethAmount = 15e18;
        // expect: 15e18 * 2000/ETH = 30,000e18
        uint256 expectedValue = 30000e18;
        uint256 actualValue = dscEngine.getUSDValue(weth, ethAmount);
        assertEq(expectedValue, actualValue);
    }

    /*//////////////////////////////////////////////////////////////
                        DEPOSIT COLLATERAL TEST
    //////////////////////////////////////////////////////////////*/

    function testRevertIfDepositAmountSmallerThanZero() public {
        vm.startPrank(USER);
        ERC20Mock(weth).approve(address(dscEngine), AMOUNT_COLLATERAL);

        vm.expectRevert(DSCEngine.DSCEngine__AmountShouldBeGreaterThanZero.selector);
        dscEngine.depositCollateral(weth, 0);
        vm.stopPrank();
    }
}
