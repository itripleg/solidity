pragma solidity >=0.8.0 <0.9.0;
//SPDX-License-Identifier: MIT
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Receiver.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";
import "hardhat/console.sol";

//Not yet implemented
struct wizard {
  string sign;
  string house;
}

/**
@title MagicSchool
@author Joshua Bell
@notice ERC1155 experimental blockchain game
@dev uses ChainlinkVRF to randomly sort an address 
*/
contract MagicSchool is ERC1155, Ownable, ERC1155Receiver, VRFConsumerBase {

  ///@notice Headmaster can set a vanity motto visble to entire school
  address payable public headmaster;
  string public motto = "WAGMI";

  /// Vars for chainlink randomness
  uint256 private chainlinkFee = 0.001 * 10 ** 18; // 0.1 LINK (Polygon Mumbai)
  bytes32 private keyHash = 0x6e75b569a01ef56d18cab6a8e71e6600d6ce853834d4a5748b720d06f878b3a4; //Polygon keyHash
  address VRFCoordinator = 0x8C7382F9D8f56b33781fE506E897a4F1e2d17255; // Polygon testnet VRF
  address linkAddress = 0x326C977E6efc84E512bB9C30f76E30c160eD06FB;  //Polygon testnet LINK
  bytes32 internal requestId;

  /// Enrollment vars
  mapping (bytes32 => address) addressWaitingToBeSorted;
  mapping(address => uint) public sortingResults; 
  uint256 enrollmentCost = 1 wei;
  address[] public enrolledStudents;
  string[] signs = ["", "EARTH", "WIND", "FIRE", "WATER"]; //null zero index
  mapping(address => string) public signByAddress;

  
  /// ERC-1155 Tokens
  uint256 public constant HOUSEPOINTS = 0;

  /**
  @notice constructor()
  @dev initializes VRF and LINK token address per network
  */
  constructor() ERC1155("") VRFConsumerBase(VRFCoordinator, linkAddress) 
  {
      headmaster = payable(msg.sender);
      _mint(address(this), HOUSEPOINTS, 10**6, "");
  }
  
  
  function setURI(string memory newuri) public onlyOwner {
      _setURI(newuri);
  }

  ///@dev initial enroll with a payable cost to join
  function enroll() public payable {    
      require(msg.sender != headmaster, "Headmaster cannot enroll!");
      require(enrolledStudents.length < 10, "Students at max capcity!");
        for (uint256 i; i < enrolledStudents.length; i++){
            require (enrolledStudents[i] != msg.sender, "Already enrolled");     
          }
        require( msg.value == enrollmentCost, "Enrollment cost not met");
        // Enrollment process
        enrolledStudents.push(msg.sender);
        setApprovalForAll(address(this), true);
        safeTransferFrom(address(this), msg.sender, 0 , 1000 , ""); //send new student some HousePoints
        setApprovalForAll(address(this), false);
  }

  /// returns an address array of address that have paid the enrollment fee
  function getEnrolledStudents() public view returns (address[] memory){
    return enrolledStudents;
  }

  /** 
    @notice sorting function charges a fee in house points and makes a Chainlink requestRandomness
    call and maps the caller to a requestId to be sorted later 
  */
  function sort() public returns (bytes32){
    require(sortingResults[msg.sender] == 0, "Already sorted!");
    require(LINK.balanceOf(address(this)) >= chainlinkFee, "Not enough LINK in sorting hat!");
    safeTransferFrom(msg.sender, address(this), 0, 100, "");
    requestId = requestRandomness(keyHash, chainlinkFee);
    addressWaitingToBeSorted[requestId] = msg.sender;
    return(requestId);
  }

  ///This function is only called by the ChainlinkVRF once randomness has been generated
  function fulfillRandomness(bytes32, uint256 randomness) internal override {
      uint256 sortvalue = randomness % 5 + 1;
      sortingResults[addressWaitingToBeSorted[requestId]] = sortvalue;
  }

  /** 
    Vanity motto to display for fun. Will add more flexiblity later.
  */

  function setMotto(string memory newMotto) public {
      require (msg.sender == headmaster, "Only Headmaster can set motto.");
      motto = newMotto;
      console.log(msg.sender,"set motto to", motto);
      // emit SetMotto(msg.sender, motto);
  }

  /** 
    The following three functions are ERC1155 inheritence overrides 
    needed for succesful compilation. Need to clean this up
    but we'll be lazy for now
  */

  function supportsInterface(bytes4 interfaceId) public view virtual override(ERC1155, ERC1155Receiver) returns (bool) {
    return super.supportsInterface(interfaceId);
  }

  function onERC1155Received(
      address,
      address,
      uint256,
      uint256,
      bytes memory
  ) public virtual override returns (bytes4) {
      return this.onERC1155Received.selector;
  }

  function onERC1155BatchReceived(
      address,
      address,
      uint256[] memory,
      uint256[] memory,
      bytes memory
  ) public virtual override returns (bytes4) {
      return this.onERC1155BatchReceived.selector;
  }
}
