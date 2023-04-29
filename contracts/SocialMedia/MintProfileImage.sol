// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract MintProfileImage is ERC721 {
    using Counters for Counters.Counter;
    using Strings for uint256;

    Counters.Counter tokenIds;
    mapping(uint256 => string) tokenURIs;
    struct RenderToken {
        uint256 id;
        string uri;
        string space;
    }

    constructor() ERC721("ProfileImageNFT", "PIN") {}

    function setTokenURI(uint256 tokenId, string memory _tokenURI) internal {
        tokenURIs[tokenId] = _tokenURI;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(_exists(tokenId), "URI does not exists on that ID");
        return tokenURIs[tokenId];
    }

    function getAllToken() public view returns (RenderToken[] memory) {
        uint256 latestId = tokenIds.current();
        RenderToken[] memory renderTokens = new RenderToken[](latestId);
        for (uint256 i = 0; i <= latestId; i++) {
            if (_exists(i)) {
                renderTokens[i] = RenderToken(i, tokenURI(i), " ");
            }
        }
        return renderTokens;
    }

    function mint(address recipents, string memory URI)public returns(uint){
        uint newId = tokenIds.current();
        _mint(recipents, newId);
        setTokenURI(newId, URI);
        tokenIds.increment();
        return newId;
    }
}
