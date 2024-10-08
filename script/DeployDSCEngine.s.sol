// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";

import {DecentralizedStableCoin} from "src/DecentralizedStableCoin.sol";
import {DSCEngine} from "src/DSCEngine.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";

contract DeployDSCEngine is Script {
    DecentralizedStableCoin dscCoin;
    DSCEngine dscEngine;
    HelperConfig helperConfig;

    address[] public tokenAddresses;
    address[] public priceFeedAddresses;
    address public constant INITIAL_ADDRESS = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;

    function run() external returns (DecentralizedStableCoin, DSCEngine, HelperConfig) {
        helperConfig = new HelperConfig();
        (address wethUSDPriceFeed, address wbtcUSDPriceFeed, address weth, address wbtc, uint256 deployerKey) =
            helperConfig.activeNetworkConfig();

        tokenAddresses = [weth, wbtc];
        priceFeedAddresses = [wethUSDPriceFeed, wbtcUSDPriceFeed];

        vm.startBroadcast(deployerKey);
        dscCoin = new DecentralizedStableCoin(INITIAL_ADDRESS);
        dscEngine = new DSCEngine(tokenAddresses, priceFeedAddresses, address(dscCoin));

        dscCoin.transferOwnership(address(dscEngine));
        vm.stopBroadcast();

        return (dscCoin, dscEngine, helperConfig);
    }
}
