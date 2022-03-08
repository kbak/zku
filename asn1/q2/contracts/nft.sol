// contracts/MyNFT.sol
// SPDX-License-Identifier: MIT
pragma solidity 0.8.1;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

contract MyNFT is ERC721URIStorage {
    using Strings for uint256;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

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
}