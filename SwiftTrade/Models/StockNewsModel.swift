//
//  StockNewsModel.swift
//  SwiftTrade
//
//  Created by Abhishek Kumar on 4/28/24.
//

import Foundation

struct StockNewsModel: Codable, Identifiable {
    let id: Int
    let datetime: Date
    let source: String
    let headline: String
    let summary: String
    let url: String
    let image: String
}
