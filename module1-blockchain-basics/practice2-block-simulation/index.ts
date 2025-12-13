import { Blockchain } from './blockchain.ts';

const blockchain = new Blockchain();

console.log("Blockchain initialized.");
console.log("Genesis Block:", blockchain.chain[0]);

// Add transactions
console.log("\nAdding transactions...");
blockchain.newTransaction("Alice", "Bob", 50);
blockchain.newTransaction("Bob", "Charlie", 20);

// Mine block 2
console.log("\nStarting mining for Block 2...");
const block2 = blockchain.mine();
console.log("Block 2 mined:", JSON.stringify(block2, null, 2));
console.log("Block 2 Hash:", Blockchain.hash(block2));

// Add more transactions
console.log("\nAdding transactions...");
blockchain.newTransaction("Charlie", "Alice", 10);
blockchain.newTransaction("Dave", "Bob", 5);

// Mine block 3
console.log("\nStarting mining for Block 3...");
const block3 = blockchain.mine();
console.log("Block 3 mined:", JSON.stringify(block3, null, 2));
console.log("Block 3 Hash:", Blockchain.hash(block3));

console.log("\nFull Blockchain:");
console.log(JSON.stringify(blockchain.chain, null, 2));

console.log("\nIs blockchain valid?", blockchain.isChainValid());
