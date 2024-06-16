// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";

// the owner of the space will be the one to make set the space is not available when they receive payment through their links

contract Pofi is AccessControl {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE"); 
    bytes32 public constant SPACE_OWNER_ROLE = keccak256("SPACE_OWNER"); 
    

    uint256 public podcastLent;

    address admin;

    enum PodcastStatus {
        ACTIVE,
        AVAILABE,
        NOTAVAILABLE
    }

    struct Podcast {
        string name;
        string title;
        address payable Owner;
        uint256 likes;
        uint256 donationAmount;
        uint256 currentAmount;
        string podcastURI;
        PodcastStatus podcastStatus;
        uint256 duration;
    }

    constructor () {
        _setRoleAdmin(SPACE_OWNER_ROLE, DEFAULT_ADMIN_ROLE); 
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        admin = msg.sender;
    }

    mapping (uint256 => Podcast) public  _podcasts;
    mapping(uint256 => mapping(address => bool)) public hasLiked;

     function createPodcast(string memory _name, string memory _title, string memory _description, string memory _podcastURI) public  {
        Podcast storage podcast = _podcasts[podcastLent];

        podcast.name = _name;
        podcast.title = _title;
        podcast.Owner = payable (msg.sender);
        podcast.podcastStatus = PodcastStatus.ACTIVE;
        podcast.podcastURI = _podcastURI;
        
        podcastLent++;
    }

    function podcastIsNotAvailable(uint256 _index) public {
        require(_index < podcastLent, "space not available");
        require(_podcasts[_index].Owner == msg.sender, "you are not the owner of the space");
        require(_podcasts[_index].podcastStatus == PodcastStatus.ACTIVE, "you are not the owner of the space");

        Podcast storage podcast = _podcasts[_index];
        podcast.podcastStatus = PodcastStatus.NOTAVAILABLE;
    }

     function depositToPodcast(uint256 _podcastLen) public payable  {
        Podcast storage podcast = _podcasts[_podcastLen];
        require(msg.value > 0, "Deposit amount must be greater than zero");

        podcast.donationAmount += msg.value;

        // (bool sent, ) = address(this).call{value: _depositAmount}("");
        // require(sent, "Failed to send Ether");
    }

    function podcastLike(uint256 _podcastLen) external  {
        require(_podcastLen <= podcastLent,"invalid post Id");
        require(!hasLiked[_podcastLen][msg.sender], "You have already liked this post");

        _podcasts[_podcastLen].likes++;
        hasLiked[_podcastLen][msg.sender] = true;
    }
    



    
}