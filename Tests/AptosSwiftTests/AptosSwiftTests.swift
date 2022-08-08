import XCTest
@testable import AptosSwift

final class AptosSwiftTests: XCTestCase {
    
    func testKeyPair() throws {
        let keypair1 = try AptosKeyPairEd25519(mnemonics: "talk speak heavy can high immune romance language alarm sorry capable flame")
        XCTAssertEqual(keypair1.privateKey, "0x2e0c19e199f9ba403e35817f078114bdcb6ea6341e749f02e4fea83ca055baa7")
        XCTAssertEqual(keypair1.publicKey, "0x8d9f75b3a99e9d401a8e1c911fbc51e0d77920f8975f7df57ec34f9a6e454c43")
        XCTAssertEqual(keypair1.address.address, "0x43cf7854347a34ec167a1980c324221005936d322683aa592bef6de7e46bc575")
        
        let keypair2 = try AptosKeyPairEd25519(privateKeyData: Data(hex: "2e0c19e199f9ba403e35817f078114bdcb6ea6341e749f02e4fea83ca055baa7"))
        XCTAssertEqual(keypair2.address.address, "0x43cf7854347a34ec167a1980c324221005936d322683aa592bef6de7e46bc575")
        
        let keypair3 = try AptosKeyPairEd25519(privateKeyData: Data(hex: "0x105f0dd49fb8eb999efd01ee72def91c65d8a81ae4a4803c42a56df14ace864a".stripHexPrefix()))
        XCTAssertEqual(keypair3.address.address, "0x689b6d1d3e54ebb582bef82be2e6781cccda150a6681227b4b0e43ab754834e5")
    }
    
    func testDecoderAndEncoderExamples() throws {
        XCTAssertEqual(try BorshDecoder().decode(UVarInt.self, from: Data(hex: "cdeaec31")).value.description, "104543565")
        XCTAssertEqual(try BorshEncoder().encode(UVarInt(4294967295)).toHexString(), "ffffffff0f")
        
        XCTAssertEqual(try BorshDecoder().decode(VarData.self, from: Data(hex: "03020304")).data, Data(hex: "020304"))
        XCTAssertEqual(try BorshEncoder().encode(VarData(Data(hex: "020304"))).toHexString(), "03020304")
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
                let chaininfo = try provider.getChainInfo().wait()
                print(chaininfo.ledgerVersion)
                reqeustExpectation.fulfill()
            } catch {
                reqeustExpectation.fulfill()
            }
        }
        wait(for: [reqeustExpectation], timeout: 30)
    }
}
