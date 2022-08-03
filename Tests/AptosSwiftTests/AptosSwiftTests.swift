import XCTest
@testable import AptosSwift

final class AptosSwiftTests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
    }
    
    func testKeyPair() throws {
        let privateKeypair = try! AptosKeyPair(privateKey: Data(hex: "0x105f0dd49fb8eb999efd01ee72def91c65d8a81ae4a4803c42a56df14ace864a"))
        let mnemonicsKeypair = try! AptosKeyPair(mnemonics: "rabbit wave faint history little wave capable swamp fringe cousin filter boat")
        print("privateKeypair private:",privateKeypair.privateKey.toHexString())
        print("privateKeypair publickey:",privateKeypair.publicKey.toHexString())
        print("mnemonicsKeypair private:",mnemonicsKeypair.privateKey.toHexString())
        print("mnemonicsKeypair publickey:",mnemonicsKeypair.publicKey.toHexString())
    }
    
    func testprovider() throws {
        let reqeustExpectation = expectation(description: "Tests")
        let provider = AptosRPCProvider(nodeUrl: "https://fullnode.devnet.aptoslabs.com")
        DispatchQueue.global().async {
            do {
                let account = try provider.getAccount(address: "0x689b6d1d3e54ebb582bef82be2e6781cccda150a6681227b4b0e43ab754834e5").wait()
                print(account.authenticationKey)
                print(account.sequenceNumber)
                reqeustExpectation.fulfill()
            } catch {
                reqeustExpectation.fulfill()
            }
        }
        wait(for: [reqeustExpectation], timeout: 30)
    }
}
