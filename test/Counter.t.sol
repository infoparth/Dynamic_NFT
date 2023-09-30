// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {Decentra} from "../src/Decentra.sol";

contract DecentraTest is Test {

    Decentra public dec;
     
     function setUp() public {

        dec = new Decentra("baseURI", "Second_uri", 3);

     }

}
