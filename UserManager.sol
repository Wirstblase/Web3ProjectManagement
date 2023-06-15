// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.7.0 <0.9.0;

// Import the ProjectContract
import "./ProjectContract.sol";

contract UserManager {

    struct User {
        string username;
        string profilePicture;
        address[] projectAddresses;
    }

    mapping(address => User) public users;

    function setUser(string memory _username, string memory _profilePicture) public {
        User storage user = users[msg.sender];
        user.username = _username;
        user.profilePicture = _profilePicture;
    }

    function createProject(string memory _projectName) public {
        // Create a new ProjectContract
        ProjectContract newProject = new ProjectContract(_projectName, msg.sender);

        // Add the new project's address to the user's project addresses
        users[msg.sender].projectAddresses.push(address(newProject));
    }

    function addProjectAddress(address _projectAddress) public {
        users[msg.sender].projectAddresses.push(_projectAddress);
    }

    function getUsername(address _address) public view returns (string memory) {
        return users[_address].username;
    }

    function getProfilePicture(address _address) public view returns (string memory) {
        return users[_address].profilePicture;
    }

    function getNumberOfProjects(address _address) public view returns (uint) {
        return users[_address].projectAddresses.length;
    }

    function getProjectAddress(address _address, uint _index) public view returns (address) {
        return users[_address].projectAddresses[_index];
    }
}
