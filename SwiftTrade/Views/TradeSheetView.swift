//
//  TradeSheetView.swift
//  SwiftTrade
//
//  Created by Abhishek Kumar on 4/28/24.
//

import SwiftUI


struct PortfolioItem: Codable {
    let quantity: Int
    let avgCost: Float
    let change: Float
    let marketValue: Float
    let totalCost: Float
    let name: String
    let ticker: String
}

struct TradeSheetView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @EnvironmentObject var stockDetailViewModel: StockDetailViewModel
    @EnvironmentObject var portfolioModel: PortfolioViewModel
    @EnvironmentObject var walletViewModel: WalletViewModel
    
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
//        if totalPrice > walletModel.amount {
//            print("Can't buy more than your wallet")
//            return false
//        }
        return true
    }
    
    func tryBuy() async {
        
//        print("Existing portfolio:\n\(portfolioModel.portfolioModel)")
//        print("Ticker buying:\n\(stockDetailViewModel.stockOverview.ticker)")
        
        let purchaseCost = Float(stockCount) * stockDetailViewModel.stat.c;
        
        if let existingStockIndex = portfolioModel.portfolioModel.firstIndex(where: { $0.ticker ==  stockDetailViewModel.stockOverview.ticker}){
            print("existing stock:\n\(portfolioModel.portfolioModel[existingStockIndex])")
            
            let existingStock = portfolioModel.portfolioModel[existingStockIndex]
            let newQuantity = existingStock.quantity + stockCount
            let newAvgCost = (existingStock.totalCost + purchaseCost) / Float(newQuantity)
            let newTotalCost = existingStock.totalCost + purchaseCost
            let change = newAvgCost - stockDetailViewModel.stat.c
            let marketValue = Float(newQuantity) * stockDetailViewModel.stat.c
            
            let updatedStock = PortfolioItem(
                quantity: newQuantity,
                avgCost: newAvgCost,
                change: change,
                marketValue: marketValue,
                totalCost: newTotalCost,
                name: existingStock.name,
                ticker: existingStock.ticker
            )
            
            await portfolioModel.updateOrCreatePortfolio(item: updatedStock)
            
        } else {
            //print("existing stock not found")
            let avgCost = purchaseCost / Float(stockCount)
            let newStock = PortfolioItem(
                quantity: stockCount,
                avgCost: avgCost,
                change: avgCost - stockDetailViewModel.stat.c,
                marketValue: Float(stockCount) * stockDetailViewModel.stat.c,
                totalCost: purchaseCost,
                name: stockDetailViewModel.stockOverview.name,
                ticker: stockDetailViewModel.stockOverview.ticker
            )
            
            await portfolioModel.updateOrCreatePortfolio(item: newStock)
            
        }
        
        let newAmount = walletViewModel.amount - purchaseCost
        await walletViewModel.updateWallet(updatedAmount: newAmount)
    }
    
    func tryFailSell() -> Bool {
        // filter portfolio to find stock, 
        // if can't find it, can't sell it
        // if found, and stockCount > owned, can't sell
        return true
    }
    
    func trySell() async {
        //        print("Existing portfolio:\n\(portfolioModel.portfolioModel)")
        //        print("Ticker buying:\n\(stockDetailViewModel.stockOverview.ticker)")
        
        if let existingStockIndex = portfolioModel.portfolioModel.firstIndex(
            where: { $0.ticker ==  stockDetailViewModel.stockOverview.ticker}){
            
            let existingStock = portfolioModel.portfolioModel[existingStockIndex]
            let newQuantity = existingStock.quantity - stockCount
            
            if newQuantity < 0 {
                print("Selling more than you have")
                return
            }
            else if newQuantity == 0 {
                let updatedStock = PortfolioItem(
                    quantity: existingStock.quantity,
                    avgCost: existingStock.avgCost,
                    change: existingStock.change,
                    marketValue: existingStock.marketValue,
                    totalCost: existingStock.totalCost,
                    name: existingStock.name,
                    ticker: existingStock.ticker
                )
                
                await portfolioModel.deletePortfolio(item: updatedStock)
            } else {
                let newTotalCost = Float(newQuantity) * existingStock.avgCost
                let newMarketValue = Float(newQuantity) * stockDetailViewModel.stat.c
                let newChange = existingStock.avgCost - stockDetailViewModel.stat.c
                let newAvgCost = newTotalCost / Float(newQuantity)
                
                let updatedStock = PortfolioItem(
                    quantity: newQuantity,
                    avgCost: newAvgCost,
                    change: newChange,
                    marketValue: newMarketValue,
                    totalCost: newTotalCost, name: stockDetailViewModel.stockOverview.name,
                    ticker: stockDetailViewModel.stockOverview.ticker
                )
                
                await portfolioModel.updateOrCreatePortfolio(item: updatedStock)
            }
            
            let newAmount = walletViewModel.amount + Float(newQuantity) * stockDetailViewModel.stat.c
            await walletViewModel.updateWallet(updatedAmount: newAmount)
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
                
                Text(String(format: "$%.2f available to buy AAPL", walletViewModel.amount))
                    .font(.caption)
                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                    .foregroundColor(.gray)
            }
                        
            HStack{
                Button {
                    Task {
                        await tryBuy()
                    }
                } label: {
                    Text("Buy")
                        .frame(width: 150, height: 50)
                        .background(.green)
                        .cornerRadius(30)
                        .foregroundColor(.white)
                        .padding()
                }
                
                Button {
                    Task {
                      await trySell()
                    }
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
