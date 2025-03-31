//
//  SharedTestHelpers.swift
//  EssentialFeed
//
//  Created by Jeet Kapadia on 31/03/25.
//

import Foundation

func anyNSError() -> NSError {
    NSError(domain: "any error", code: 0)
}

func anyURL() -> URL {
    return URL(string: "https://any-url.com")!
}
