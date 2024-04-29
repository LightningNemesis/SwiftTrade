//
//  StatModel.swift
//  SwiftTrade
//
//  Created by Abhishek Kumar on 4/28/24.
//

import Foundation

struct StatModel: Codable {
    let c: Float // close price
    let d: Float // current price
    let dp: Float // change in price
    let h: Float // high price
    let l: Float // low price
    let o: Float // open price
    let pc: Float // % change
    let t: CLong // timestamp
}
