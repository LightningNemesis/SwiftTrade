//
//  StockDetailsView.swift
//  SwiftTrade
//
//  Created by Abhishek Kumar on 4/27/24.
//

import SwiftUI

struct StockDetailsView: View {
    
    @Environment(\.presentationMode) var presentationMode
        
    @State var showTradeSheet: Bool = false
    
    @StateObject var stockDetailViewModel: StockDetailViewModel = StockDetailViewModel()
    
    var body: some View {
        ScrollView (showsIndicators:false){
            
            if stockDetailViewModel.isLoading{
                ProgressView()
            }else{
                // Name, Price and Change in Price
                NamePriceView(stockDetailViewModel: stockDetailViewModel)
                
                // Portfolio subview
                PortfolioView(showTradeSheet: $showTradeSheet)
                
                // Stats subview
                StatsView(stockDetailViewModel: stockDetailViewModel)
                
                // About subview
                AboutView(stockDetailViewModel: stockDetailViewModel)
                
                // Insights subview
                VStack{
                    Text("Insights")
                        .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                    
                    // Highcharts comes here
                }
                
                // News subview
                NewsView(stockDetailViewModel: stockDetailViewModel)
            }
        }
        .padding(.horizontal)
        .navigationTitle("AAPL")
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
                Image(systemName: "plus.circle")
                .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
        )
        .navigationBarBackButtonHidden(true)
        .onAppear {
            Task {
                await stockDetailViewModel.loadData()
            }
        }
    }
}




#Preview {
        StockDetailsView()    
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
    @Binding var showTradeSheet: Bool
    
    var body: some View {
        VStack{
            Text("Portfolio")
                .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
            
            HStack{
                Text("You have 0 shares of AAPL.\nStart trading!")
                    .font(.subheadline)
                
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
                })
                
            }
            .padding(.vertical)
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
                .font(.subheadline)
            }
            .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
            .padding(.vertical, 5)
        }
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
                                    .scaledToFill()
                                    .frame(height: 200)
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
