//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by Sean Yao on 2022/1/31.
//

import Foundation

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}
