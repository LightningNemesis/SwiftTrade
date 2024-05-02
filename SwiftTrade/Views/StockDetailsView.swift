//
//  StockDetailsView.swift
//  SwiftTrade
//
//  Created by Abhishek Kumar on 4/27/24.
//

import SwiftUI

struct FavoriteItem: Codable {
    let c: Float
    let d: Float
    let dp: Float
    let ipo: String
    let ticker: String
    let weburl: String
    let name: String
}

struct StockDetailsView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @State var showTradeSheet: Bool = false
    @StateObject var stockDetailViewModel: StockDetailViewModel = StockDetailViewModel()
    @ObservedObject var portfolioViewModel: PortfolioViewModel = PortfolioViewModel()
    @ObservedObject var walletViewModel: WalletViewModel = WalletViewModel()
    @ObservedObject var favoriteViewModel: FavoriteViewModel = FavoriteViewModel()
    @StateObject var insiderViewModel: InsiderViewModel = InsiderViewModel()
    
    let searchedStock: String
    
    func addToFavorite() async {
        let favItem: FavoriteItem = FavoriteItem(c: stockDetailViewModel.stat.c, d: stockDetailViewModel.stat.d, dp: stockDetailViewModel.stat.dp, ipo: stockDetailViewModel.stockOverview.ipo, ticker: stockDetailViewModel.stockOverview.ticker, weburl: stockDetailViewModel.stockOverview.weburl, name: stockDetailViewModel.stockOverview.name)
        
        await favoriteViewModel.addWatchlist(item: favItem)
    }
    
    var body: some View {
        ScrollView (showsIndicators:false){
            if stockDetailViewModel.isLoading || portfolioViewModel.isLoading || insiderViewModel.isLoading {
                ProgressView()
            }else{
                // Name, Price and Change in Price
                NamePriceView(stockDetailViewModel: stockDetailViewModel)
                
                // Portfolio subview
                PortfolioView(
                    stockDetailViewModel: stockDetailViewModel, 
                    showTradeSheet: $showTradeSheet
                )
                
                // Stats subview
                StatsView(stockDetailViewModel: stockDetailViewModel)
                
                // About subview
                AboutView(stockDetailViewModel: stockDetailViewModel)
                
                // Insights subview
                VStack{
                    Text("Insights")
                        .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                       
                    if !insiderViewModel.insiderModel.isEmpty {
                        InsiderSentimentsView(insiderViewModel: insiderViewModel)
                    }
                    
                }
                
                // News subview
                VStack{
                    Text("News")
                        .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                    NewsView(stockDetailViewModel: stockDetailViewModel)
                }
            }
        }
        .padding(.horizontal)
        .navigationTitle(searchedStock)
        .navigationBarItems(
            leading:
                Button(
                    action: {
                        self.presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Stocks")
                        }
                    },
            trailing:
                Button(action: {
                    Task{
                        await addToFavorite()
                    }
                    
                }, label: {
                    Image(systemName: "plus.circle")
                    .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                })
                
        )
        .navigationBarBackButtonHidden(true)
        .onAppear {
            Task {
                await stockDetailViewModel.loadData(stock: searchedStock)
                do {
                    try await insiderViewModel.getSentiment(stock: searchedStock)
                } catch {
                    print("Failed to get sentiment: \(error)")
                }
            }
        }
    }
}




#Preview {
        StockDetailsView(searchedStock: "ANET")
}

struct NamePriceView: View {
    
    @ObservedObject var stockDetailViewModel: StockDetailViewModel
    
    var body: some View {
        VStack(alignment:.leading){
            Text(stockDetailViewModel.stockOverview.name)
                .font(.title2)
                .foregroundColor(.gray)
                .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
            
            HStack(alignment: .center){
                Text(String(format: "$%.2f", stockDetailViewModel.stat.h))
                    .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                
                Image(systemName: "arrow.up.forward")
                    .foregroundColor(.green)
                Text(String(format: "$%.2f (%.2f%%)", stockDetailViewModel.stat.dp, stockDetailViewModel.stat.pc))
                    .font(.title2)
                    .foregroundColor(.green)
                
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical)
        }
    }
}

struct PortfolioView: View {
    @ObservedObject var stockDetailViewModel: StockDetailViewModel
    @EnvironmentObject var walletViewModel: WalletViewModel
    @EnvironmentObject var portfolioViewModel: PortfolioViewModel
    @Binding var showTradeSheet: Bool
    
    var body: some View {
        VStack{
            Text("Portfolio")
                .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
            
            HStack{
                if portfolioViewModel.portfolioModel.isEmpty || getPortfolioItem(ticker: stockDetailViewModel.stockOverview.ticker) == nil {
                    Text("You have 0 shares of AAPL.\nStart trading!")
                        .font(.subheadline)
                } else {
                    if let portfolioFoundItem = getPortfolioItem(ticker: stockDetailViewModel.stockOverview.ticker) {
                        VStack(alignment: .leading){
                            HStack{
                                Text("Shares owned:")
                                    .font(.subheadline)
                                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                                Text("\(portfolioFoundItem.quantity)")
                                    .font(.subheadline)
                            }
                            .padding(.vertical, 5)
                            
                            HStack{
                                Text("Avg. Cost / Share:")
                                    .font(.subheadline)
                                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                                Text(String(format: "$%.2f", portfolioFoundItem.avgCost))
                                    .font(.subheadline)
                            }
                            .padding(.vertical, 5)
                            
                            HStack{
                                Text("Total Cost:")
                                    .font(.subheadline)
                                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                                Text(String(format: "$%.2f", portfolioFoundItem.totalCost))
                                    .font(.subheadline)
                            }
                            .padding(.vertical, 5)
                            
                            HStack{
                                Text("Change:")
                                    .font(.subheadline)
                                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                                Text(String(format: "$%.2f", portfolioFoundItem.change))
                                    .font(.subheadline)
                            }
                            .padding(.vertical, 5)
                            
                            HStack{
                                Text("Market Value:")
                                    .font(.subheadline)
                                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                                Text(String(format: "$%.2f", portfolioFoundItem.marketValue))
                                    .font(.subheadline)
                            }
                        }
                    }
                    
                }
                
                
                Spacer()
                
                Button(action: {
                    showTradeSheet.toggle()
                }, label: {
                    Text("Trade")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 30)
                        .background(.green)
                        .cornerRadius(30)
                    
                })
                .sheet(isPresented: $showTradeSheet, content: {
                    TradeSheetView()
                        .environmentObject(stockDetailViewModel)
                        .environmentObject(walletViewModel)
                        .environmentObject(portfolioViewModel)
                })
                
            }
//            .padding(.vertical)
        }
    }
    
    func getPortfolioItem(ticker: String) -> PortfolioItem? {
        if let foundItem = portfolioViewModel.portfolioModel.first(where: { $0.ticker == ticker }) {
            let newPortfolioItem = PortfolioItem(quantity: foundItem.quantity, avgCost: foundItem.avgCost, change: foundItem.change, marketValue: foundItem.marketValue, totalCost: foundItem.totalCost, name: foundItem.name, ticker: foundItem.ticker)
            return newPortfolioItem
        }
        else {
            return nil
        }
    }
}

struct StatsView: View {
    
    @ObservedObject var stockDetailViewModel: StockDetailViewModel
    
    var body: some View {
        VStack{
            Text("Stats")
                .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
            
            HStack{
                VStack(alignment: .leading){
                    HStack{
                        Text("High Price:")
                            .font(.headline)
                        Text(String(format: "$%.2f", stockDetailViewModel.stat.h))
                            .font(.subheadline)
                    }
                    HStack{
                        Text("Low Price:")
                            .font(.headline)
                        Text(String(format: "$%.2f", stockDetailViewModel.stat.l))
                            .font(.subheadline)
                    }
                    
                }
                .frame(maxWidth:.infinity, alignment: .leading)
                
                
                VStack(alignment: .leading){
                    HStack{
                        Text("Open Price:")
                            .font(.headline)
                        Text(String(format: "$%.2f", stockDetailViewModel.stat.o))
                            .font(.subheadline)
                    }
                    HStack{
                        Text("Prev. Close:")
                            .font(.headline)
                        Text(String(format: "$%.2f", stockDetailViewModel.stat.pc))
                            .font(.subheadline)
                    }
                }
                .frame(maxWidth:.infinity, alignment: .leading)
            }
            .padding(.vertical, 5)
        }
    }
}

struct AboutView: View {
    
    @ObservedObject var stockDetailViewModel: StockDetailViewModel
    
    var body: some View {
        VStack{
            
            Text("About")
                .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
            
            HStack{
                VStack(alignment:.leading){
                    Text("IPO Start Date:")
                    Text("Industry:")
                    Text("Webpage:")
                    Text("Company Peers:")
                }
                .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                .font(.subheadline)
                .fontWeight(.bold)
                
                Spacer()
                
                VStack(alignment:.leading){
                    Text(stockDetailViewModel.stockOverview.ipo)
                    Text(stockDetailViewModel.stockOverview.finnhubIndustry)
                    if let url = URL(string: stockDetailViewModel.stockOverview.weburl) {
                        Link(stockDetailViewModel.stockOverview.weburl, destination: url)
                        .lineLimit(1) // Ensures the text does not wrap
                        .truncationMode(.tail) // Adds '...' if the text is too long
                    }
                    ScrollView(.horizontal, showsIndicators:false, content:{
                        LazyHStack{
                            ForEach(stockDetailViewModel.stockPeers, id: \.self){ peer in
                                Text("\(peer.uppercased()),")
                                    .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                            }
                        }
                    })
                    
                }
                .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                .font(.subheadline)
            }
            .padding(.vertical, 5)
        }
    }
}

struct InsiderSentimentsView: View {
    @ObservedObject var insiderViewModel: InsiderViewModel = InsiderViewModel()
    
    @State private var totalChange: Int = 0
    @State private var totalMSPR: Float = 0.0
    @State private var posMSPR: Float = 0.0
    @State private var negMSPR: Float = 0.0
    @State private var posChange: Int = 0
    @State private var negChange: Int = 0
    
    func transformData() {
        print(insiderViewModel.insiderModel)
        
        for element in insiderViewModel.insiderModel {
            if element.mspr > 0 {
                posMSPR += element.mspr
            }
            
            if element.change > 0 {
                posChange += element.change
            }
            
            if element.mspr < 0 {
                negMSPR += element.mspr
            }
            
            if element.change < 0 {
                negChange += element.change
            }
            
            totalMSPR += element.mspr
            totalChange += element.change
        }
    }
    
    var body: some View {
        VStack{
            Text("Insider Sentiments")
                .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .center)
            
            HStack{
                VStack(alignment: .leading){
                    Text("Apple Inc")
                    Divider()
                    Text("Total")
                    Divider()
                    Text("Postive")
                    Divider()
                    Text("Negative")
                    Divider()
                }
                .font(.subheadline)
                .fontWeight(.bold)
                
                Spacer()
                
                VStack(alignment: .leading){
                    Text("MSPR")
                        .fontWeight(.bold)
                    Divider()
                    Text(String(format: "%.2f", totalMSPR))
                    Divider()
                    Text(String(format: "%.2f", posMSPR))
                    Divider()
                    Text(String(format: "%.2f", negMSPR))
                    Divider()
                }
                .font(.subheadline)
                
                Spacer()
                
                VStack(alignment: .leading){
                    Text("Change")
                        .fontWeight(.bold)
                    Divider()
                    Text(String(format: "%d", totalChange))
                    Divider()
                    Text(String(format: "%d", posChange))
                    Divider()
                    Text(String(format: "%d", negChange))
                    Divider()
                }
                .font(.subheadline)

            }
            .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
            .padding(.vertical)
        }
        .onAppear(perform: {
            transformData()
        })
        .padding(.vertical)
        
    }
}

struct NewsView: View {
    
    @ObservedObject var stockDetailViewModel: StockDetailViewModel
    @State private var selectedNewsItem: StockNewsModel?
    
    var body: some View {
        VStack{
            LazyVStack{
                
                if let firstNews = stockDetailViewModel.companyNews.first {
                    Button(action: {
                        selectedNewsItem = stockDetailViewModel.companyNews.first
                    }, label: {
                        VStack(alignment: .leading){
                            AsyncImage(url: URL(string: firstNews.image), content: { returnedImage in
                                returnedImage
                                    .resizable()
                                    .frame(height: 200)
                                    .scaledToFill()
                                    .cornerRadius(10)
                            }, placeholder: {
                                ProgressView()
                            })
                            
                            
                            HStack{
                                Text(firstNews.source)
                                    .font(.caption)
                                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                                    .foregroundColor(.gray)
                                Text(convertTimestampToDuration(timestamp: firstNews.datetime))
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            
                            Text(firstNews.headline.capitalized)
                                .font(.headline)
                                .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                                .foregroundColor(.black)
                                .multilineTextAlignment(.leading)
                            
                            Rectangle()
                                .fill(.gray)
                                .frame(height: 0.5)
                                .padding(.bottom)
                        }
                    })
                }
                
                
                
                ForEach(stockDetailViewModel.companyNews.dropFirst()){ newsItem in
                    Button(action: {
                        selectedNewsItem = newsItem
                    }, label: {
                        HStack(alignment:.top){
                            VStack(alignment: .leading){
                                HStack{
                                    Text(newsItem.source)
                                        .font(.caption)
                                        .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                                        .foregroundColor(.gray)
                                    Text(convertTimestampToDuration(timestamp: newsItem.datetime))
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                Text(newsItem.headline.capitalized)
                                    .font(.headline)
                                    .foregroundColor(.black)
                                    .multilineTextAlignment(.leading)
                            }
                            Spacer()
                            AsyncImage(url: URL(string: newsItem.image), content: { returnedImage in
                                returnedImage
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .cornerRadius(10)
                            }, placeholder: {
                                ProgressView()
                                    .frame(width: 100, height: 100)
                            })
                            
                        }
                        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                    })
                }
            }
            .sheet(item: $selectedNewsItem, content: { newsItem in
                // DO NOT ADD CONDITIONAL LOGIC HERE
                NewsSheetView(newsItem: newsItem)
            })
        }
    }
    
    func convertTimestampToDuration(timestamp: TimeInterval) -> String {
        let targetDate = Date(timeIntervalSince1970: timestamp)
        let currentDate = Date()
        let timeInterval = currentDate.timeIntervalSince(targetDate)
        
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .short
        formatter.zeroFormattingBehavior = .dropAll
        
        return formatter.string(from: timeInterval) ?? "Time not available"
    }
}
