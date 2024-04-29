//
//  StockOverviewModel.swift
//  SwiftTrade
//
//  Created by Abhishek Kumar on 4/28/24.
//

import Foundation

struct StockOverviewModel: Codable {
    let name: String
    let ticker: String
    let ipo: String
    let finnhubIndustry: String
    let weburl: String // website
}
