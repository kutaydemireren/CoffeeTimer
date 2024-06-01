//
//  Request.swift
//  CoffeeTimer
//
//  Created by Kutay Demireren on 01/06/2024.
//

import Foundation

enum RequestType: String {
    case get = "GET"
}

protocol Request {
    var host: String { get }
    var path: String { get }
    var requestType: RequestType { get }
}

extension Request {
    var requestType: RequestType {
        return .get
    }

    func createURLRequest() throws -> URLRequest {
        var components = URLComponents()
        components.scheme = "https"
        components.host = host
        components.path = path

        guard let url = components.url else { throw NetworkError.unexpectedURL }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = requestType.rawValue
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        return urlRequest
    }
}
