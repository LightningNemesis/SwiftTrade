//
//  PortfolioViewModel.swift
//  SwiftTrade
//
//  Created by Abhishek Kumar on 5/2/24.
//

import Foundation

//struct PortfolioItem: Codable, Identifiable {
//    var id: String
//    var quantity: Int
//    var avgCost: Double
//    var totalCost: Double
//    var ticker: String
//}

class PortfolioViewModel: ObservableObject {
    @Published var portfolioModel: [PortfolioResponse]
    @Published var isLoading: Bool
    
    init() {
        self.portfolioModel = []
        self.isLoading = false
    }
    
    func getPortfolio() async {
        do {
            let myAPIService: FinnhubAPIService = FinnhubAPIService(
                baseURL: "https://nemesis-node-server.wl.r.appspot.com/api",
                token: ""
            )
            
            let response: [PortfolioResponse] = try await myAPIService.fetchData(from: "/portfolio", decodingType: [PortfolioResponse].self)
            
            DispatchQueue.main.async {
                self.isLoading = true
                self.portfolioModel = response
                self.isLoading = false
            }
            
        }catch {
            print("Failed to fetch portfolio data: \(error)")
        }
    }
    
    func updateOrCreatePortfolio(item: PortfolioItem) async {
        let myAPIService: FinnhubAPIService = FinnhubAPIService(
            baseURL: "https://nemesis-node-server.wl.r.appspot.com/api",
            token: ""
        )
        
        do {
            let updatedItem: PortfolioResponse
            if portfolioModel.contains(where: { $0.ticker == item.ticker }) {
                let foundItem = portfolioModel.first(where: { $0.ticker == item.ticker })
                
                // Update the existing item
                if let id = foundItem?._id {
                    let endpoint = "/portfolio/\(id)"
                    
                    updatedItem = try await myAPIService.putData(endpoint: endpoint, requestBody: item, responseType: PortfolioResponse.self)
                    
                    if let index = portfolioModel.firstIndex(where: { $0.ticker == item.ticker }) {
                        DispatchQueue.main.async {
                            self.portfolioModel[index] = updatedItem
                        }
                    }
                }
                
                
            } else {
                // Create a new item
                let endpoint = "/portfolio"
                // Serialize item to JSON for logging
                let jsonData = try JSONEncoder().encode(item)
                if let jsonString = String(data: jsonData, encoding: .utf8) {
                    print("Creating new item: \(jsonString)")
                }
                updatedItem = try await myAPIService.postData(endpoint: endpoint, requestBody: item, responseType: PortfolioResponse.self)
                DispatchQueue.main.async {
                    self.portfolioModel.append(updatedItem)
                }
            }
            
        }
        catch let error as NSError {
            if let responseData = (error as? DecodingError)?.failureReason?.data(using: .utf8) {
                if let jsonString = String(data: responseData, encoding: .utf8) {
                    print("Response data: \(jsonString)")
                }
            } else {
                print("Error updating/creating portfolio item: \(error)")
            }
        }
    }
    
    func deletePortfolio(item: PortfolioItem) async {
        let myAPIService: FinnhubAPIService = FinnhubAPIService(
            baseURL: "https://nemesis-node-server.wl.r.appspot.com/api",
            token: ""
        )
        
        do {
            let foundItem = portfolioModel.first(where: { $0.ticker == item.ticker })
            
            // Delete the existing item
            if let id = foundItem?._id {
                let endpoint = "/portfolio/\(id)"
                try await myAPIService.deleteData(endpoint: endpoint, responseType: PortfolioResponse.self)
                
                if let index = portfolioModel.firstIndex(where: { $0.ticker == item.ticker }) {
                    DispatchQueue.main.async {
                        self.portfolioModel.remove(at: index)
                    }
                }
            }
        } catch {
            print("Failed to delete portfolio item: \(error)")
        }
    }        
}
