import { createHash } from 'crypto';

// 你的昵称，可以修改为你自己的
const NICKNAME = 'wesley';

/**
 * 计算字符串的 SHA256 哈希值
 */
function sha256(data: string): string {
    return createHash('sha256').update(data).digest('hex');
}

/**
 * 检查哈希值是否以指定数量的 0 开头
 */
function hasLeadingZeros(hash: string, count: number): boolean {
    return hash.startsWith('0'.repeat(count));
}

/**
 * POW 挖矿函数
 * @param nickname 昵称
 * @param difficulty 难度（需要多少个前导 0）
 */
function mineHash(nickname: string, difficulty: number): {
    nonce: number;
    content: string;
    hash: string;
    timeMs: number
} {
    const startTime = Date.now();
    let nonce = 0;

    while (true) {
        const content = `${nickname}${nonce}`;
        const hash = sha256(content);

        if (hasLeadingZeros(hash, difficulty)) {
            const endTime = Date.now();
            return {
                nonce,
                content,
                hash,
                timeMs: endTime - startTime
            };
        }

        nonce++;
    }
}

/**
 * 主函数
 */
function main(): void {
    console.log('='.repeat(60));
    console.log('POW (Proof of Work) SHA256 演示');
    console.log(`昵称: ${NICKNAME}`);
    console.log('='.repeat(60));

    // 寻找 4 个 0 开头的哈希值
    console.log('\n🔍 正在寻找 4 个 0 开头的哈希值...\n');
    const result4 = mineHash(NICKNAME, 4);
    console.log(`✅ 找到 4 个 0 开头的哈希值!`);
    console.log(`   花费时间: ${result4.timeMs} ms`);
    console.log(`   Nonce: ${result4.nonce}`);
    console.log(`   Hash 内容: ${result4.content}`);
    console.log(`   Hash 值: ${result4.hash}`);

    // 寻找 5 个 0 开头的哈希值
    console.log('\n🔍 正在寻找 5 个 0 开头的哈希值...\n');
    const result5 = mineHash(NICKNAME, 5);
    console.log(`✅ 找到 5 个 0 开头的哈希值!`);
    console.log(`   花费时间: ${result5.timeMs} ms`);
    console.log(`   Nonce: ${result5.nonce}`);
    console.log(`   Hash 内容: ${result5.content}`);
    console.log(`   Hash 值: ${result5.hash}`);

    console.log('\n' + '='.repeat(60));
    console.log('POW 演示完成!');
    console.log('='.repeat(60));
}

// 运行主函数
main();
