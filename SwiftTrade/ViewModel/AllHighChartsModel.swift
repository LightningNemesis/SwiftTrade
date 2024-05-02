//
//  AllHighChartsModel.swift
//  SwiftTrade
//
//  Created by Abhishek Kumar on 5/2/24.
//

import SwiftUI
import Foundation

struct TimeseriesResponse: Codable {
    let ticker: String
    let queryCount: Int
    let resultsCount: Int
    let adjusted: Bool
    let results: [TimeseriesModel]
}

struct TimeseriesModel: Codable {
    let v: Float
    let vw: Float
    let o: Float
    let c: Float
    let h: Float
    let l: Float
    let t: TimeInterval
    let n: Int
}
struct HourlyModel {
    let c: Float
    let t: TimeInterval
}

struct OhlcModel {
    let o: Float
    let h: Float
    let l: Float
    let c: Float
    let t: TimeInterval
}

struct VolumeModel {
    let v: Float
    let t: TimeInterval
}

struct RecommendationResponse: Codable {
    let buy: Int
    let hold: Int
    let sell: Int
    let period: String
    let strongBuy: Int
    let strongSell: Int
    let symbol: String
}

struct RecommendationModel: Codable {
    var buy: [Int]
    var hold: [Int]
    var sell: [Int]
    var strongBuy: [Int]
    var strongSell: [Int]
    var period: [String]
}

struct EarningsResponse: Codable {
    let actual: Float
    let period: String
    let surprise: Float
    let estimate: Float
}

struct EarningsModel: Codable {
    var actual: [Float]
    var period: [String]
    var surprise: [Float]
    var estimate: [Float]
}

class APIService {
    static let shared = APIService(baseURL: "https://api.polygon.io/v2/aggs/", token: "y9CbEJ1gYrXZpwAWpXbAJrAL1ziBkaV2")

    private let baseURL: String
    private let token: String
    
    init(baseURL: String, token: String) {
        self.baseURL = baseURL
        self.token = token
    }
    
    func fetchDataHourlyHistorical<T: Decodable>(from endpoint: String, decodingType: T.Type) async throws -> T {
        let urlString = "\(baseURL)\(endpoint)"
        guard let url = URL(string: urlString) else {
            throw StockError.invalidURL
        }

        print("URL :\n\(urlString)")

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request) // making the API call

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw StockError.invalidResponse
        }

        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(T.self, from: data)
        } catch {
            throw StockError.invalidData
        }
    }
    
    func fetchDataRecommendationEPS<T: Decodable>(from endpoint: String, decodingType: T.Type) async throws -> T {
        // Construct the URL with the token as a query parameter
        let urlString = "\(baseURL)\(endpoint)&token=\(token)"
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
        
        // Decode the data
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(T.self, from: data)
        } catch {
            throw StockError.invalidData
        }
    }
}


class HighChartsViewModel: ObservableObject {
    @State private var timeSeriesResponse: TimeseriesResponse?
    @State private var recommendationResponse: RecommendationResponse?
    @State private var earningsResponse: EarningsResponse?
    
    @Published var hourlyModel: [HourlyModel]?
    @Published var ohlcModel: [OhlcModel]?
    @Published var volumeModel: [VolumeModel]?
    
    @Published var recommendationModel: RecommendationModel?
    @Published var earningsModel: EarningsModel?
    
    @Published var isLoading: Bool
    
    init() {
        self.timeSeriesResponse = TimeseriesResponse(
            ticker: "",
            queryCount: 0,
            resultsCount: 0,
            adjusted: false,
            results: []
        )
        self.hourlyModel = []
        self.ohlcModel = []
        self.volumeModel = []
        self.recommendationModel = RecommendationModel(
            buy: [],
            hold: [],
            sell: [],
            strongBuy: [],
            strongSell: [],
            period: []
        )
        self.earningsModel = EarningsModel(
            actual: [],
            period: [],
            surprise: [],
            estimate: []
        )
        
        self.isLoading = false
    }
    
    func getHourlyTimeseriesData(ticker: String) async {
        do{
            let myAPIService: APIService = APIService(
                baseURL: "https://api.polygon.io/v2/aggs/",
                token: "y9CbEJ1gYrXZpwAWpXbAJrAL1ziBkaV2"
            )
            
            let response: TimeseriesResponse = try await myAPIService.fetchDataHourlyHistorical(from: "ticker/\(ticker)/range/1/hour/2024-04-28/2024-04-29?adjusted=true&sort=asc", decodingType: TimeseriesResponse.self)
            
            extractAndStoreHourlyData(from: response)
            
        } catch {
            print("Failed to fetch data: \(error)")
        }
    }
    
    func getHistoricalTimeseriesData(ticker: String) async {
        do{
            let myAPIService: APIService = APIService(
                baseURL: "https://api.polygon.io/v2/aggs/",
                token: "y9CbEJ1gYrXZpwAWpXbAJrAL1ziBkaV2"
            )
            let response: TimeseriesResponse = try await myAPIService.fetchDataHourlyHistorical(from: "ticker/\(ticker)/range/1/day/2023-04-28/2024-04-29?adjusted=true&sort=asc", decodingType: TimeseriesResponse.self)
            
            extractAndStoreHistoricalData(from: response)
            
        } catch {
            print("Failed to fetch data: \(error)")
        }
    }
    
    func getRecommendationsData(ticker: String) async {
        do{
            let myAPIService: APIService = APIService(
                baseURL: "https://finnhub.io/api/v1",
                token: "cn2vjohr01qt9t7visi0cn2vjohr01qt9t7visig"
            )
            let response: [RecommendationResponse] = try await myAPIService.fetchDataRecommendationEPS(from: "/stock/recommendation?symbol=\(ticker)", decodingType: [RecommendationResponse].self)
            
            extractAndStoreRecommendationData(from: response)
            
        } catch {
            print("Failed to fetch data: \(error)")
        }
    }
    
    func getEarningsData(ticker: String) async {
        do{
            let myAPIService: APIService = APIService(
                baseURL: "https://finnhub.io/api/v1",
                token: "cn2vjohr01qt9t7visi0cn2vjohr01qt9t7visig"
            )
            let response: [EarningsResponse] = try await myAPIService.fetchDataRecommendationEPS(from: "/stock/earnings?symbol=\(ticker)", decodingType: [EarningsResponse].self)
            
            extractAndStoreEarningsData(from: response)
            
        } catch {
            print("Failed to fetch data: \(error)")
        }

    }
    
    func extractAndStoreHourlyData(from response: TimeseriesResponse){
        var hourlyDataArray: [HourlyModel] = []
        
        for element in response.results {
            let hourlyData = HourlyModel(
                c: element.c,
                t: element.t
            )
            hourlyDataArray.append(hourlyData)
        }
        
        DispatchQueue.main.async {
            self.isLoading = true
            self.hourlyModel = hourlyDataArray
            self.isLoading = false
        }
    }
    
    func extractAndStoreHistoricalData(from response: TimeseriesResponse){
        var ohlcDataArray: [OhlcModel] = []
        var volumeDataArray: [VolumeModel] = []
        
        for element in response.results {
            let ohlcData = OhlcModel(
                o: element.o,
                h: element.h,
                l: element.h,
                c: element.c,
                t: element.t
            )
            ohlcDataArray.append(ohlcData)
            
            let volumeData = VolumeModel(
                v: element.v,
                t: element.t
            )
            volumeDataArray.append(volumeData)
        }
        
        DispatchQueue.main.async {
            self.isLoading = true
            self.ohlcModel = ohlcDataArray
            self.volumeModel = volumeDataArray
            self.isLoading = false
        }
    }
    
    func extractAndStoreRecommendationData(from response: [RecommendationResponse]){
        var buyArray: [Int] = []
        var sellArray: [Int] = []
        var holdArray: [Int] = []
        var strongBuyArray: [Int] = []
        var strongSellArray: [Int] = []
        var periodArray: [String] = []
        
        for element in response {
            buyArray.append(element.buy)
            holdArray.append(element.hold)
            sellArray.append(element.sell)
            strongBuyArray.append(element.strongBuy)
            strongSellArray.append(element.strongSell)
            periodArray.append(element.period)
        }
                
        
        DispatchQueue.main.async {
            self.isLoading = true
            self.recommendationModel?.buy = buyArray
            self.recommendationModel?.sell = sellArray
            self.recommendationModel?.hold = holdArray
            self.recommendationModel?.strongBuy = strongBuyArray
            self.recommendationModel?.strongSell = strongSellArray
            self.recommendationModel?.period = periodArray
            self.isLoading = false
        }
    }
    
    func extractAndStoreEarningsData(from response: [EarningsResponse]){
        var periodArray: [String] = []
        var actualArray: [Float] = []
        var estimateArray: [Float] = []
        var surpriseArray: [Float] = []
        
        for element in response {
            periodArray.append(element.period)
            actualArray.append(element.actual)
            estimateArray.append(element.estimate)
            surpriseArray.append(element.surprise)
        }
        
        DispatchQueue.main.async {
            self.isLoading = true
            
            self.earningsModel?.actual = actualArray
            self.earningsModel?.estimate = estimateArray
            self.earningsModel?.period = periodArray
            self.earningsModel?.surprise = surpriseArray
            
            self.isLoading = false
        }
    }
}
