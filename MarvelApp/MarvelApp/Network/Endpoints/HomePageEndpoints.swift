//
//  HomePageEndpoints.swift
//  MarvelApp
//
//  Created by Caner Tüysüz on 5.12.2024.
//

import Foundation

enum HomepageEndpoints: EndpointProtocol {
    case getCharacters

    var url: String {
        switch self {
        case .getCharacters:
            return "https://gateway.marvel.com:443/v1/public/characters"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .getCharacters:
            return .GET
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .getCharacters:
            return ["Content-Type": "application/json"]
        }
    }
    
    var limit: Int {
        switch self {
        case .getCharacters:
            return 20
        }
    }
    
    var queryItems: [URLQueryItem]? {
        switch self {
        case .getCharacters:
            return [
                URLQueryItem(name: "limit", value: "\(self.limit)"),
                URLQueryItem(name: "ts", value: NetworkManagerHelpers.generateTS()),
                URLQueryItem(name: "apikey", value: NetworkManagerHelpers.generatePublicKey()),
                URLQueryItem(name: "hash", value: NetworkManagerHelpers.generateHash()),
            ]
        }
    }
}
