//
//  HomeScreen.swift
//  SwiftTrade
//
//  Created by Abhishek Kumar on 4/27/24.
//

import SwiftUI

struct PortfolioModel: Identifiable {
    let id: String = UUID().uuidString
    let ticker: String
    let count: Int
    let totalPrice: Float
    let changePrice: Float
    let changePercent: Float
}

struct FavoriteModel: Identifiable {
    let id: String = UUID().uuidString
    let ticker: String
    let name: String
    let currentPrice: Float
    let changePrice: Float
    let changePercent: Float
}

struct HomeScreenView: View {
    
    
    @State var stockInput: String = ""
    @State var date: String = "March 21, 2024"
    @State var netWorth: Float = 25000.00
    @State var cashBalance: Float = 25000.00
    
    
    @State var portfolio: [PortfolioModel] = [
            PortfolioModel(ticker: "AAPL", count: 3, totalPrice: 517.74, changePrice: 0.03, changePercent: 0.01),
            PortfolioModel(ticker: "NVDA", count: 11, totalPrice: 10382.74, changePrice: 0.03, changePercent: 1.32)
        ]
    
    @State var favorites: [FavoriteModel] = [
        FavoriteModel(ticker: "AAPL", name: "Apple Inc", currentPrice: 172.58, changePrice: 1.21, changePercent: 0.71),
        FavoriteModel(ticker: "QCOM", name: "Qualcomm Inc", currentPrice: 171.26, changePrice: 0.03, changePercent: 1.32)
    ]
    
   
        
    var body: some View {
        NavigationView{
            ZStack{
                // Background
                Color(UIColor.secondarySystemBackground).ignoresSafeArea()
                
                // Foreground
                VStack{
                    
                    // Search bar
                    SearchBarView(stockInput: $stockInput)
                    
                    // Date
                    DateView(date: $date)
                    
                    // Portfolio, Favorites & Footer Button
                
                    List{
                        Section(
                            header: Text("Portfolio")
                        ){
                            HStack{
                                VStack(alignment:.leading){
                                    Text("Net Worth")
                                        .font(.title2)
                                    Text(String(format: "$%.2f", netWorth))
                                        .font(.title2)
                                        .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                                }
                                Spacer()
                                VStack(alignment:.leading){
                                    Text("Cash Balance")
                                        .font(.title2)
                                    Text(String(format: "$%.2f", cashBalance))
                                        .font(.title2)
                                        .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                                }
                            }
                            
                            ForEach(portfolio){ portItem in
                                NavigationLink {
                                    StockDetailsView()
                                } label: {
                                    HStack{
                                        VStack(alignment: .leading){
                                            Text(portItem.ticker)
                                                .font(.headline)
                                                    
                                            Text("\(portItem.count) shares")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                        
                                        Spacer()
                                        
                                        VStack(alignment:.trailing){
                                            Text(String(format: "$%.2f", portItem.totalPrice))
                                                .font(.subheadline)
                                                .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                                            Text(String(format: "↗ $%.2f (%.2f%%)", portItem.changePrice, portItem.changePercent ))
                                                .font(.subheadline)
                                        }
                                    }
                                }
                            }
                        }
                        
                        Section(header: Text("Favourites")) {
                            ForEach(favorites){ favItem in
                                HStack{
                                    VStack(alignment: .leading){
                                        Text(favItem.ticker)
                                            .font(.headline)
                                        Text(favItem.name)
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    
                                    Spacer()
                                    
                                    VStack(alignment:.trailing){
                                        Text(String(format: "$%.2f", favItem.currentPrice))
                                            .font(.subheadline)
                                            .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                                        Text(String(format: "↗ $%.2f (%.2f%%)", favItem.changePrice, favItem.changePercent ))
                                            .font(.subheadline)
                                    }
                                    
                                    Image(systemName:"chevron.right")
                                        .foregroundColor(.gray)
                                }
                            }
                            .onDelete(perform: delete)
                            .onMove(perform: move)
                        }
                        
                        Text("Powered by Finnhub.io")
                                .font(.subheadline)
                                .fontWeight(.light)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding()
                                .background(.white)
                                .cornerRadius(10)
                        
                    }
                    
                }
                .navigationTitle("Stocks")
                .navigationBarItems(trailing: EditButton())
                
            }
        }
    }
    
    func delete(indexSet: IndexSet) {
        favorites.remove(atOffsets: indexSet)
    }
    
    func move(indices: IndexSet, newOffset: Int) {
        favorites.move(fromOffsets: indices, toOffset: newOffset)
    }
}

#Preview {
    HomeScreenView()
}

struct DateView: View {
    @Binding var date: String
    
    var body: some View {
        Text(date)
            .font(.title)
            .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
            .foregroundStyle(.gray)
            .padding(.top, 10)
            .padding(.bottom, 10)
            .padding(.horizontal)
            .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
            .background(.white)
            .cornerRadius(10)
            .padding(.horizontal)
    }
}

struct SearchBarView: View {
    @Binding var stockInput: String
    
    var body: some View {
        TextField(
            "🔎 Search",
            text: $stockInput
        )
        .padding(.top, 10)
        .padding(.bottom, 10)
        .padding(.horizontal)
        .background(.white)
        .cornerRadius(10)
        .padding(.horizontal)
    }
}
