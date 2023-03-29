// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/*write solidity function to implement a multi-signature wallet,
where funds can be released only with the approval of multiple addresses.*/

contract MultiSign {
    address public owner;
    uint256 private transactionIdx;
    uint256 private numOfSignatureRequired;

    uint256[] public pendingTransactions;

    mapping(address => bool) public owners;

    struct Transaction {
        address from;
        address to;
        uint256 amount;
        bool isConfirm;
        uint256 signatureCount;
    }

    mapping(uint256 => mapping(address => bool)) signatures;
    mapping(uint256 => Transaction) public transactions;

    // Events
    event DepositFunds(address from, uint256 amount);
    event WithdrawFunds(address from, uint256 amount);
    event TransactionCreated(address from, address to, uint256 amount);
    event TransactionSigned(address by, uint256 transactionId);
    event TransactionCompleted(
        address from,
        address to,
        uint256 amount,
        uint256 transactionId
    );

    // Constructor
    constructor(uint256 _numOfSignatureRequired) {
        owner = msg.sender;
        numOfSignatureRequired = _numOfSignatureRequired;
    }

    // Modifiers
    modifier isOwner() {
        require(msg.sender == owner, "You can't access!");
        _;
    }

    modifier validOwner() {
        require(
            msg.sender == owner || owners[msg.sender] == true,
            "You are not owner!"
        );
        _;
    }

    // Functions
    // Add new owner
    function addOwner(address _owner) public isOwner {
        owners[_owner] = true;
    }

    // Remove owner
    function removeOwner(address _owner) public isOwner {
        owners[_owner] = false;
    }

    // Deposit funds
    receive() external payable {
        emit DepositFunds(msg.sender, msg.value);
    }

    // Create Transaction
    function tranferTo(address _to, uint256 _amount) public validOwner {
        require(address(this).balance >= _amount, "Not enought balance");

        uint256 transactionId = transactionIdx++;

        transactions[transactionId] = Transaction({
            from: msg.sender,
            to: _to,
            amount: _amount,
            isConfirm: false,
            signatureCount: 0
        });

        pendingTransactions.push(transactionId);

        emit TransactionCreated(msg.sender, _to, _amount);
    }

    // Get pending transactions
    function getPendingTransactions()
        public
        view
        validOwner
        returns (uint256[] memory)
    {
        return pendingTransactions;
    }

    // Get pending transaction
    function getPendingTransaction(uint256 _transactionId)
        public
        view
        validOwner
        returns (Transaction memory)
    {
        return transactions[_transactionId];
    }

    // Sign transaction and release payment
    function signTransaction(uint256 _transactionId) public validOwner {
        Transaction storage transaction = transactions[_transactionId];

        require(
            transaction.from != 0x0000000000000000000000000000000000000000,
            "Transaction must exist"
        );
        require(
            transaction.from != msg.sender,
            "Creator cannot sign the transaction"
        );
        require(
            !signatures[_transactionId][msg.sender],
            "You cannot sign the transaction more than once"
        );

        transaction.signatureCount = transaction.signatureCount + 1;

        signatures[_transactionId][msg.sender] = true;

        emit TransactionSigned(msg.sender, _transactionId);

        // release payment
        if (transaction.signatureCount >= numOfSignatureRequired) {
            require(
                address(this).balance >= transaction.amount,
                "Not enought fund"
            );

            payable(transaction.to).transfer(transaction.amount);

            transactions[_transactionId].isConfirm = true;

            emit TransactionCompleted(
                transaction.from,
                transaction.to,
                transaction.amount,
                _transactionId
            );

            deleteTransaction(_transactionId);
        }
    }

    // Delete transaction
    function deleteTransaction(uint256 _transactionId) public validOwner {
        require(
            transactions[_transactionId].isConfirm,
            "Transaction must exist"
        );

        delete pendingTransactions[_transactionId];

        delete transactions[_transactionId];
    }
}
