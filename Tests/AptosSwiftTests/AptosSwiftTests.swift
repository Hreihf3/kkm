import XCTest
@testable import AptosSwift

final class AptosSwiftTests: XCTestCase {
    
    func testKeyPair() throws {
        let keypair1 = try AptosKeyPairEd25519(mnemonics: "talk speak heavy can high immune romance language alarm sorry capable flame")
        XCTAssertEqual(keypair1.privateKeyHex, "0x2e0c19e199f9ba403e35817f078114bdcb6ea6341e749f02e4fea83ca055baa7")
        XCTAssertEqual(keypair1.publicKey.hex, "0x8d9f75b3a99e9d401a8e1c911fbc51e0d77920f8975f7df57ec34f9a6e454c43")
        XCTAssertEqual(keypair1.address.address, "0x43cf7854347a34ec167a1980c324221005936d322683aa592bef6de7e46bc575")
        
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
        
        debugPrint(try BorshDecoder().decode(Bool.self, from: Data(hex: "00")))
        debugPrint(try BorshEncoder().encode(true).toHexString())
    }
    
    func testSignTransactionExamples() throws {
        let keyPair = try AptosKeyPairEd25519(seed: Data(hex: "9bf49a6a0755f953811fce125f2683d50429c3bb49e074147e0089a52eae155f"))
        
        let token = try AptosTypeTag.Struct(AptosStructTag.fromString("0x01::aptos_coin::AptosCoin"))
        let args: [Data] = [
            try BorshEncoder().encode(AptosAddress("0xdd")),
            try BorshEncoder().encode(UInt64(1))
        ]
        let payload = try AptosTransactionPayloadScriptFunction(value: .natural(module: "0x1222::coin",
                                                                                func: "transfer",
                                                                                typeArgs: [token],
                                                                                args: args))
        
        let rawTx = try AptosRawTransaction(sender: AptosAddress("0x0a550c18"),
                                            sequenceNumber: 0,
                                            maxGasAmount: 2000,
                                            gasUnitPrice: 0,
                                            expirationTimestampSecs: 18446744073709551615,
                                            chainId: 4,
                                            payload: .ScriptFunction(payload))
        let signedTx = try rawTx.sign(keyPair)
        XCTAssertEqual(try BorshEncoder().encode(signedTx), Data(hex: "000000000000000000000000000000000000000000000000000000000a550c18000000000000000003000000000000000000000000000000000000000000000000000000000000122204636f696e087472616e73666572010700000000000000000000000000000000000000000000000000000000000000010a6170746f735f636f696e094170746f73436f696e00022000000000000000000000000000000000000000000000000000000000000000dd080100000000000000d0070000000000000000000000000000ffffffffffffffff040020b9c6ee1630ef3e711144a648db06bbb2284f7274cfbee53ffcee503cc1a4920040d7b32e9efbc640963782b11833159a3d62ba962c3f1e5580a9bab89ab012d99c38ed54ab8c0383a438a9a562b3b4b519bd31265130f2955f744125929ff23307"))
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
        
        let jsondata = try JSONSerialization.data(withJSONObject: signedTx.toHuman())
        print(String(data: jsondata, encoding:.utf8)!)
        
        XCTAssertEqual(try BorshEncoder().encode(signedTx), Data(hex: "000000000000000000000000000000000000000000000000000000000a550c1800000000000000000126a11ceb0b030000000105000100000000050601000000000000000600000000000000001a0102010700000000000000000000000000000000000000000000000000000000000000010a6170746f735f636f696e094170746f73436f696e00010002d0070000000000000000000000000000ffffffffffffffff040020b9c6ee1630ef3e711144a648db06bbb2284f7274cfbee53ffcee503cc1a4920040662b626455b62ca41ef35b34c74ef0b848c5b3679ae3cf32af47d10ef3372ed4060cfaaeee6ab71ab0034951c21e589d70512c8c536625f532ebf9f127867209"))
    }
    
    func testProviderExamples() throws {
        let reqeustExpectation = expectation(description: "Tests")
        let provider = AptosRPCProvider(nodeUrl: "https://fullnode.devnet.aptoslabs.com")
        DispatchQueue.global().async {
            do {
                //                let keypair = try AptosKeyPair.randomKeyPair()
                //                let hashs = try provider.fundAccount(address: keypair.address.address).wait()
                //                print(hashs.first)
                //                let account = try provider.getAccountResources(address: "0x689b6d1d3e54ebb582bef82be2e6781cccda150a6681227b4b0e43ab754834e5").wait()
//                let account = try provider.getAccountResource(address: try AptosAddress("0x689b6d1d3e54ebb582bef82be2e6781cccda150a6681227b4b0e43ab754834e5"), resourceType: "0x1::coin::CoinStore<0x1::aptos_coin::AptosCoin>").wait()
                let account = try provider.getAccount(address: AptosAddress("0x689b6d1d3e54ebb582bef82be2e6781cccda150a6681227b4b0e43ab754834e5")).wait()
                print(account.sequenceNumber)
                reqeustExpectation.fulfill()
            } catch {
                reqeustExpectation.fulfill()
            }
        }
        wait(for: [reqeustExpectation], timeout: 30)
    }
    
    func testTransactionExamples() throws {
        let reqeustExpectation = expectation(description: "Tests")
        let provider = AptosRPCProvider(nodeUrl: "https://fullnode.devnet.aptoslabs.com")
        DispatchQueue.global().async {
            do {
                let keyPair = try AptosKeyPairEd25519(privateKeyData: Data(hex: "0x105f0dd49fb8eb999efd01ee72def91c65d8a81ae4a4803c42a56df14ace864a"))
                var amountdata = Data()
                try UInt64(1000).serialize(to: &amountdata)
                let function = try AptosScriptFunction.natural(module: "0x1::coin", func: "transfer", typeArgs: [AptosTypeTag.Struct(AptosStructTag.fromString("0x1::aptos_coin::AptosCoin"))], args: [AptosAddress("0xde1cbede2618446ed917826e79cc30d93c39eeeef635f76225f714dc2d7e26b6").data,amountdata])
                let payloadscriptfunction = AptosTransactionPayloadScriptFunction(value: function)
                let data = UInt64(Date().timeIntervalSince1970)+10
                let transaction = AptosRawTransaction(sender: try AptosAddress("0x689b6d1d3e54ebb582bef82be2e6781cccda150a6681227b4b0e43ab754834e5"), sequenceNumber: 2, maxGasAmount: 1000, gasUnitPrice: 1, expirationTimestampSecs: data, chainId: 22, payload: AptosTransactionPayload.ScriptFunction(payloadscriptfunction))
                let signedtransaction = try transaction.sign(keyPair)
                let datas = try JSONSerialization.data(withJSONObject: signedtransaction.toHuman())
                print(String(data: datas, encoding: .utf8))
                let result = try provider.submitTransaction(signedTransaction: signedtransaction).wait()
                print(result.hash)
                print("end")
            } catch let error {
                print(error)
                reqeustExpectation.fulfill()
            }
        }
        wait(for: [reqeustExpectation], timeout: 30)
    }
}
