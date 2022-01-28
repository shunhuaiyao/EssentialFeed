//
//  FeedItem.swift
//  EssentialFeed
//
//  Created by Sean Yao on 2022/1/27.
//

import Foundation
import UIKit

public struct FeedItem: Equatable {
    public let id: UUID
    public let description: String?
    public let location: String?
    public let imageURL: URL
    
    public init(id: UUID, description: String?, location: String?, imageURL: URL) {
        self.id = id
        self.description = description
        self.location = location
        self.imageURL = imageURL
    }
}
