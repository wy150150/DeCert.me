import crypto, { createHash, generateKeyPairSync, sign, verify } from 'crypto';

// 你的昵称
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
 * POW 挖矿函数 - 寻找满足难度要求的 nonce
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
 * 生成 RSA 公私钥对
 */
function generateKeyPair() {
    const { publicKey, privateKey } = generateKeyPairSync('rsa', {
        modulusLength: 2048,
        publicKeyEncoding: {
            type: 'spki',
            format: 'pem'
        },
        privateKeyEncoding: {
            type: 'pkcs8',
            format: 'pem'
        }
    });

    return { publicKey, privateKey };
}

/**
 * 使用私钥对数据进行签名
 */
function signData(privateKey: string, data: string): string {
    const signature = sign('sha256', Buffer.from(data), {
        key: privateKey,
        padding: crypto.constants.RSA_PKCS1_PSS_PADDING,
    });
    return signature.toString('base64');
}

/**
 * 使用公钥验证签名
 */
function verifySignature(publicKey: string, data: string, signature: string): boolean {
    const signatureBuffer = Buffer.from(signature, 'base64');
    return verify('sha256', Buffer.from(data), {
        key: publicKey,
        padding: crypto.constants.RSA_PKCS1_PSS_PADDING,
    }, signatureBuffer);
}

/**
 * 主函数
 */
function main(): void {
    console.log('='.repeat(70));
    console.log('RSA 非对称加密签名验证演示');
    console.log(`昵称: ${NICKNAME}`);
    console.log('='.repeat(70));

    // 第 1 步：寻找满足 POW 4 个 0 开头的哈希值
    console.log('\n📌 第 1 步: 寻找满足 POW 条件的哈希值...\n');
    const powResult = mineHash(NICKNAME, 4);
    console.log(`✅ 找到 4 个 0 开头的哈希值!`);
    console.log(`   花费时间: ${powResult.timeMs} ms`);
    console.log(`   Nonce: ${powResult.nonce}`);
    console.log(`   Hash 内容: ${powResult.content}`);
    console.log(`   Hash 值: ${powResult.hash}`);

    // 第 2 步：生成 RSA 公私钥对
    console.log('\n📌 第 2 步: 生成 RSA 公私钥对...\n');
    const { publicKey, privateKey } = generateKeyPair();
    console.log('✅ RSA 密钥对已生成!');
    console.log('\n🔐 公钥 (Public Key):');
    console.log(publicKey);
    console.log('🔑 私钥 (Private Key):');
    console.log(privateKey.substring(0, 200) + '...[已截断]');

    // 第 3 步：使用私钥对 "昵称 + nonce" 进行签名
    console.log('\n📌 第 3 步: 使用私钥对数据进行签名...\n');
    const dataToSign = powResult.content; // "昵称 + nonce"
    const signature = signData(privateKey, dataToSign);
    console.log(`✅ 签名完成!`);
    console.log(`   签名的数据: ${dataToSign}`);
    console.log(`   签名结果 (Base64): ${signature.substring(0, 60)}...`);

    // 第 4 步：使用公钥验证签名
    console.log('\n📌 第 4 步: 使用公钥验证签名...\n');
    const isValid = verifySignature(publicKey, dataToSign, signature);
    console.log(`✅ 验证结果: ${isValid ? '✅ 签名有效!' : '❌ 签名无效!'}`);

    // 额外测试：篡改数据后验证
    console.log('\n📌 额外测试: 篡改数据后验证...\n');
    const tamperedData = powResult.content + '_tampered';
    const isValidTampered = verifySignature(publicKey, tamperedData, signature);
    console.log(`   篡改后的数据: ${tamperedData}`);
    console.log(`   验证结果: ${isValidTampered ? '✅ 签名有效' : '❌ 签名无效 (预期结果，数据被篡改)'}`);

    console.log('\n' + '='.repeat(70));
    console.log('RSA 签名验证演示完成!');
    console.log('='.repeat(70));

    // 输出完整摘要
    console.log('\n📋 完整摘要:');
    console.log('-'.repeat(70));
    console.log(`昵称 + Nonce: ${powResult.content}`);
    console.log(`SHA256 哈希值: ${powResult.hash}`);
    console.log(`签名 (完整): ${signature}`);
    console.log(`签名验证: ${isValid ? '通过' : '失败'}`);
}

// 运行主函数
main();
