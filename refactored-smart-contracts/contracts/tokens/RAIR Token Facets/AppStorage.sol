// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10; 

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

struct RoleData721 {
	mapping(address => bool) members;
	bytes32 adminRole;
}

struct product {
	uint startingToken;
	uint endingToken;
	uint mintableTokens;
	string name;
}

struct AppStorage721 {
	bytes32 secret;
	string baseURI;
	address factoryAddress;
	uint16 royaltyFee;
	product[] products;
	mapping(uint => uint) tokenToProduct;
	mapping(uint => string) uniqueTokenURI;
	mapping(uint => string) productURI;
	mapping(uint => uint[]) tokensByProduct;
	string contractMetadataURI;
	// ERC721
    string _name;
    string _symbol;
    mapping(uint256 => address) _owners;
    mapping(address => uint256) _balances;
    mapping(uint256 => address) _tokenApprovals;
	mapping(address => mapping(address => bool)) _operatorApprovals;
	// ERC721 Enumerable
	mapping(address => mapping(uint256 => uint256)) _ownedTokens;
    mapping(uint256 => uint256) _ownedTokensIndex;
    uint256[] _allTokens;
    mapping(uint256 => uint256) _allTokensIndex;
	// Access Control Enumerable
	mapping(bytes32 => RoleData721) _roles;
	string failsafe;
}

library LibAppStorage721 {
	function diamondStorage() internal pure	returns (AppStorage721 storage ds) {
		assembly {
			ds.slot := 0
		}
	}
}

contract AccessControlAppStorageEnumerable721 is Context {
	AppStorage721 internal s;

	event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);
	event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    function grantRole(bytes32 role, address account) public onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) public onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    function _checkRole(bytes32 role, address account) internal view {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

	function hasRole(bytes32 role, address account) public view returns (bool) {
		return s._roles[role].members[account];
	}

	function getRoleAdmin(bytes32 role) public view returns (bytes32) {
		return s._roles[role].adminRole;
	}

	function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal {
		bytes32 previousAdminRole = getRoleAdmin(role);
		s._roles[role].adminRole = adminRole;
		emit RoleAdminChanged(role, previousAdminRole, adminRole);
	}

	function _grantRole(bytes32 role, address account) internal {
		if (!hasRole(role, account)) {
			s._roles[role].members[account] = true;
			emit RoleGranted(role, account, _msgSender());
		}
	}

	function _revokeRole(bytes32 role, address account) internal {
		if (hasRole(role, account)) {
			s._roles[role].members[account] = false;
			emit RoleRevoked(role, account, _msgSender());
		}
	}
}