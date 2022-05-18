//
//  SharedTestHelpers.swift
//  EssentialFeedTests
//
//  Created by Sean Yao on 2022/5/18.
//

import Foundation

func anyURL() -> URL {
    URL(string: "https://any-url.com")!
}

func anyNSError() -> NSError {
    NSError(domain: "any error", code: 0, userInfo: nil)
}
