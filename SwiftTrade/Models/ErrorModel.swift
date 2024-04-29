//
//  ErrorModel.swift
//  SwiftTrade
//
//  Created by Abhishek Kumar on 4/28/24.
//

import Foundation

enum StockError: Error {
    case invalidURL
    case invalidResponse
    case invalidData
}
