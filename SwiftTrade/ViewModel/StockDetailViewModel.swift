//
//  StockDetailViewModel.swift
//  SwiftTrade
//
//  Created by Abhishek Kumar on 4/28/24.
//

import Foundation

class StockDetailViewModel: ObservableObject {
    @Published var stockOverview: StockOverviewModel = StockOverviewModel(name: "Apple Inc", ticker: "AAPL", ipo: "1980-12-12", finnhubIndustry: "Technology", weburl: "https://www.apple.com/")
    @Published var stat: StatModel = StatModel(c: 0.0, d: 0.0, dp: 0.0, h: 0.1, l: 0.0, o: 0.0, pc: 0.0, t: 0)
    @Published var stockPeers: [String] = []
    @Published var companyNews: [StockNewsModel] = []
    
    @Published var isLoading: Bool = false
    
    init() {}
    
    func loadData() async {
        do {
            DispatchQueue.main.async {
                self.isLoading = true
            }
            try await getStockOverview()
            try await getStat()
            try await getCompanyPeers()
            try await getCompanyNews()
            DispatchQueue.main.async {
                self.isLoading = false
            }            
        } catch StockError.invalidURL {
            print("invalid URL")
        } catch StockError.invalidResponse {
            print("invalid Response")
        } catch StockError.invalidData {
            print("invalid Data")
        } catch {
            print("An unexpected error occured: \(error)")
        }
    }
    
    // GET Stock Overview
    func getStockOverview() async throws {
        let endpoint = "https://finnhub.io/api/v1/stock/profile2?symbol=AAPL&token=cn2vjohr01qt9t7visi0cn2vjohr01qt9t7visig"
        
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
            let decodedData = try decoder.decode(StockOverviewModel.self, from: data)
            DispatchQueue.main.async {
                self.stockOverview = decodedData
//                print("Is Main Thread: \(Thread.isMainThread)")
            }
        } catch {
            throw StockError.invalidData
        }
    }
    
    // GET Stock Summary
    func getStat() async throws {
        let endpoint = "https://finnhub.io/api/v1/quote?symbol=AAPL&token=cn2vjohr01qt9t7visi0cn2vjohr01qt9t7visig"
        
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
            let decodedData = try decoder.decode(StatModel.self, from: data)
            
//            print("Decoded StatModel:\n\(decodedData)")
            
            DispatchQueue.main.async {
                self.stat = decodedData
//                print("Is Main Thread: \(Thread.isMainThread)")
            }
        } catch {
            throw StockError.invalidData
        }
    }
    
    func getCompanyPeers() async throws {
        let endpoint = "https://finnhub.io/api/v1/stock/peers?symbol=ANET&token=cn2vjohr01qt9t7visi0cn2vjohr01qt9t7visig"
        
        guard let url = URL(string: endpoint) else {
            throw StockError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url) // GET request
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw StockError.invalidResponse
        }
        
        do {
            let decoder = JSONDecoder()
            let decodedData = try decoder.decode([String].self, from: data)
//            print("Decoded StatModel:\n\(decodedData)")
            DispatchQueue.main.async {
                self.stockPeers = decodedData
            }
        }
    }
    
    func getCompanyNews() async throws {
        let endpoint = "https://finnhub.io/api/v1/company-news?symbol=AAPL&from=2022-01-15&to=2024-02-09&token=cn2vjohr01qt9t7visi0cn2vjohr01qt9t7visig"
        
        guard let url = URL(string: endpoint) else {
            throw StockError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url) // GET
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw StockError.invalidResponse
        }
        
        do {            
            let decoder = JSONDecoder()
            let decodedData = try decoder.decode([StockNewsModel].self, from: data)
            let validNewsItems = decodedData.filter { !$0.image.isEmpty }
            let limitedNewsItems = Array(validNewsItems.prefix(20))
            print("Decoded StatModel:\n\(limitedNewsItems)")
            DispatchQueue.main.async {
                self.companyNews = limitedNewsItems
            }
        }
    }
}
