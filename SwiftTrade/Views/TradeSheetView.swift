//
//  TradeSheetView.swift
//  SwiftTrade
//
//  Created by Abhishek Kumar on 4/28/24.
//

import SwiftUI

struct WalletResponse: Codable {
    let _id: String
    let amount: Float
    let __v: Int
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
    
    
}



struct TradeSheetView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var stockDetailViewModel: StockDetailViewModel = StockDetailViewModel()
    @StateObject var walletModel: WalletViewModel = WalletViewModel()
    @ObservedObject var portfolioModel: PortfolioViewModel = PortfolioViewModel()
    
    @State private var totalPrice: Float = 0.0
    
    @State var stockCount: Int = 0
    
    // Computed property to handle the conversion between Int and String for TextField
    var stockCountString: Binding<String> {
        Binding<String>(
            get: {
                String(self.stockCount)
            },
            set: {
                // Here, you can add additional logic to ensure only numbers are accepted
                if let value = Int($0) {
                    self.stockCount = value
                }
            }
        )
    }
    
    func calcPrice() {
        totalPrice = Float(stockCount) * stockDetailViewModel.stat.c
    }
    
    func tryFailBuy() -> Bool {
        if stockCount == 0 {
            print("Enter a value greater than 0")
            return false
        }
        if totalPrice > walletModel.amount {
            print("Can't buy more than your wallet")
            return false
        }
        return true
    }
    
    func tryBuy(){
        if tryFailBuy() {
           // make api call to buy here
            
        }
    }
    
    func tryFailSell() -> Bool {
        // filter portfolio to find stock, 
        // if can't find it, can't sell it
        // if found, and stockCount > owned, can't sell
        return true
    }
    
    func trySell() {
        if tryFailSell() {
            // make api call to sell here
        }
    }
    
    
    var body: some View {
        VStack{
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }, label: {
                Image(systemName: "xmark")
                    .foregroundColor(.black)
                    .font(.title)
                    .padding(20)
            })
            .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .trailing)
            
            if walletModel.isLoading, portfolioModel.isLoading {
                ProgressView()
            } else {
                Text("Trade Apple Inc shares")
                    .font(.headline)
                
                Spacer()
                
                HStack{
                    TextField("0", text: stockCountString)
                        .keyboardType(.numberPad)
                        .onChange(of: stockCount, perform: { _ in
                            calcPrice()
                        })
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                    
                    Spacer()
                    Text("Share")
                        .font(.largeTitle)
                }
                .padding(.horizontal)
                
                Text(String(format: "x $%.2f/share = %.2f", stockDetailViewModel.stat.c, totalPrice))
                    .font(.headline)
                    .foregroundColor(.gray)
                    .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .trailing)
                    .padding()
                
                Spacer()
                
                Text(String(format: "$%.2f available to buy AAPL", walletModel.amount))
                    .font(.caption)
                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                    .foregroundColor(.gray)
            }
            
            
            
            HStack{
                Button {
                    
                } label: {
                    Text("Buy")
                        .frame(width: 150, height: 50)
                        .background(.green)
                        .cornerRadius(30)
                        .foregroundColor(.white)
                        .padding()
                }
                
                Button {
                    
                } label: {
                    Text("Sell")
                        .frame(width: 150, height: 50)
                        .background(.green)
                        .cornerRadius(30)
                        .foregroundColor(.white)
                        .padding()
                }
            }
        }
        .onAppear {
            Task {
                await portfolioModel.getPortfolio()
                await walletModel.getWallet()
            }
        }
    }
}
#Preview {
    TradeSheetView()
}

struct SuccessView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack{
            Color(.green).ignoresSafeArea()

            VStack{
                Spacer()

                Text("Congratulations!")
                    .font(.largeTitle)
                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                    .foregroundColor(.white)

                Text("You have successfully bought 3 shares of AAPL")
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding()

                Spacer()

                Button {
                    presentationMode.wrappedValue.dismiss()
                    } label: {
                        Text("Done")
                            .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, maxHeight: 50)
                            .background(.white)
                            .cornerRadius(30)
                            .foregroundColor(.green)
                            .padding()
                    }
            }
        }
    }
}
