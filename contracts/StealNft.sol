// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

// Imports
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// Contract
contract StealNft is ERC721, ERC721URIStorage, Ownable {

    // Variables
    uint256 private stealNftPrice = 1000000000000000; // 256/256 mem slot | Willingly of course...
    uint256 private _nextTokenId; // 256/256 mem slot | Equal to 0

    // Constructor
    constructor() ERC721("StealNft", "STLNFT") Ownable(msg.sender) { }

    // Function Overrides
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, ERC721URIStorage) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function tokenURI(uint256 tokenId) public view virtual override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    // Functions

    /**
     * @dev Mints in this collection an NFT with the same metadata as the one given in the foreign ERC721 collection.
     *
     * Requirements:
     *
     * - `nftContractAddress` has to be a valid ERC721 implementation.
     * - `tokenId` has to be a valid token id for the given ERC721.
     * - Be cool
     */
    function steal(address nftContractAddress, uint256 tokenId, address receiverAddress) public payable {
        require(msg.value >= stealNftPrice, "You can't steal for free... Transaction amount insufficient.");

        string memory metadataUri = IERC721Metadata(nftContractAddress).tokenURI(tokenId);

        _safeMint(receiverAddress, ++_nextTokenId);
        _setTokenURI(tokenId, metadataUri);
    }

    /**
     * @dev Adjusts the price of stealing an NFT.
     *
     * Requirements:
     *
     * - `newStealNftPrice` the price to be set for an NFT steal.
     * - Only callable by the contract owner.
     */
    function adjustNftStealPrice(uint256 newStealNftPrice) onlyOwner public {
        stealNftPrice = newStealNftPrice;
    }

    /**
     * @dev Delivers the harvested value in the contract to the owner of the contract.
     */
    function harvestLegallyObtainedMoney() public {
        payable(owner()).transfer(address(this).balance);
    }
}