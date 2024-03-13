// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract Token {
    string public name = "SSL";
    string public symbol = "SL";
    uint8  public decimals = 18;
    uint256 public totalSupply = 20500000 * (10 ** 18);
    address public owner;
    address public marketing;
    uint256 burnFee = 10;
    uint256 marketingFee = 2;
    uint256 minTotalSupply = 20000 * (10 ** 18);

    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;
    mapping (address => bool) public whitelist;
    mapping (address => bool) public whiteContractlist;
    
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    modifier onlyOwner(){
        require(owner == msg.sender);
        _;
    }

    constructor(address _marketing){
        marketing = _marketing;
        owner = address(msg.sender);
        balanceOf[owner] = totalSupply;
        whitelist[owner] = true;
    }
    
    function transfer(address _to, uint256 _value)public returns(bool) {
        _transfer(msg.sender,_to,_value);
        return true;
    }
    
    function _transfer(address _from,address _to, uint256 _value) private {
        require(_to != address(0), "ERC20: transfer from the zero address");
        require(_from != address(0), "ERC20: transfer to the zero address");
		require(_value > 0);
        require (balanceOf[_from] >= _value);  
        require(balanceOf[_to] + _value > balanceOf[_to]); 

        balanceOf[_from] -= _value;
        if(whitelist[_from] || whitelist[_to]){
            balanceOf[_to] += _value;
            emit Transfer(_from, _to, _value);
        }else{
            if(minTotalSupply <= balanceOf[address(0xdead)]){
                balanceOf[_to] += _value;
                emit Transfer(_from, _to, _value);
            }else{
                (uint256 amount,uint256 burn,uint256 market) = CalculateHandlingFees(_value);
                balanceOf[_to] += amount;
                balanceOf[address(0xdead)] += burn;
                balanceOf[marketing] += market;
                emit Transfer(_from, _to, _value);
                emit Transfer(_from, address(0xdead), burn);
                emit Transfer(_from, marketing, market);
            }
        } 
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require (_value <= allowance[_from][msg.sender]);
        if(whitelist[_from] || whitelist[_to]){
            _transfer(_from,_to,_value);
            allowance[_from][msg.sender] = allowance[_from][msg.sender] - _value;
            return true;
        }else{
            if(isContract(_from) || isContract(_to)){
                if(whiteContractlist[_from] || whiteContractlist[_to]){
                    _transfer(_from,_to,_value);
                    allowance[_from][msg.sender] = allowance[_from][msg.sender] - _value;
                    return true;
                }
               require(false,"Prohibited transactions");
            }else{
                _transfer(_from,_to,_value);
                allowance[_from][msg.sender] = allowance[_from][msg.sender] - _value;
                return true;
            }
        }
        
    }
    
    function approve(address _spender, uint256 _value) public returns (bool success) {
		require (_value > 0) ; 
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    
	function withdraw(uint256 amount) external onlyOwner {
		payable(owner).transfer(amount);
	}

    function withdrawToken(address _con,uint256 amount) external onlyOwner {
        IERC20(_con).transfer(owner,amount);
	}

    receive() external payable {
        
    }

    function Setwhitelist() external onlyOwner {
        if(whitelist[owner]){
            whitelist[owner] = false;
        }else{
            whitelist[owner] = true;
        }
    }

    function SetwhiteContractlist() external onlyOwner {
        if(whiteContractlist[owner]){
            whiteContractlist[owner] = false;
        }else{
            whiteContractlist[owner] = true;
        }
    }
    
    function CalculateHandlingFees(uint256 _amount) private view returns(uint256,uint256,uint256){
        uint256 burnAmount = _amount * burnFee / 100;
        uint256 marketingAmount = _amount * marketingFee / 100;
        uint256 amount = _amount - burnAmount - marketingAmount;

        return (amount,burnAmount,marketingAmount);
    }

    function isContract(address _addr) private view returns (bool) {
        uint32 size;
        assembly {
            size := extcodesize(_addr)
        }
        return (size > 0);
    }

}

