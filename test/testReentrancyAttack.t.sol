// License 
// SPDX-License-Identifier: MIT

// Solidity compiler version
pragma solidity 0.8.24;

// Libraries
import "forge-std/Test.sol";
import "../src/simpleBank.sol";
import "../src/reentrancyAttack.sol";

// Contract
contract reentrancyAttackTest is Test{

    simpleBank simpleBankTesting;
    reentrancyAttack reentrancyAttackTesting;

    // Variables
    address deployer = vm.addr(1);
    address user = vm.addr(2);
    address attacker;

    // Functions
    function setUp() public {
        vm.startPrank(deployer);
        simpleBankTesting = new simpleBank();
        reentrancyAttackTesting = new reentrancyAttack(address(simpleBankTesting));
        attacker = address(reentrancyAttackTesting);
        vm.stopPrank();
    }

    function testUserCanDeposit() external { 
        uint256 amount = 50 ether;
        vm.deal(user, amount);
        vm.startPrank(user);
        uint256 balanceBefore = simpleBankTesting.userBalance(user);
        simpleBankTesting.deposit{value: amount}();
        uint256 balanceAfter = simpleBankTesting.userBalance(user);
        assert(balanceAfter == balanceBefore + amount);
        vm.stopPrank();
    }

    function testUserCanWithdraw() external { 
        uint256 amount = 50 ether;
        vm.deal(user, amount);
        vm.startPrank(user);
        uint256 balance1 = simpleBankTesting.userBalance(user);
        simpleBankTesting.deposit{value: amount}();
        uint256 balance2 = simpleBankTesting.userBalance(user);
        simpleBankTesting.withdraw();
        uint256 balance3 = simpleBankTesting.userBalance(user);
        assert(balance2 == balance1 + amount);
        assert(balance3 == balance2 - amount);
        vm.stopPrank();
    }

    function testAttackerCanSteal() external { 
        uint256 amountUser = 50 ether;
        vm.deal(user, amountUser);

        vm.startPrank(user);
        simpleBankTesting.deposit{value: amountUser}();
        uint256 balanceUser = simpleBankTesting.userBalance(user);
        vm.stopPrank();

        uint256 amountAttacker = 10 ether;
        vm.deal(attacker, amountAttacker);

        vm.startPrank(attacker);
        uint256 balanceBefore = simpleBankTesting.userBalance(attacker);
        reentrancyAttackTesting.attack{value: amountAttacker}();
        uint256 balanceAfter = address(reentrancyAttackTesting).balance;
        assert(balanceAfter == balanceBefore + amountAttacker + balanceUser);
        vm.stopPrank();
    }

}