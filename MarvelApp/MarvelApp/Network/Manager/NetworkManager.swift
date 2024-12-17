//
//  NetworkManager.swift
//  MarvelApp
//
//  Created by Caner Tüysüz on 5.12.2024.
//

import CryptoKit
import Foundation

enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
}

protocol EndpointProtocol {
    var url: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String]? { get }
    var queryItems: [URLQueryItem]? { get }
}

extension EndpointProtocol {
    var headers: [String: String]? { return nil }
    var queryItems: [URLQueryItem]? { return nil }
}

enum NetworkError: Error {
    case invalidURL
    case decodingError
    case networkError(String)
    case serverError(String)

    var title: String {
        return "Error (\(errorCode))"
    }

    var description: String {
        return "An error occured"
    }

    var errorCode: Int {
        switch self {
        case .networkError:
            return 100
        case .invalidURL:
            return 200
        case .decodingError:
            return 300
        case .serverError:
            return 400
        }
    }
}

enum NetworkResult<T> {
    case success(T)
    case failure(NetworkError)
}

final class NetworkManager {

    static let shared = NetworkManager()

    func makeRequest<T: Decodable>(
        endpoint: EndpointProtocol, responseType: T.Type,
        completion: (@escaping (NetworkResult<T>) -> Void)
    ) {

        guard var components = URLComponents(string: endpoint.url) else {
            completion(.failure(.invalidURL))
            return
        }

        components.queryItems = endpoint.queryItems

        guard let url = components.url else {
            completion(.failure(.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue

        if let headers = endpoint.headers {
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error {
                print("Network error occurred: \(error.localizedDescription)")
                
                completion(.failure(.networkError(error.localizedDescription)))
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                guard (200...299).contains(httpResponse.statusCode) else {
                    print("Server responded with status code: \(httpResponse.statusCode)")
                    
                    completion(.failure(.serverError("Server returned status code \(httpResponse.statusCode)")))
                    return
                }
            } else {
                print("Unexpected response format")
                
                completion(.failure(.serverError("Invalid response from server")))
                return
            }

            do {
                guard let data else { return }

                let decodedResponse = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decodedResponse))
            } catch {
                print("Decoding error: \(error.localizedDescription)")
                completion(.failure(.decodingError))
            }

        }.resume()

    }

}

final class NetworkManagerHelpers {
    static func generateTS() -> String {
        return "1"
    }
    
    static func generatePublicKey() -> String? {
        return ProcessInfo.processInfo.environment["PUBLIC_KEY"]
    }

    static func generatePrivateKey() -> String? {
        return ProcessInfo.processInfo.environment["PRIVATE_KEY"]
    }

    static func generateHash() -> String? {
        let ts = self.generateTS()
        
        guard let publicKey = self.generatePublicKey() else {
            print("Public key is missing")
            return nil
        }
        
        guard let privateKey = self.generatePrivateKey() else {
            print("Private key is missing")
            return nil
        }

        let hashInput = "\(ts)\(privateKey)\(publicKey)"
        
        guard let data = hashInput.data(using: .utf8) else {
            print("Failed to encode hash input as UTF-8")
            return nil
        }
        
        let hash = Insecure.MD5.hash(data: data)
        let hashString = hash.map { String(format: "%02hhx", $0) }.joined()
        
        return hashString
    }
}
