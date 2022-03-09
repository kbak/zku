// contracts/MyNFT.sol
// SPDX-License-Identifier: MIT
pragma solidity 0.8.1;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "./merkle.sol";

contract MyNFT is ERC721URIStorage {
    using Strings for uint256;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    // maps each NFT to a merkle tree as soon as the token gets transfered
    mapping(uint256 => Merkle) merkleTrees;

    constructor() ERC721("MyNFT", "MNFT") {
    }

    // mints a new NFT to the 'to' address
    function mint(address to, string memory description)
        public
        returns (uint256)
    {
        // uses next available number as token ID
        _tokenIds.increment();

        uint256 newItemId = _tokenIds.current();
        // mints the token
        _mint(to, newItemId);
        // sets token URI that is generated based on the ID and description
        _setTokenURI(newItemId, genTokenURI(newItemId, description));

        return newItemId;
    }

    // generates a Base64 string representation of token URI
    function genTokenURI(uint256 tokenId, string memory description)
        private
        pure
        returns (string memory)
    {
        bytes memory dataURI = abi.encodePacked(
            '{',
                '"name": "MyNFT #', tokenId.toString(), '"',
                '"description": ', description, '"',
            '}'
        );

        return string(
            abi.encodePacked(
                "data:application/json;base64,",
                Base64.encode(dataURI)
            )
        );
    }

    // updates the merkle root after token transfer
    function _afterTokenTransfer(address /*from*/, address to, uint256 tokenId)
        internal
        override
    {
        if (address(0) == address(merkleTrees[tokenId])) {
            merkleTrees[tokenId] = new Merkle();
        }
        string[] memory data = new string[](4);
        data[0] = uint256(uint160(address(msg.sender))).toString();
        data[1] = uint256(uint160(address(to))).toString();
        data[2] = tokenId.toString();
        data[3] = tokenURI(tokenId);
        merkleTrees[tokenId].update(data);
    }
}