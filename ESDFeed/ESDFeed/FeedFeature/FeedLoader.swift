//
//  FeedLoader.swift
//  ESDFeed
//
//  Created by Jeet Kapadia on 17/08/24.
//

import Foundation

enum LoadFeedResult {
    case success([FeedItem])
    case error(Error)
}

protocol FeedLoader {
    func load(completion: @escaping(LoadFeedResult) -> Void)
}
