import * as crypto from 'crypto';

export interface Transaction {
    sender: string;
    recipient: string;
    amount: number;
}

export interface Block {
    index: number;
    timestamp: number;
    transactions: Transaction[];
    proof: number;
    previous_hash: string;
}

export class Blockchain {
    public chain: Block[];
    private currentTransactions: Transaction[];

    constructor() {
        this.chain = [];
        this.currentTransactions = [];
        // Genesis block
        this.createGenesisBlock();
    }

    private createGenesisBlock() {
        const genesisBlock: Block = {
            index: 1,
            timestamp: Date.now(),
            transactions: [],
            proof: 100,
            previous_hash: "0",
        };
        this.chain.push(genesisBlock);
    }

    public getLastError(): string | null {
        return null;
    }

    public newTransaction(sender: string, recipient: string, amount: number): number {
        this.currentTransactions.push({
            sender,
            recipient,
            amount,
        });
        return this.lastBlock().index + 1;
    }

    public lastBlock(): Block {
        return this.chain[this.chain.length - 1];
    }

    public static hash(block: Block): string {
        // We sort keys to ensure consistent JSON stringify order
        const blockString = JSON.stringify(block, Object.keys(block).sort());
        return crypto.createHash('sha256').update(blockString).digest('hex');
    }

    public mine(): Block {
        const lastBlock = this.lastBlock();
        const previousHash = Blockchain.hash(lastBlock);

        let proof = 0;
        let timestamp = Date.now();

        console.log("Mining block " + (lastBlock.index + 1) + "...");

        while (true) {
            const candidateBlock: Block = {
                index: lastBlock.index + 1,
                timestamp: timestamp,
                transactions: this.currentTransactions,
                proof: proof,
                previous_hash: previousHash,
            };

            const blockHash = Blockchain.hash(candidateBlock);

            if (blockHash.substring(0, 4) === '0000') {
                // Found the proof!
                this.chain.push(candidateBlock);
                this.currentTransactions = []; // Reset transactions
                return candidateBlock;
            }

            proof++;
        }
    }

    // Helper to verify the chain integrity
    public isChainValid(): boolean {
        for (let i = 1; i < this.chain.length; i++) {
            const currentBlock = this.chain[i];
            const previousBlock = this.chain[i - 1];

            if (currentBlock.previous_hash !== Blockchain.hash(previousBlock)) {
                return false;
            }

            if (Blockchain.hash(currentBlock).substring(0, 4) !== '0000') {
                return false;
            }
        }
        return true;
    }
}
