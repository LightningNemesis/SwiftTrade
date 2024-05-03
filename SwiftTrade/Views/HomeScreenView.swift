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

//struct FavoriteModel: Identifiable {
//    let id: String = UUID().uuidString
//    let ticker: String
//    let name: String
//    let currentPrice: Float
//    let changePrice: Float
//    let changePercent: Float
//}

struct PortfolioResponse: Codable, Identifiable {
    let _id: String
    let name: String
    let quantity: Int
    let avgCost: Float
    let totalCost: Float
    let change: Float
    let marketValue: Float
    let ticker: String
    var id: String { _id }
}

struct FavoriteResponse: Codable, Identifiable{
    let _id: String
    let c: Float
    let d: Float
    let dp: Float
    let ipo: String
//    let shareOutstanding: Float
    let ticker: String
    let weburl: String
    let name: String
    var id: String { _id }
}

struct WalletResponse: Codable {
    let _id: String
    let amount: Float
}


class WalletViewModel: ObservableObject {
    @Published var amount: Float
    @Published var isLoading: Bool
    
    init() {
        self.amount = 0.0
        self.isLoading = false
    }
    
    func getWallet() async {
        do {
            let myAPIService: FinnhubAPIService = FinnhubAPIService(
                baseURL: "https://nemesis-node-server.wl.r.appspot.com/api",
                token: ""
            )
            
            let response: WalletResponse = try await myAPIService.fetchData(from: "/wallet", decodingType: WalletResponse.self)
            DispatchQueue.main.async {
                self.isLoading = true
                self.amount = response.amount
                self.isLoading = false
            }
        }
        catch {
            print("Failed to fetch wallet data: \(error)")
        }
    }
    
    func updateWallet(updatedAmount: Float) async {
        let myAPIService: FinnhubAPIService = FinnhubAPIService(
            baseURL: "https://nemesis-node-server.wl.r.appspot.com/api",
            token: ""
        )
        
        do {
            let endpoint = "/wallet"
            
            let updatedWallet = ["amount": updatedAmount]
            try await myAPIService.putData(endpoint: endpoint, requestBody: updatedWallet, responseType: WalletResponse.self)
            
            DispatchQueue.main.async {
                self.amount = updatedAmount
            }
        }
        catch{
            print("Failed to update wallet: \(error)")
        }
    }
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
            print("Failed to fetch watchlist data: \(error)")
        }
    }
    
    func addWatchlist(item: FavoriteItem) async {
        do {
            let myAPIService: FinnhubAPIService = FinnhubAPIService(
                baseURL: "https://nemesis-node-server.wl.r.appspot.com/api",
                token: ""
            )
            
            let endpoint = "/watchlist"
            
            // Serialize item to JSON for logging
            let jsonData = try JSONEncoder().encode(item)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("Creating new item: \(jsonString)")
            }
            
            let updatedItem = try await myAPIService.postData(endpoint: endpoint, requestBody: item, responseType: FavoriteResponse.self)
            DispatchQueue.main.async {
                self.favoriteModel.append(updatedItem)
            }
            
        } catch {
            print("Failed to update watchlist data: \(error)")
        }
    }
    
    func removeWatchlist(item: FavoriteResponse) async {
        do {
            let myAPIService: FinnhubAPIService = FinnhubAPIService(
                baseURL: "https://nemesis-node-server.wl.r.appspot.com/api",
                token: ""
            )
            
            let foundItem = favoriteModel.first(where: { $0.ticker == item.ticker })
            
            // Delete the existing item
            if let id = foundItem?._id {
                let endpoint = "/watchlist/\(id)"
                try await myAPIService.deleteData(endpoint: endpoint, responseType: PortfolioResponse.self)
                
                if let index = favoriteModel.firstIndex(where: { $0.ticker == item.ticker }) {
                    DispatchQueue.main.async {
                        self.favoriteModel.remove(at: index)
                    }
                }
            }
        } catch {
            print("Failed to update watchlist data: \(error)")
        }
    }
}

struct CustomStat: Codable, Identifiable {
    var id: String = UUID().uuidString
    var stat: StatModel
    var portfolioItem: PortfolioResponse
}

class PortfolioDetailModel: ObservableObject {
    @Published var stat: StatModel?
    @Published var customStat: [CustomStat] = []
    @Published var isLoading: Bool = false
    @Published var netWorth: Float = 0.0
    
    
    init() {
        self.stat = StatModel(c: 0.0, d: 0.0, dp: 0.0, h: 0.1, l: 0.0, o: 0.0, pc: 0.0, t: 0)
        self.customStat = []
        self.netWorth = 0.0
        self.isLoading = false
    }
    
    // GET Stock Summary
    func getStat(stock: String) async throws -> StatModel {
        let endpoint = "https://finnhub.io/api/v1/quote?symbol=\(stock)&token=cn2vjohr01qt9t7visi0cn2vjohr01qt9t7visig"
        
        guard let url = URL(string: endpoint) else {
            throw StockError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url) // making the GET request
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw StockError.invalidResponse
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let decodedData = try decoder.decode(StatModel.self, from: data)
            
            return decodedData
//            DispatchQueue.main.async {
//                self.stat = decodedData
//                self.customStat.stat = decodedData
//                self.customStat.ticker = stock
//            }
        } catch {
            throw StockError.invalidData
        }
    }
    
    func transformData(portfolioData: [PortfolioResponse]) async {
        var customStatDataArray: [CustomStat] = []
        var netWorthData: Float = 0
        for element in portfolioData {
            do {
                let statData = try await getStat(stock: element.ticker)
                let customStatElement = CustomStat(stat: statData, portfolioItem: element)
                customStatDataArray.append(customStatElement)
                netWorthData += element.totalCost
            } catch {
                print(error)
            }
        }
        DispatchQueue.main.async {
            
            self.isLoading = true
            self.customStat = customStatDataArray
            self.netWorth  = netWorthData
            self.isLoading = false
        }
        
    }
}

struct HomeScreenView: View {
    @StateObject var autocompleteViewModel: AutocompleteViewModel = AutocompleteViewModel()
    @StateObject var portfolioViewModel: PortfolioViewModel = PortfolioViewModel()
    @StateObject var portfolioDetailViewModel: PortfolioDetailModel = PortfolioDetailModel()
    @StateObject var favoriteViewModel: FavoriteViewModel = FavoriteViewModel()
    @StateObject var walletViewModel: WalletViewModel = WalletViewModel()
    
    @State var stockInput: String = ""
    @State var searchedStock: String = ""
    @FocusState private var isTextFieldFocused: Bool
    
    // Debounce implementation
    @State private var debounceTimer: AnyCancellable?
    
    @State var date: String = "March 21, 2024"
//    @State var netWorth: Float = 25000.00    
        
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
                        DateView()
                        
                        // Portfolio, Favorites & Footer Button
                        if portfolioViewModel.isLoading || favoriteViewModel.isLoading || walletViewModel.isLoading || portfolioDetailViewModel.isLoading{
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
                                            Text(String(format: "$%.2f", portfolioDetailViewModel.netWorth + walletViewModel.amount))
                                                .font(.title2)
                                                .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                                        }
                                        Spacer()
                                        VStack(alignment:.leading){
                                            Text("Cash Balance")
                                                .font(.title2)
                                            Text(String(format: "$%.2f", walletViewModel.amount))
                                                .font(.title2)
                                                .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                                        }
                                    }
                                    
                                    
                                    ForEach(portfolioDetailViewModel.customStat) { item in
                                        NavigationLink {
                                            StockDetailsView(
                                                portfolioViewModel: portfolioViewModel,
                                                walletViewModel: walletViewModel,
                                                searchedStock: item.portfolioItem.ticker
                                            )
                                            .environmentObject(portfolioViewModel)
                                            .environmentObject(walletViewModel)
                                            .environmentObject(favoriteViewModel)
                                        } label: {
                                            HStack {
                                                VStack(alignment: .leading) {
                                                    Text(item.portfolioItem.ticker)
                                                        .font(.headline)
                                                    Text("\(item.portfolioItem.quantity) shares")
                                                        .font(.caption)
                                                        .foregroundColor(.gray)
                                                }
                                                Spacer()
                                                VStack(alignment:.trailing){
                                                    Text(String(format: "$%.2f", item.portfolioItem.totalCost))
                                                        .font(.subheadline)
                                                        .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                                                    HStack{
                                                        Image(systemName: item.stat.d >= 0 ? "arrow.up.right" : "arrow.down.right")
                                                            .foregroundColor(item.stat.d >= 0 ? .green : .red)
                                                        Text(String(format: "$%.2f (%.2f%%)", item.stat.d, item.stat.d ))
                                                            .font(.subheadline)
                                                            .foregroundColor(item.stat.d >= 0 ? .green : .red)
                                                    }
                                                }
                                            }
                                        }

                                        
                                    }
                                }
                                
                                Section(header: Text("Favourites")) {
                                    ForEach(favoriteViewModel.favoriteModel){ favItem in
                                        NavigationLink {
                                            StockDetailsView(
                                                portfolioViewModel: portfolioViewModel,
                                                walletViewModel: walletViewModel,
                                                searchedStock: favItem.ticker
                                            )
                                            .environmentObject(portfolioViewModel)
                                            .environmentObject(walletViewModel)
                                            .environmentObject(favoriteViewModel)
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
                                                    HStack{
                                                        Image(systemName: favItem.d >= 0 ? "arrow.up.right" : "arrow.down.right")
                                                            .foregroundColor(favItem.d >= 0 ? .green : .red)
                                                        Text(String(format: "$%.2f (%.2f%%)", favItem.d, favItem.dp ))
                                                            .font(.subheadline)
                                                            .foregroundColor(favItem.d >= 0 ? .green : .red)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    .onDelete(perform: delete)
                                    .onMove(perform: move)
                                }
                                
                                if let url = URL(string: "https://finnhub.io/") {
                                    Link("Powered by Finnhub.io", destination: url)
                                        .font(.subheadline)
                                        .fontWeight(.light)
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .padding()
                                        .background(.white)
                                        .cornerRadius(10)
                                }
//                                Text("Powered by Finnhub.io")
//                                        .font(.subheadline)
//                                        .fontWeight(.light)
//                                        .frame(maxWidth: .infinity, alignment: .center)
//                                        .padding()
//                                        .background(.white)
//                                        .cornerRadius(10)
                            }
                        }
                        
                    } else {
                        if autocompleteViewModel.isLoading || autocompleteViewModel.stockAutocomplete.isEmpty {
                            ProgressView()
                        }
                        List{
                            ForEach(autocompleteViewModel.stockAutocomplete, id: \.symbol) { item in
                                NavigationLink(
                                    destination: 
                                        StockDetailsView(searchedStock: item.symbol)                                        
                                        .environmentObject(portfolioViewModel)
                                        .environmentObject(walletViewModel)
                                        .environmentObject(favoriteViewModel)
                                    
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
                        await walletViewModel.getWallet()
                        await portfolioDetailViewModel.transformData(portfolioData: portfolioViewModel.portfolioModel)
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
        guard let index = indexSet.first else {
                return
            }
        
        Task {
            await favoriteViewModel.removeWatchlist(item: favoriteViewModel.favoriteModel[index])
            favoriteViewModel.favoriteModel.remove(atOffsets: indexSet)
        }
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
//    @Binding var date: String
    
    var body: some View {
        Text(Date().formatted(.longDateFormatter))
                    .padding()
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
            "Search",
            text: $stockInput
        )
        .padding(.leading, 35)
//        .onChange(of: stockInput, perform: { newValue in
//            if newValue.count >= 1 {
//                onSearch(newValue)
//            }
//        })
        .overlay(
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading) // Aligns icon to the left
//                    .padding(.leading) // Adds space from the edge of the TextField
                Spacer()
            }
        )
        .focused(isTextFieldFocused)
        .padding(.top, 10)
        .padding(.bottom, 10)
        .padding(.horizontal)
        .background(.white)
        .cornerRadius(10)
        .padding(.horizontal)
    }
}

extension DateFormatter {
    static let longDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
}

extension Date {
    func formatted(_ formatter: DateFormatter) -> String {
        formatter.string(from: self)
    }
}
