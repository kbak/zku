pragma solidity ^0.8.0;

interface IVerifierCard {
    function verifyProof(
        uint256[2] memory a,
        uint256[2][2] memory b,
        uint256[2] memory c,
        uint256[2] memory input
    ) external view returns (bool);
}

interface IVerifierAnotherCard {
    function verifyProof(
        uint256[2] memory a,
        uint256[2][2] memory b,
        uint256[2] memory c,
        uint256[3] memory input
    ) external view returns (bool);
}

contract AnotherCard {
    address IVerifierCard verifierCard;
    address IVerifierAnotherCard verifierAnotherCard;

    constructor(IVerifierCard _verifierCard, IVerifierAnotherCard _verifierAnotherCard) {
        verifierCard = _verifierCard;
        verifierAnotherCard = _verifierAnotherCard;
    }

    function verifyProofCard(
        uint256[2] memory a,
        uint256[2][2] memory b,
        uint256[2] memory c,
        uint256[2] memory input
    ) public view returns (bool) {
        return verifierCard.verifyProof(a, b, c, input);
    }

    function verifyCard(
        uint256[2] memory a,
        uint256[2][2] memory b,
        uint256[2] memory c,
        uint256[2] memory input
    ) public view returns (bool) {
        require(verifyProofCard(a, b, c, input), "Filed proof check");
        return true;
    }

    function verifyProofAnotherCard(
        uint256[2] memory a,
        uint256[2][2] memory b,
        uint256[2] memory c,
        uint256[3] memory input
    ) public view returns (bool) {
        return verifierAnotherCard.verifyProof(a, b, c, input);
    }

    function verifyAnotherCard(
        uint256[2] memory a,
        uint256[2][2] memory b,
        uint256[2] memory c,
        uint256[3] memory input
    ) public view returns (bool) {
        require(verifyProofAnotherCard(a, b, c, input), "Filed proof check");
        return true;
    }
}