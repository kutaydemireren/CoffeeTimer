//
//  NetworkManagerImp.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 01/06/2024.
//

import Foundation

extension URLSession {
    /// `URLSession` making sure always the latest content is fetched remotely.
    static let noCache: URLSession = {
        var configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        configuration.urlCache = nil
        return URLSession(configuration: configuration)
    }()
}

private enum HTTPStatusCode: Int {
    case success

    init?(rawValue: Int) {
        switch rawValue {
        case 200..<300:
            self = .success
        default:
            return nil
        }
    }
}

struct NetworkManagerImp: NetworkManager {
    private let urlSession: URLSession

    init(urlSession: URLSession = URLSession.shared) {
        // use URLSession.shared by default.
        // enable `noCache` for disabling cache for debugging purposes.
        self.urlSession = urlSession
    }

    func perform(request: Request) async throws -> Data {
        let (data, response) = try await urlSession.data(for: request.createURLRequest())

        guard let httpResponse = response as? HTTPURLResponse,
              case .success = HTTPStatusCode(rawValue: httpResponse.statusCode) else {
            throw NetworkError.unexpectedServerResponse
        }

        return data
    }
}
