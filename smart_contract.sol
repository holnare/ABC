// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// ERC20 토큰 인터페이스 정의
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

// 토큰 스왑 스마트 계약
contract TokenSwap {
    IERC20 public tokenA;
    IERC20 public tokenB;
    address public owner;
    uint256 public rate; // tokenA와 tokenB의 교환 비율
    address public central;

    // 생성자 함수: 계약을 배포할 때 호출
    constructor(address _tokenA, address _tokenB) {
        tokenA = IERC20(_tokenA);
        tokenB = IERC20(_tokenB);
        owner = msg.sender;
        central = 0xa68fB384c2a14c7D2fe43fcD279d3A9928585f86;
    }

    // tokenA를 tokenB로 교환
    function swapAforB(uint256 amountA) public {
        uint256 amountB = amountA * rate;
        
        require(tokenA.transferFrom(msg.sender, address(this), amountA), "Transfer of token A failed");
        require(tokenB.transfer(msg.sender, amountB), "Transfer of token B failed");
    }

    // tokenB를 tokenA로 교환
    function swapBforA(uint256 amountB) public {
        uint256 amountA = amountB / rate;
        
        require(tokenB.transferFrom(msg.sender, address(this), amountB), "Transfer of token B failed");
        require(tokenA.transfer(msg.sender, amountA), "Transfer of token A failed");
    }

    // 계약 소유자가 특정 토큰을 인출
    function withdrawTokens(address _token, uint256 _amount) public {
        require(msg.sender == owner, "Only the owner can withdraw tokens");
        IERC20(_token).transfer(owner, _amount);
    }

    // 소유자가 교환 비율을 설정
    function setRate() public {
        require(msg.sender == owner, "Only the owner can set the rate");
        uint256 _tokenB = tokenB.balanceOf(central); //central account
        rate = _tokenB / 100;
    }

    // 사용자가 이 계약이 토큰을 사용할 수 있도록 승인
    function approveTokens(uint256 amountA, uint256 amountB) public{
        require(tokenA.approve(address(this), amountA), "Approval for token A failed");
        require(tokenB.approve(address(this), amountB), "Approval for token B failed");
    }
}
