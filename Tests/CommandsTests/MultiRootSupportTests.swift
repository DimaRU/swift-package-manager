/*
 This source file is part of the Swift.org open source project

 Copyright (c) 2014 - 2019 Apple Inc. and the Swift project authors
 Licensed under Apache License v2.0 with Runtime Library Exception

 See http://swift.org/LICENSE.txt for license information
 See http://swift.org/CONTRIBUTORS.txt for Swift project authors
*/

import Basics
import Commands
import SPMTestSupport
import TSCBasic
import Workspace
import XCTest

final class MultiRootSupportTests: XCTestCase {

    func testWorkspaceLoader() throws {
        let fs = InMemoryFileSystem(emptyFiles: [
            "/tmp/test/dep/Package.swift",
            "/tmp/test/local/Package.swift",
        ])
        let path = AbsolutePath("/tmp/test/Workspace.xcworkspace")
        try fs.writeFileContents(path.appending(component: "contents.xcworkspacedata")) {
            $0 <<< """
                <?xml version="1.0" encoding="UTF-8"?>
                <Workspace
                version = "1.0">
                <FileRef
                    location = "absolute:/tmp/test/dep">
                </FileRef>
                <FileRef
                    location = "group:local">
                </FileRef>
                </Workspace>
                """
        }

        let observability = ObservabilitySystem.makeForTesting()
        let result = try XcodeWorkspaceLoader(diagnostics: observability.topScope.makeDiagnosticsEngine(), fs: fs).load(workspace: path)

        XCTAssertNoDiagnostics(observability.diagnostics)
        XCTAssertEqual(result.map{ $0.pathString }.sorted(), ["/tmp/test/dep", "/tmp/test/local"])
    }
}
