// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MyERC1155 {
    mapping(uint256 => mapping(address => uint256)) private _balances;
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);
    event TransferBatch(address indexed operator, address indexed from, address indexed to, uint256[] ids, uint256[] values);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    event URI(string value, uint256 indexed id);

    function balanceOf(address account, uint256 id) public view returns (uint256) {
        require(account != address(0), "Balance query for zero address");
        return _balances[id][account];
    }

    function balanceOfBatch(address[] memory accounts, uint256[] memory ids) public view returns (uint256[] memory) {
        require(accounts.length == ids.length, "Accounts and IDs length mismatch");

        uint256[] memory batchBalances = new uint256[](accounts.length);

        for (uint256 i = 0; i < accounts.length; ++i) {
            batchBalances[i] = balanceOf(accounts[i], ids[i]);
        }

        return batchBalances;
    }

    function setApprovalForAll(address operator, bool approved) public {
        require(operator != msg.sender, "Setting approval status for self");

        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function isApprovedForAll(address account, address operator) public view returns (bool) {
        return _operatorApprovals[account][operator];
    }

    function safeTransferFrom(address from, address to, uint256 id, uint256 amount) public {
        require(to != address(0), "Transfer to zero address");
        require(from == msg.sender || isApprovedForAll(from, msg.sender), "Caller is not owner nor approved");

        _balances[id][from] -= amount;
        _balances[id][to] += amount;

        emit TransferSingle(msg.sender, from, to, id, amount);
    }

    function safeBatchTransferFrom(address from, address to, uint256[] memory ids, uint256[] memory amounts) public {
        require(to != address(0), "Transfer to zero address");
        require(ids.length == amounts.length, "IDs and amounts length mismatch");
        require(from == msg.sender || isApprovedForAll(from, msg.sender), "Caller is not owner nor approved");

        for (uint256 i = 0; i < ids.length; ++i) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            _balances[id][from] -= amount;
            _balances[id][to] += amount;
        }

        emit TransferBatch(msg.sender, from, to, ids, amounts);
    }

    function mint(address to, uint256 id, uint256 amount) public {
        require(to != address(0), "Mint to zero address");

        _balances[id][to] += amount;
        emit TransferSingle(msg.sender, address(0), to, id, amount);
    }

    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts) public {
        require(to != address(0), "Mint to zero address");
        require(ids.length == amounts.length, "IDs and amounts length mismatch");

        for (uint256 i = 0; i < ids.length; ++i) {
            _balances[ids[i]][to] += amounts[i];
        }

        emit TransferBatch(msg.sender, address(0), to, ids, amounts);
    }
}