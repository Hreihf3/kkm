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
        print(AptosPublicKeyEd25519(keypair3.publicKeyData).data.description)
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
        
        let args: [Data] = [
            try BorshEncoder().encode(AptosAddress("0xdd")),
            try BorshEncoder().encode(UInt64(1))
        ]
        let payload = try AptosTransactionPayloadScriptFunction(value: .natural(module: "0x1222::aptos_coin",
                                                                                          func: "transfer",
                                                                                          typeArgs: [],
                                                                                          args: args))
        
        let rawTx = try AptosRawTransaction(sender: AptosAddress("0x0a550c18"),
                                            sequenceNumber: 0,
                                            maxGasAmount: 2000,
                                            gasUnitPrice: 0,
                                            expirationTimestampSecs: 18446744073709551615,
                                            chainId: 4,
                                            payload: .ScriptFunction(payload))
        let signedTx = try rawTx.sign(keyPair)
        XCTAssertEqual(try BorshEncoder().encode(signedTx), Data(hex: "000000000000000000000000000000000000000000000000000000000a550c1800000000000000000300000000000000000000000000000000000000000000000000000000000012220a6170746f735f636f696e087472616e7366657200022000000000000000000000000000000000000000000000000000000000000000dd080100000000000000d0070000000000000000000000000000ffffffffffffffff040020b9c6ee1630ef3e711144a648db06bbb2284f7274cfbee53ffcee503cc1a492004061bb6440bfbdfac3fff8559704303bd72544794b432ab7f9d0f3f779b6cb01aad5c86b6574f04a00698d01f4102015de056a480addd57aab600c3d4d2cba580c"))
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
                let account = try provider.getAccountResource(address: try AptosAddress("0x689b6d1d3e54ebb582bef82be2e6781cccda150a6681227b4b0e43ab754834e5"), resourceType: "0x1::coin::CoinStore<0x1::aptos_coin::AptosCoin>").wait()
                print(account.type)
                reqeustExpectation.fulfill()
            } catch {
                reqeustExpectation.fulfill()
            }
        }
        wait(for: [reqeustExpectation], timeout: 30)
    }
    
    func testTransactionExamples() throws {
        var amountdata = Data()
        try UInt64(1000).serialize(to: &amountdata)
        let function = try AptosScriptFunction.natural(module: "0x1::coin", func: "transfer", typeArgs: [AptosTypeTag.Struct(AptosStructTag.fromString("0x1::aptos_coin::AptosCoin"))], args: [AptosAddress("0xde1cbede2618446ed917826e79cc30d93c39eeeef635f76225f714dc2d7e26b6").data,amountdata])
        
        let payloadscriptfunction = AptosTransactionPayloadScriptFunction(value: function)
        let transaction = AptosTransaction(sender: try AptosAddress("0x689b6d1d3e54ebb582bef82be2e6781cccda150a6681227b4b0e43ab754834e5"), sequenceNumber: 0, maxGasAmount: 1000, gasUnitPrice: 1, expirationTimestampSecs: 1659665022, chainId: 22, payload: AptosTransactionPayload.ScriptFunction(payloadscriptfunction))
        print(transaction.signMessage().toHexString())
        XCTAssertEqual(transaction.signMessage().toHexString(), "b5e97db07fa0bd0e5598aa3643a9bc6f6693bddc1a9fec9e674a461eaa00b193689b6d1d3e54ebb582bef82be2e6781cccda150a6681227b4b0e43ab754834e5000000000000000003000000000000000000000000000000000000000000000000000000000000000104636f696e087472616e73666572010700000000000000000000000000000000000000000000000000000000000000010a6170746f735f636f696e094170746f73436f696e000220de1cbede2618446ed917826e79cc30d93c39eeeef635f76225f714dc2d7e26b608e803000000000000e80300000000000001000000000000007e7aec620000000016")
    }
}
