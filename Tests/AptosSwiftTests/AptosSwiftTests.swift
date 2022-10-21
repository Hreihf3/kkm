import XCTest
@testable import AptosSwift

final class AptosSwiftTests: XCTestCase {
    
    let nodeUrl = URL(string: "https://fullnode.mainnet.aptoslabs.com")!
    let faucetUrl = URL(string: "https://faucet.devnet.aptoslabs.com")!
    
    func testKeyPair() throws {
        let keypair1 = try AptosKeyPairEd25519(mnemonics: "talk speak heavy can high immune romance language alarm sorry capable flame")
        XCTAssertEqual(keypair1.privateKeyHex, "0xf2fff935ff731761e583048d74906fb295d62175814a3b13a84ee5b4122aa6c5")
        XCTAssertEqual(keypair1.publicKey.hex, "0x5e5e5e45810c23fd084de6e9c39bb679454771df9f4277e9ff110427998af8eb")
        XCTAssertEqual(keypair1.address.address, "0x2b8710cebbfd6a63539e0f3940c5ccbb268c0d0b649fd1a0eb39d3687bcafffd")
        
        let keypair2 = try AptosKeyPairEd25519(privateKeyData: Data(hex: "2e0c19e199f9ba403e35817f078114bdcb6ea6341e749f02e4fea83ca055baa7"))
        XCTAssertEqual(keypair2.address.address, "0x43cf7854347a34ec167a1980c324221005936d322683aa592bef6de7e46bc575")
        
        let keypair3 = try AptosKeyPairEd25519(privateKeyData: Data(hex: "105f0dd49fb8eb999efd01ee72def91c65d8a81ae4a4803c42a56df14ace864a"))
        XCTAssertEqual(keypair3.address.address, "0x689b6d1d3e54ebb582bef82be2e6781cccda150a6681227b4b0e43ab754834e5")
    }
    
    func testDecoderAndEncoderExamples() throws {
        XCTAssertEqual(try BorshDecoder().decode(UVarInt.self, from: Data(hex: "cdeaec31")).value.description, "104543565")
        XCTAssertEqual(try BorshEncoder().encode(UVarInt(4294967295)).toHexString(), "ffffffff0f")
        
        XCTAssertEqual(try BorshDecoder().decode(VarData.self, from: Data(hex: "03020304")).data, Data(hex: "020304"))
        XCTAssertEqual(try BorshEncoder().encode(VarData(Data(hex: "020304"))).toHexString(), "03020304")
    }
    
    func testSignTransactionExamples() throws {
        let keyPair = try AptosKeyPairEd25519(seed: Data(hex: "9bf49a6a0755f953811fce125f2683d50429c3bb49e074147e0089a52eae155f"))
        
        let token = try AptosTypeTag.Struct(AptosStructTag.fromString("0x01::aptos_coin::AptosCoin"))
        let args: [Data] = [
            try BorshEncoder().encode(AptosAddress("0xdd")),
            try BorshEncoder().encode(UInt64(1))
        ]
        let payload = try AptosTransactionPayloadEntryFunction(value: .natural(module: "0x1222::coin",
                                                                                func: "transfer",
                                                                                typeArgs: [token],
                                                                                args: args))
        
        let rawTx = try AptosRawTransaction(sender: AptosAddress("0x0a550c18"),
                                            sequenceNumber: 0,
                                            maxGasAmount: 2000,
                                            gasUnitPrice: 0,
                                            expirationTimestampSecs: 18446744073709551615,
                                            chainId: 4,
                                            payload: .EntryFunction(payload))
        let signedTx = try rawTx.sign(keyPair)
        
        XCTAssertEqual(try BorshEncoder().encode(signedTx), Data(hex: "000000000000000000000000000000000000000000000000000000000a550c18000000000000000002000000000000000000000000000000000000000000000000000000000000122204636f696e087472616e73666572010700000000000000000000000000000000000000000000000000000000000000010a6170746f735f636f696e094170746f73436f696e00022000000000000000000000000000000000000000000000000000000000000000dd080100000000000000d0070000000000000000000000000000ffffffffffffffff040020b9c6ee1630ef3e711144a648db06bbb2284f7274cfbee53ffcee503cc1a4920040112162f543ca92b4f14c1b09b7f52894a127f5428b0d407c09c8efb3a136cff50e550aea7da1226f02571d79230b80bd79096ea0d796789ad594b8fbde695404"))
    }
    
    func testSignTransaction2Examples() throws {
        let keyPair = try AptosKeyPairEd25519(seed: Data(hex: "9bf49a6a0755f953811fce125f2683d50429c3bb49e074147e0089a52eae155f"))
        
        let token = try AptosTypeTag.Struct(AptosStructTag.fromString("0x01::aptos_coin::AptosCoin"))
        let arg = AptosTransactionArgument.UInt8(.init(2))
        let script = Data(hex: "a11ceb0b030000000105000100000000050601000000000000000600000000000000001a0102")
        let payload = AptosTransactionPayloadScript(value: AptosScript(code: script, typeArgs: [token], args: [arg]))
        
        let rawTx = try AptosRawTransaction(sender: AptosAddress("0x0a550c18"),
                                            sequenceNumber: 0,
                                            maxGasAmount: 2000,
                                            gasUnitPrice: 0,
                                            expirationTimestampSecs: 18446744073709551615,
                                            chainId: 4,
                                            payload: .Script(payload))
        let signedTx = try rawTx.sign(keyPair)
        
        XCTAssertEqual(try BorshEncoder().encode(signedTx), Data(hex: "000000000000000000000000000000000000000000000000000000000a550c1800000000000000000026a11ceb0b030000000105000100000000050601000000000000000600000000000000001a0102010700000000000000000000000000000000000000000000000000000000000000010a6170746f735f636f696e094170746f73436f696e00010002d0070000000000000000000000000000ffffffffffffffff040020b9c6ee1630ef3e711144a648db06bbb2284f7274cfbee53ffcee503cc1a49200409936b8d22cec685e720761f6c6135e020911f1a26e220e2a0f3317f5a68942531987259ac9e8688158c77df3e7136637056047d9524edad88ee45d61a9346602"))
    }
    
    func testFaucetClientExamples() throws {
        let reqeustExpectation = expectation(description: "Tests")
        let faucetClient = AptosFaucetClient(url: faucetUrl)
        DispatchQueue.global().async {
            do {
                let address1 = try AptosAddress("0x689b6d1d3e54ebb582bef82be2e6781cccda150a6681227b4b0e43ab754834e5")
                let address2 = try AptosAddress("0xde1cbede2618446ed917826e79cc30d93c39eeeef635f76225f714dc2d7e26b6")
                let hashs1 = try faucetClient.fundAccount(address: address1, amount: 1000000).wait()
                let hashs2 = try faucetClient.fundAccount(address: address2, amount: 1000000).wait()
                debugPrint(hashs1 + hashs2)
                XCTAssertTrue(hashs1.count > 0)
                XCTAssertTrue(hashs2.count > 0)

                reqeustExpectation.fulfill()
            } catch {
                reqeustExpectation.fulfill()
            }
        }
        wait(for: [reqeustExpectation], timeout: 30)
    }
    
    func testGetAbiExamples() throws {
        let reqeustExpectation = expectation(description: "Tests")
        let client = AptosClient(url: nodeUrl)
        DispatchQueue.global().async {
            do {
                let accountModule = try client.getAccountModule(address: try AptosAddress("0xf6994988bd40261af9431cd6dd3fcf765569719e66322c7a05cc78a89cd366d4"), moduleName: "FixedPriceMarket").wait()
                XCTAssertTrue(!accountModule.bytecode.isEmpty)
                
                debugPrint(accountModule.abi!.exposedFunctions.filter({$0.isEntry && $0.name == "batch_buy_script"}).map({ [ "name": "\(accountModule.abi!.address)::\(accountModule.abi!.name)::\($0.name)", "params": $0.paramTypes.map({AptosTypeTag.typeTag($0)})] }))

                reqeustExpectation.fulfill()
            } catch let e {
                debugPrint(e)
                reqeustExpectation.fulfill()
            }
        }
        wait(for: [reqeustExpectation], timeout: 30)
    }
    
    func testClientExamples() throws {
        let reqeustExpectation = expectation(description: "Tests")
        let client = AptosClient(url: nodeUrl)
        DispatchQueue.global().async {
            do {
                let healthy = try client.healthy().wait()
                XCTAssertEqual(healthy.message, "aptos-node:ok")
                
                let ledgerInfo = try client.getLedgerInfo().wait()
                XCTAssertTrue(ledgerInfo.chainId > 0)
                XCTAssertTrue((UInt64(ledgerInfo.blockHeight) ?? 0) > 0)
                
                let address = try AptosAddress("0x689b6d1d3e54ebb582bef82be2e6781cccda150a6681227b4b0e43ab754834e5")
                let accountData = try client.getAccount(address: address).wait()
                XCTAssertEqual(accountData.authenticationKey, address.address)
                
                let accountResources = try client.getAccountResources(address: address).wait()
                XCTAssertTrue(!accountResources.isEmpty)
                
                let resourceType = "0x1::coin::CoinStore<0x1::aptos_coin::AptosCoin>"
                let accountResource = try client.getAccountResource(address: address, resourceType: resourceType).wait()
                XCTAssertEqual(accountResource.type, resourceType)
                
                let coinStore = try accountResource.to(AptosClient.AccountResourceData.CoinStore.self)
                XCTAssertTrue(!coinStore.coin.value.isEmpty)
                
                let accountModules = try client.getAccountModules(address: try AptosAddress("0x1")).wait()
                XCTAssertTrue(!accountModules.isEmpty)
                
                let accountModule = try client.getAccountModule(address: try AptosAddress("0x1"), moduleName: "code").wait()
                XCTAssertTrue(!accountModule.bytecode.isEmpty)
                
                let block = try client.getBlock(0).wait()
                XCTAssertEqual(block.blockHeight, "0")
                
                let transaction = try client.getTransactionByHash("0x3993463e2d17aca60d1114652c9c4ca4fe59b571ea343c16dd97e7080b3ad635").wait()
                XCTAssertEqual(transaction["hash"], "0x3993463e2d17aca60d1114652c9c4ca4fe59b571ea343c16dd97e7080b3ad635")

                reqeustExpectation.fulfill()
            } catch let e {
                debugPrint(e)
                reqeustExpectation.fulfill()
            }
        }
        wait(for: [reqeustExpectation], timeout: 30)
    }
    
    func testSimulateTransactionExamples() throws {
        let reqeustExpectation = expectation(description: "Tests")
        let client = AptosClient(url: self.nodeUrl)
        DispatchQueue.global().async {
            do {
                let keyPair = try AptosKeyPairEd25519(privateKeyData: Data(hex: "0x105f0dd49fb8eb999efd01ee72def91c65d8a81ae4a4803c42a56df14ace864a"))
                
                let sequenceNumber = try client.getAccount(address: AptosAddress("0x689b6d1d3e54ebb582bef82be2e6781cccda150a6681227b4b0e43ab754834e5")).wait().sequenceNumber
                let chainId = try client.getLedgerInfo().wait().chainId
                let to = try AptosAddress("0xde1cbede2618446ed917826e79cc30d93c39eeeef635f76225f714dc2d7e26b6")
                let amount = UInt64(10)
                
                let function = try AptosEntryFunction.natural(module: "0x1::coin",
                                                               func: "transfer",
                                                               typeArgs: [
                                                                AptosTypeTag.Struct(AptosStructTag.fromString("0x1::aptos_coin::AptosCoin"))
                                                               ],
                                                               args: [
                                                                to.data,
                                                                try BorshEncoder().encode(amount)
                                                               ]
                )
                let payload = AptosTransactionPayloadEntryFunction(value: function)
                let date = UInt64(Date().timeIntervalSince1970 + 60)
                let transaction = AptosRawTransaction(sender: try AptosAddress("0x689b6d1d3e54ebb582bef82be2e6781cccda150a6681227b4b0e43ab754834e5"),
                                                      sequenceNumber: UInt64(sequenceNumber)!,
                                                      maxGasAmount: 1000,
                                                      gasUnitPrice: 1,
                                                      expirationTimestampSecs: date,
                                                      chainId: UInt8(chainId),
                                                      payload: AptosTransactionPayload.EntryFunction(payload))
                let result1 = try client.simulateTransaction(transaction, publicKey: keyPair.publicKey).wait()
                debugPrint(result1)
                reqeustExpectation.fulfill()
            } catch let error {
                print(error)
                reqeustExpectation.fulfill()
            }
        }
        wait(for: [reqeustExpectation], timeout: 30)
    }
    
    func testSendBCSTransactionExamples() throws {
        let reqeustExpectation = expectation(description: "Tests")
        let client = AptosClient(url: self.nodeUrl)
        DispatchQueue.global().async {
            do {
                // Address[0x689b6d1d3e54ebb582bef82be2e6781cccda150a6681227b4b0e43ab754834e5]
                let keyPair = try AptosKeyPairEd25519(privateKeyData: Data(hex: "0x105f0dd49fb8eb999efd01ee72def91c65d8a81ae4a4803c42a56df14ace864a"))
                
                let sequenceNumber = try client.getAccount(address: keyPair.address).wait().sequenceNumber
                let chainId = try client.getLedgerInfo().wait().chainId
                let to = try AptosAddress("0xde1cbede2618446ed917826e79cc30d93c39eeeef635f76225f714dc2d7e26b6")
                let amount = UInt64(10)
                
                let function = try AptosEntryFunction.natural(module: "0x1::coin",
                                                               func: "transfer",
                                                               typeArgs: [
                                                                AptosTypeTag.Struct(AptosStructTag.fromString("0x1::aptos_coin::AptosCoin"))
                                                               ],
                                                               args: [
                                                                to.data,
                                                                try BorshEncoder().encode(amount)
                                                               ]
                )
                let payload = AptosTransactionPayloadEntryFunction(value: function)
                let date = UInt64(Date().timeIntervalSince1970 + 60)
                let transaction = AptosRawTransaction(sender: keyPair.address,
                                                      sequenceNumber: UInt64(sequenceNumber)!,
                                                      maxGasAmount: 1000,
                                                      gasUnitPrice: 1,
                                                      expirationTimestampSecs: date,
                                                      chainId: UInt8(chainId),
                                                      payload: AptosTransactionPayload.EntryFunction(payload))
                let signedtransaction = try transaction.sign(keyPair)
                let result = try client.submitSignedTransaction(signedtransaction).wait()
                print(result)
                
                reqeustExpectation.fulfill()
            } catch let error {
                print(error)
                reqeustExpectation.fulfill()
            }
        }
        wait(for: [reqeustExpectation], timeout: 30)
    }
}
