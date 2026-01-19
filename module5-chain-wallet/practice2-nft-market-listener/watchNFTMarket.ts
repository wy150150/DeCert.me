import {
    createPublicClient,
    formatEther,
    http,
    publicActions,
} from "viem";
import { foundry } from "viem/chains";
import dotenv from "dotenv";

dotenv.config();

// 替换成你部署的 NFTMarket 合约地址
const NFTMARKET_ADDRESS = "0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0";

const main = async () => {
    const publicClient = createPublicClient({
        chain: foundry,
        transport: http(process.env.RPC_URL!),
    }).extend(publicActions);

    console.log('开始监听 NFTMarket 事件...');
    console.log(`合约地址: ${NFTMARKET_ADDRESS}\n`);

    // 先获取历史事件
    const currentBlock = await publicClient.getBlockNumber();
    console.log(`当前区块: ${currentBlock}`);
    console.log('正在扫描历史事件...\n');

    // 获取历史 NFTListed 事件
    const listedLogs = await publicClient.getLogs({
        address: NFTMARKET_ADDRESS,
        event: {
            type: 'event',
            name: 'NFTListed',
            inputs: [
                { type: 'uint256', name: 'tokenId', indexed: true },
                { type: 'address', name: 'seller', indexed: true },
                { type: 'uint256', name: 'price' }
            ]
        },
        fromBlock: 0n,
        toBlock: currentBlock
    });

    listedLogs.forEach((log) => {
        console.log('\n🔔 历史 NFT 上架事件:');
        console.log(`Token ID: ${log.args.tokenId}`);
        console.log(`卖家: ${log.args.seller}`);
        console.log(`价格: ${formatEther(log.args.price!)} Token`);
        console.log(`交易哈希: ${log.transactionHash}`);
        console.log(`区块号: ${log.blockNumber}`);
    });

    // 获取历史 NFTSold 事件
    const soldLogs = await publicClient.getLogs({
        address: NFTMARKET_ADDRESS,
        event: {
            type: 'event',
            name: 'NFTSold',
            inputs: [
                { type: 'uint256', name: 'tokenId', indexed: true },
                { type: 'address', name: 'seller', indexed: true },
                { type: 'address', name: 'buyer', indexed: true },
                { type: 'uint256', name: 'price' }
            ]
        },
        fromBlock: 0n,
        toBlock: currentBlock
    });

    soldLogs.forEach((log) => {
        console.log('\n💰 历史 NFT 售出事件:');
        console.log(`Token ID: ${log.args.tokenId}`);
        console.log(`卖家: ${log.args.seller}`);
        console.log(`买家: ${log.args.buyer}`);
        console.log(`价格: ${formatEther(log.args.price!)} Token`);
        console.log(`交易哈希: ${log.transactionHash}`);
        console.log(`区块号: ${log.blockNumber}`);
    });

    console.log('\n--- 开始监听新事件 ---\n');

    // 监听 NFTListed 事件
    publicClient.watchEvent({
        address: NFTMARKET_ADDRESS,
        event: {
            type: 'event',
            name: 'NFTListed',
            inputs: [
                { type: 'uint256', name: 'tokenId', indexed: true },
                { type: 'address', name: 'seller', indexed: true },
                { type: 'uint256', name: 'price' }
            ]
        },
        onLogs: (logs) => {
            logs.forEach((log) => {
                console.log('\n🔔 检测到 NFT 上架事件:');
                console.log(`Token ID: ${log.args.tokenId}`);
                console.log(`卖家: ${log.args.seller}`);
                console.log(`价格: ${formatEther(log.args.price!)} Token`);
                console.log(`交易哈希: ${log.transactionHash}`);
                console.log(`区块号: ${log.blockNumber}`);
            });
        }
    });

    // 监听 NFTSold 事件
    publicClient.watchEvent({
        address: NFTMARKET_ADDRESS,
        event: {
            type: 'event',
            name: 'NFTSold',
            inputs: [
                { type: 'uint256', name: 'tokenId', indexed: true },
                { type: 'address', name: 'seller', indexed: true },
                { type: 'address', name: 'buyer', indexed: true },
                { type: 'uint256', name: 'price' }
            ]
        },
        onLogs: (logs) => {
            logs.forEach((log) => {
                console.log('\n💰 检测到 NFT 售出事件:');
                console.log(`Token ID: ${log.args.tokenId}`);
                console.log(`卖家: ${log.args.seller}`);
                console.log(`买家: ${log.args.buyer}`);
                console.log(`价格: ${formatEther(log.args.price!)} Token`);
                console.log(`交易哈希: ${log.transactionHash}`);
                console.log(`区块号: ${log.blockNumber}`);
            });
        }
    });

    // 保持程序运行
    process.on('SIGINT', () => {
        console.log('\n停止监听...');
        process.exit();
    });
};

main().catch((error) => {
    console.error('发生错误:', error);
    process.exit(1);
});
