//
//  XCTestCase+MemoryLeakTracking.swift
//  EssentialFeedTests
//
//  Created by Jeet Kapadia on 21/09/24.
//

import Foundation
import XCTest

extension XCTestCase {
    func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
        if #available(macOS 10.15, *) {
            addTeardownBlock { [weak instance] in
                XCTAssertNil(instance, "Instance should have been nil. Potential Memory leak", file: file, line: line)
            }
        } else {
            // Fallback on earlier versions
        }
    }
}
