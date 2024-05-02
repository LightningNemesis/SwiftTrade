//
//  APIService.swift
//  SwiftTrade
//
//  Created by Abhishek Kumar on 5/1/24.
//

struct AutocompleteResponse: Codable {
    let result: [AutocompleteModel]
}

struct AutocompleteModel: Codable {    
    let displaySymbol: String
    let symbol: String
    let description: String
}

import Foundation

class FinnhubAPIService {
    static let shared = FinnhubAPIService(
        baseURL: "https://finnhub.io/api/v1",
        token: "cn2vjohr01qt9t7visi0cn2vjohr01qt9t7visig"
    )
    
    private let baseURL: String
    private let token: String
    
    init(baseURL: String, token: String) {
        self.baseURL = baseURL
        self.token = token
    }
    
    func fetchData<T: Decodable>(from endpoint: String, decodingType: T.Type) async throws -> T {
        // Construct the URL with the token as a query parameter
        var urlString = ""
        if token == "" {
            urlString = "\(baseURL)\(endpoint)"
        } else {
          urlString = "\(baseURL)\(endpoint)&token=\(token)"
        }
        
        guard let url = URL(string: urlString) else {
            throw StockError.invalidURL
        }
        
        print("URL with Query Param: \(urlString)")
        
        // Prepare the URLRequest object
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // Perform the request
        let (data, response) = try await URLSession.shared.data(for: request) // making the API call
        
    
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw StockError.invalidResponse
        }
        
        if let jsonString = String(data: data, encoding: .utf8) {
                print("Raw JSON data: \(jsonString)")
            }
        
        // Decode the data
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(T.self, from: data)
        } catch {
            print("Decoding failed with error: \(error)")
                print("Error localized description: \(error.localizedDescription)")
                // Optionally, print out the error as JSON
            if let decodingError = error as? DecodingError {
                switch decodingError {
                case .typeMismatch(let type, let context):
                    print("Type '\(type)' mismatch:", context.debugDescription)
                    print("codingPath:", context.codingPath.map { $0.stringValue }.joined(separator: " → "))
                case .valueNotFound(let type, let context):
                    print("Value '\(type)' not found:", context.debugDescription)
                    print("codingPath:", context.codingPath.map { $0.stringValue }.joined(separator: " → "))
                case .keyNotFound(let key, let context):
                    print("Key '\(key)' not found:", context.debugDescription)
                    print("codingPath:", context.codingPath.map { $0.stringValue }.joined(separator: " → "))
                case .dataCorrupted(let context):
                    print("Data corrupted:", context.debugDescription)
                    print("codingPath:", context.codingPath.map { $0.stringValue }.joined(separator: " → "))
                @unknown default:
                    print("Unknown decoding error")
                }
            }
            throw StockError.invalidData
        }
    }
}
