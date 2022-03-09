// contracts/MyNFT.sol
// SPDX-License-Identifier: MIT
pragma solidity 0.8.1;

contract Merkle {
    // nodes in a merkle tree
    bytes32[] public hashes;
    // map of node indices that have been modified
    mapping(uint256 => bool) private dirtyNodes;

    constructor() {}

    // for simplicity we assume that the length of data is a number that is a power of 2
    function update(string[] memory data) public
    {
        // number of nodes in the merkle tree depending on the number of data elements
        uint256 nNodes = 2 * data.length - 1;

        // we check if the merkle tree has been initialized
        if (0 == hashes.length) {
            // if not, we initialize by presetting fields according to the number of leaves
            for (uint256 i = 0; i < nNodes; ++i) {
                hashes.push(0);
            }
        } else {
            // otherwise, we check if the data matches the preset number of leaves
            require(hashes.length == nNodes);
        }

        // update leaves if they changed. Updated leaves are marked as dirty
        for (uint i = 0; i < data.length; i++) {
            bytes32 hash = keccak256(abi.encodePacked(data[i]));
            if (hash != hashes[i]) {
                hashes[i] = hash;
                dirtyNodes[i] = true;
            }
        }

        updateRoot();
    }

    function getRoot() public view returns (bytes32) {
        return hashes[hashes.length - 1];
    }

    // updates merkle root as long as there is any node marked as dirty
    function updateRoot() private
    {
        // the number of leaves
        uint256 n = (hashes.length + 1) / 2;
        uint256 offset = 0;

        while (n > 0) {
            for (uint256 i = 0; i < n - 1; i += 2) {
                // only update the node if any of its children has been updated
                if (dirtyNodes[offset + i] || dirtyNodes[offset + i + 1]) {
                    hashes[offset + i + n] = keccak256(
                        abi.encodePacked(hashes[offset + i], hashes[offset + i + 1])
                    );
                    dirtyNodes[offset + i] = false;
                    dirtyNodes[offset + i + 1] = false;
                    dirtyNodes[offset + i + n] = true;
                    // we don't care if root stays marked as dirty
                }
            }
            offset += n;
            n = n / 2;
        }
    }
}