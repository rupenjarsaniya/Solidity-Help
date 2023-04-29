// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./MintProfileImage.sol";

contract Admin {
    uint256 private index;
    MintProfileImage private mintProfileImage;
    struct UserData {
        address ethAddress;
        string name;
        string description;
        uint256 timestamp;
        address[] followers;
        address[] followings;
        bool isActive;
        string profileImage;
    }
    struct PostData {
        uint256 id;
        address ethAddress;
        string imageUrl;
        string description;
        address[] likes;
        uint256 timestamp;
    }
    struct CommentData {
        address commmenter;
        string text;
    }
    mapping(address => UserData) public users;
    PostData[] public posts;
    mapping(uint256 => CommentData[]) public comments;
    mapping(address => uint256[]) public myPostIndex;

    constructor(MintProfileImage MintProfileImageAddress) {
        mintProfileImage = MintProfileImageAddress;
    }

    modifier isUsersPost(uint256 id, uint256 _index) {
        require(
            posts[_index].id == id && posts[_index].ethAddress == msg.sender,
            "Invalid request"
        );
        _;
    }

    modifier isUser(address _address) {
        require(users[_address].ethAddress == _address, "User not exist");
        _;
    }

    function register(
        string memory name,
        string memory description,
        string memory profileImage
    ) external {
        require(
            users[msg.sender].ethAddress == address(0),
            "User already registered"
        );

        UserData storage userData = users[msg.sender];
        userData.ethAddress = msg.sender;
        userData.name = name;
        userData.description = description;
        userData.timestamp = block.timestamp;
        userData.isActive = true;
        userData.profileImage = profileImage;

        mintProfileImage.mint(msg.sender, profileImage);
    }

    function follow_unfollow(address _address)
        external
        isUser(msg.sender)
        isUser(_address)
    {
        require(_address != msg.sender, "User cannot follow him/her self");
        address[] storage followers = users[_address].followers;
        address[] storage followings = users[msg.sender].followings;

        for (uint256 i = 0; i < followers.length; i++) {
            if (followers[i] == msg.sender && followings[i] == _address) {
                for (uint256 j = i; j < followers.length - 1; j++) {
                    followers[j] = followers[j + 1];
                    followings[j] = followings[j + 1];
                }
                followers.pop();
                followings.pop();
                return;
            }
        }

        users[_address].followers.push(msg.sender);
        users[msg.sender].followings.push(_address);
    }

    function post(string memory url, string memory description)
        external
        isUser(msg.sender)
    {
        index++;
        address[] memory likes;
        posts.push(
            PostData({
                id: index,
                ethAddress: msg.sender,
                imageUrl: url,
                description: description,
                likes: likes,
                timestamp: block.timestamp
            })
        );
        myPostIndex[msg.sender].push(index - 1);
    }

    function editPost(
        uint256 id,
        uint256 _index,
        string memory description
    ) external isUser(msg.sender) isUsersPost(id, _index) {
        require(
            posts[_index].timestamp + 5 minutes > block.timestamp,
            "You cannot edit this post longer"
        );
        posts[_index].description = description;
    }

    function deletePost(uint256 id, uint256 _index)
        external
        isUser(msg.sender)
        isUsersPost(id, _index)
    {
        for (uint256 i = _index; i < posts.length; i++) {
            posts[i] = posts[i + 1];
        }
        posts.pop();
    }

    function likeDislike(uint256 _index) external isUser(msg.sender) {
        address[] storage likes = posts[_index].likes;

        for (uint256 i = 0; i < likes.length; i++) {
            if (likes[i] == msg.sender) {
                for (uint256 j = i; j < likes.length - 1; j++) {
                    likes[j] = likes[j + 1];
                }
                likes.pop();
                return;
            }
        }

        likes.push(msg.sender);
    }

    function comment(uint256 id, string memory text)
        external
        isUser(msg.sender)
    {
        comments[id].push(CommentData(msg.sender, text));
    }

    function getCommentByPostId(uint256 id)
        external
        view
        returns (CommentData[] memory)
    {
        return comments[id];
    }

    function getPostByIndex(uint256 _index)
        external
        view
        isUser(msg.sender)
        returns (PostData memory)
    {
        return posts[_index];
    }

    function getAllPosts() external view returns (PostData[] memory) {
        return posts;
    }

    function getPosts(address _address)
        external
        view
        isUser(msg.sender)
        returns (PostData[] memory)
    {
        uint256[] memory _indexes = myPostIndex[_address];
        PostData[] memory currentPosts = new PostData[](_indexes.length);
        for (uint256 i = 0; i < _indexes.length; i++) {
            require(
                posts[_indexes[i]].ethAddress == _address,
                "Address not match"
            );
            currentPosts[i] = posts[_indexes[i]];
        }
        return currentPosts;
    }

    function getUser(address _address) external view returns (UserData memory) {
        return users[_address];
    }
}
