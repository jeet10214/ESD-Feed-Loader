//
//  FeedCachePolicy.swift
//  EssentialFeed
//
//  Created by Jeet Kapadia on 02/04/25.
//

import Foundation

internal final class FeedCachePolicy {
    private init() {}
    
    private static let calendar = Calendar(identifier: .gregorian)
    
    private static var maxCacheNumberInDays: Int {
        return 7
    }
    
    internal static func validate(_ timestamp: Date, against date: Date) -> Bool {
        guard let maxCacheAge = calendar.date(byAdding: .day, value: maxCacheNumberInDays, to: timestamp) else {
            return false
        }
        return date < maxCacheAge
    }
}
