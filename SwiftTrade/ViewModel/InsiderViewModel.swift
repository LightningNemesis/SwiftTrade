//
//  InsiderViewModel.swift
//  SwiftTrade
//
//  Created by Abhishek Kumar on 5/2/24.
//

import Foundation

struct InsiderResponse: Codable {
    let data: [InsiderModel]
}

struct InsiderModel: Codable {
    let change: Int
    let mspr: Float
}

class InsiderViewModel: ObservableObject {
    @Published var insiderModel: [InsiderModel]
    @Published var isLoading: Bool
    
    init() {
        self.insiderModel = []
        self.isLoading = false
    }
    
    func getSentiment(stock: String) async throws {
        let endpoint = "https://finnhub.io/api/v1/stock/insider-sentiment?symbol=\(stock)&from=2022-01-01&token=cn2vjohr01qt9t7visi0cn2vjohr01qt9t7visig"
        
        guard let url = URL(string: endpoint) else {
            throw StockError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url) // making the GET request
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw StockError.invalidResponse
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let decodedData = try decoder.decode(InsiderResponse.self, from: data)
//            print("Insider Data: \(decodedData)")
            DispatchQueue.main.async {
                self.insiderModel = decodedData.data
            }
        } catch {
            throw StockError.invalidData
        }
    }
    
    
}
