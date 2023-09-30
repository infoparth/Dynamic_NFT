// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "../lib/openzeppelin-contracts/contracts/utils/Counters.sol";

contract Decentra is ERC721 {
    using Counters for Counters.Counter;

    string s_base_URI;
    string s_second_URI;
    uint8 immutable MAX_LEVEL;
    address public s_owner;

    struct user{            

        uint8 level;
        string final_URI;

    }

    mapping (uint => user) public s_ids;        
    address[]  can_mint;

    event ownerChanged(address indexed prevOwner, address indexed newOwner);
    event newMinterAdded(address indexed newMinter);
    event minterRemoved(address indexed minter);

    Counters.Counter private _tokenIdCounter;

    modifier onlyOwner(){
        require(msg.sender == s_owner, "You are not the owner");
        _;
    }

    modifier ownerOrMinter(){
        require(msg.sender == s_owner || _isApproved(msg.sender) != 0, "You are not authorized to access this");
        _;
    }

    constructor(string memory _baseURI, string memory _secondURI, uint8 _MAX_LEVEL) ERC721("Decentra", "DCS") {
    s_base_URI = _baseURI;
    s_second_URI = _secondURI;
    MAX_LEVEL = _MAX_LEVEL;
    s_owner = msg.sender;

    }

    function safeMint(address to, string memory _finalURI)
    public 
    ownerOrMinter()
    {

        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        s_ids[tokenId].final_URI = _finalURI;

    }

    function scoreUpdate(uint id) 
    public 
    ownerOrMinter()
    {
        require(s_ids[id].level < MAX_LEVEL, "The Id is already on the maxz level");
        s_ids[id].level += 1;

    }

    function addMinter(address _add)
    public
    onlyOwner()
    {

        can_mint.push(_add);
        emit newMinterAdded(_add);

    }

    function removeMemebers(address _remove)
    public
    onlyOwner()
    {

        uint index = _isApproved(_remove);
        require(index != 0, "Minter does not exist");
        index -= 1;
        require(index < can_mint.length);
        can_mint[index] = can_mint[can_mint.length-1];
        can_mint.pop();

        emit minterRemoved(_remove);

    }


    function _isApproved(address _add)
    internal
    view
    onlyOwner()
    returns(uint)
    {

        uint len = can_mint.length;
        for(uint i = 0; i < len; i++){

            if(can_mint[i] == _add){
                return (i + 1);
            }
        }

        return (0);

    }

    function changeOwner(address _newOwner)
    public 
    onlyOwner()
    {

        address oldOwner = s_owner;
        s_owner = _newOwner;

        emit ownerChanged(oldOwner, _newOwner);
 
    }

    //The following functions are overrides

    function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize)
    internal
    override(ERC721)
    {

        require(from == address(0), "This NFT is non - transferable");
        super._beforeTokenTransfer(from, to, tokenId, batchSize);

    }

    function _burn(uint256 tokenId)
    internal
    override(ERC721)
    {

        require(false, "You cannot burn this NFT");
        super._burn(tokenId);

    }

    function tokenURI(uint256 tokenId)
    public
    view
    override(ERC721)
    returns (string memory)
    {

        require(_exists(tokenId), "Token ID does not exist");
        if(s_ids[tokenId].level == 0){
            return s_base_URI;
        }
        else if(s_ids[tokenId].level == 1){
            return s_second_URI;
        }
        else{
            return s_ids[tokenId].final_URI;
        }

    }

    function supportsInterface(bytes4 interfaceId)
    public 
    view
    override(ERC721)
    returns(bool)
    {

        return super.supportsInterface(interfaceId);

    }
}