//
//  DownloadData.swift
//  Kontest Admin
//
//  Created by Ayush Singhal on 14/05/24.
//

import Apollo
import Combine
import Foundation

class DownloadDataWithApollo {
    static let shared = DownloadDataWithApollo()

    private(set) var apollo = ApolloClient(url: URL(string: "https://leetcode.com/graphql?query=")!)

    private init() {}
}

func downloadDataWithAsyncAwait(url: URL) async throws -> Data {
    let (data, response) = try await URLSession.shared.data(from: url)

    guard let httpResponse = response as? HTTPURLResponse,
          (200 ..< 300).contains(httpResponse.statusCode)
    else {
        throw URLError(.badServerResponse)
    }

    return data
}
