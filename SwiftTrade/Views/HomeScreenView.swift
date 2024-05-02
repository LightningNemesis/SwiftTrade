//
//  HomeScreen.swift
//  SwiftTrade
//
//  Created by Abhishek Kumar on 4/27/24.
//

import SwiftUI
import Combine

//struct PortfolioModel: Identifiable {
//    let id: String = UUID().uuidString
//    let ticker: String
//    let count: Int
//    let totalPrice: Float
//    let changePrice: Float
//    let changePercent: Float
//}

struct FavoriteModel: Identifiable {
    let id: String = UUID().uuidString
    let ticker: String
    let name: String
    let currentPrice: Float
    let changePrice: Float
    let changePercent: Float
}

struct PortfolioResponse: Codable, Identifiable {
    let _id: String
    let name: String
    let quantity: Int
    let avgCost: Float
    let totalCost: Float
    let change: Float
    let currentPrice: Float
    let marketValue: Float
    let country: String
    let currency: String
    let estimateCurrency: String
    let exchange: String
    let finnhubIndustry: String
    let ipo: String
    let logo: String
    let marketCapitalization: Float
    let phone: String
    let shareOutstanding: Float
    let ticker: String
    let weburl: String
    var id: String { _id }
}

struct FavoriteResponse: Codable, Identifiable{
    let _id: String
    let c: Float
    let d: Float
    let dp: Float
    let ipo: String
    let shareOutstanding: Float
    let ticker: String
    let weburl: String
    let name: String
    var id: String { _id }
}


class AutocompleteViewModel: ObservableObject {
    @State private var stockAutocompleteResponse: AutocompleteResponse
    @Published var stockAutocomplete: [AutocompleteModel]
    @Published var isLoading: Bool
    
    init() {
        self.stockAutocompleteResponse = AutocompleteResponse(
            result: []
        )
        
        self.stockAutocomplete = []
        
        self.isLoading = false
    }
    
    func getAutocompleteData(stockInput: String) async {
        do {
            let response: AutocompleteResponse = try await FinnhubAPIService.shared.fetchData(from: "/search?q=\(stockInput)", decodingType: AutocompleteResponse.self)
            extractAndStoreAutocompleteData(from: response)
        }
        catch {
            print("Failed to fetch data: \(error)")
        }
    }
    
    func extractAndStoreAutocompleteData(from response: AutocompleteResponse){
        var autocompleteDataArray: [AutocompleteModel] = []
        
        for element in response.result {
            let autocompleteData = AutocompleteModel(
                displaySymbol: element.displaySymbol, 
                symbol: element.symbol,
                description: element.description
            )
            autocompleteDataArray.append(autocompleteData)
        }
        
        DispatchQueue.main.async {
            self.isLoading = true
            self.stockAutocomplete = autocompleteDataArray
            self.isLoading = false
        }
    }
}

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
}

class FavoriteViewModel: ObservableObject {
    @Published var favoriteModel: [FavoriteResponse]
    @Published var isLoading: Bool
    
    init() {
        self.favoriteModel = []
        self.isLoading = false
    }
    
    func getWatchlist() async {
        do {
            let myAPIService: FinnhubAPIService = FinnhubAPIService(
                baseURL: "https://nemesis-node-server.wl.r.appspot.com/api",
                token: ""
            )
            
            let response: [FavoriteResponse] = try await myAPIService.fetchData(from: "/watchlist", decodingType: [FavoriteResponse].self)
            
            DispatchQueue.main.async {
                self.isLoading = true
                self.favoriteModel = response
                self.isLoading = false
            }
            
        }catch {
            print("Failed to fetch portfolio data: \(error)")
        }
    }
}

struct HomeScreenView: View {
    @StateObject var autocompleteViewModel: AutocompleteViewModel = AutocompleteViewModel()
    @StateObject var portfolioViewModel: PortfolioViewModel = PortfolioViewModel()
    @StateObject var favoriteViewModel: FavoriteViewModel = FavoriteViewModel()
    
    @State var stockInput: String = ""
    @State var searchedStock: String = ""
    @FocusState private var isTextFieldFocused: Bool
    
    // Debounce implementation
    @State private var debounceTimer: AnyCancellable?
    
    @State var date: String = "March 21, 2024"
    @State var netWorth: Float = 25000.00
    @State var cashBalance: Float = 25000.00
    
//    @State var portfolio: [PortfolioModel] = [
//            PortfolioModel(ticker: "AAPL", count: 3, totalPrice: 517.74, changePrice: 0.03, changePercent: 0.01),
//            PortfolioModel(ticker: "NVDA", count: 11, totalPrice: 10382.74, changePrice: 0.03, changePercent: 1.32)
//        ]
    
//    @State var favorites: [FavoriteModel] = [
//        FavoriteModel(ticker: "AAPL", name: "Apple Inc", currentPrice: 172.58, changePrice: 1.21, changePercent: 0.71),
//        FavoriteModel(ticker: "QCOM", name: "Qualcomm Inc", currentPrice: 171.26, changePrice: 0.03, changePercent: 1.32)
//    ]
    
   
        
    var body: some View {
        NavigationView{
            ZStack{
                // Background
                Color(UIColor.secondarySystemBackground).ignoresSafeArea()
                
                // Foreground
                VStack{
                    HStack{
                        // Search bar
                        SearchBarView(
                            stockInput: $stockInput,
                            isTextFieldFocused: $isTextFieldFocused,
                            onSearch: handleSearch
                        )
                        
                        if isTextFieldFocused {
                            Button(action: {
                                stockInput = ""
                            }, label: {
                                Text("Cancel")
                            })
                            .padding(.trailing)
                        }
                    }
                    
                    
                    if !textFieldContainsInput() {
                        // Date
                        DateView(date: $date)
                        
                        // Portfolio, Favorites & Footer Button
                        if portfolioViewModel.isLoading || favoriteViewModel.isLoading {
                            ProgressView()
                        } else {
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
                                    
                                    
                                    
                                    ForEach(portfolioViewModel.portfolioModel) { portItem in
                                        NavigationLink {
                                            //                                        StockDetailsView(searchedStock: "NVDA")
                                            TradeSheetView()
                                        } label: {
                                            HStack{
                                                VStack(alignment: .leading){
                                                    Text(portItem.ticker)
                                                        .font(.headline)
                                                    Text("\(portItem.quantity) shares")
                                                        .font(.caption)
                                                        .foregroundColor(.gray)
                                                }
                                                
                                                Spacer()
                                                
                                                VStack(alignment:.trailing){
                                                    Text(String(format: "$%.2f", portItem.totalCost))
                                                        .font(.subheadline)
                                                        .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                                                    Text(String(format: "↗ $%.2f (%.2f%%)", portItem.change, portItem.change ))
                                                        .font(.subheadline)
                                                }
                                            }
                                        }
                                    }
                                }
                                
                                Section(header: Text("Favourites")) {
                                    ForEach(favoriteViewModel.favoriteModel){ favItem in
                                        NavigationLink {
                                            //                                        StockDetailsView(searchedStock: "NVDA")
                                            TradeSheetView()
                                        } label: {
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
                                                    Text(String(format: "$%.2f", favItem.c))
                                                        .font(.subheadline)
                                                        .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                                                    Text(String(format: "↗ $%.2f (%.2f%%)", favItem.d, favItem.dp ))
                                                        .font(.subheadline)
                                                }
                                            }
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
                        
                    } else {
                        if autocompleteViewModel.isLoading || autocompleteViewModel.stockAutocomplete.isEmpty {
                            ProgressView()
                        }
                        List{
                            ForEach(autocompleteViewModel.stockAutocomplete, id: \.symbol) { item in
                                NavigationLink(
                                    destination: StockDetailsView(searchedStock: item.symbol)
                                ) {
                                    VStack(alignment: .leading){
                                        Text(item.symbol)
                                            .font(.title3)
                                            .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                                        Text(item.description.uppercased())
                                            .font(.title3)
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                        }
                        .onChange(of: stockInput) { _ in
                            debounceSearch()
                        }
                    }
                }
                .onAppear {
                    Task {
                        await portfolioViewModel.getPortfolio()
                        await favoriteViewModel.getWatchlist()
                    }
                }
                .navigationTitle("Stocks")
                .navigationBarItems(trailing: EditButton())
                .navigationBarHidden(isTextFieldFocused)
                .animation(Animation.default)
            }
        }
    }
    
    func delete(indexSet: IndexSet) {
        favoriteViewModel.favoriteModel.remove(atOffsets: indexSet)
    }
    
    func move(indices: IndexSet, newOffset: Int) {
        favoriteViewModel.favoriteModel.move(fromOffsets: indices, toOffset: newOffset)
    }
    
    func textFieldContainsInput() -> Bool {
        if stockInput.count >= 1 {
            return true
        } else {
            return false
        }
    }
    
    func handleSearch(_ query: String) {
        Task{
            print("Making API call now")
            await autocompleteViewModel.getAutocompleteData(stockInput: query)
        }
    }
    
    func debounceSearch() {
        debounceTimer?.cancel()  // Cancel any existing timer
        debounceTimer = Just(stockInput)
            .delay(for: .seconds(0.5), scheduler: RunLoop.main)
            .sink(receiveValue: { [self] _ in
                handleSearch(stockInput)
            })
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
    var isTextFieldFocused: FocusState<Bool>.Binding
    var onSearch: (String) -> Void
    
    var body: some View {
        TextField(
            "🔎 Search",
            text: $stockInput
        )
//        .onChange(of: stockInput, perform: { newValue in
//            if newValue.count >= 1 {
//                onSearch(newValue)
//            }
//        })
        .focused(isTextFieldFocused)
        .padding(.top, 10)
        .padding(.bottom, 10)
        .padding(.horizontal)
        .background(.white)
        .cornerRadius(10)
        .padding(.horizontal)
    }
}
