import PathKit
import Sorbetto
import XCTest
@testable import SorbettoSass

class SorbettoSassTests: XCTestCase {
    @discardableResult
    func buildTest(path: String) throws -> Site {
        let destination = try Path.uniqueTemporary()

        //
        // Why three ".."?
        //        <-(1) <-(2)         <-(3)
        // Sorbetto/Tests/SorbettoTests/X.swift
        //
        let fileToRoot = "../../.."

        let repoRoot = (Path(#file) + fileToRoot).normalize()
        let directoryPath = repoRoot + path
        XCTAssertTrue(directoryPath.isDirectory)

        return try Sorbetto(directory: directoryPath, destination: destination)
            .using(Sass())
            .build()
    }

    func testFixtures1() throws {
        let site = try buildTest(path: "./Fixtures/Sites/01/")

        XCTAssertNil(site["static/app.scss"], "Should have moved static/app.scss to static/app.css")

        guard let app = site["static/app.css"] else {
            XCTFail("static/app.css should exist")
            return
        }

        XCTAssertEqual(app.contents, "foo {\n  margin: 42px; }\n".data(using: .utf8))
    }

    static var allTests: [(String, (SorbettoSassTests) -> () throws -> Void)] {
        return [
            ("testFixtures1", testFixtures1),
        ]
    }
}
