//
//  StockDetailsView.swift
//  SwiftTrade
//
//  Created by Abhishek Kumar on 4/27/24.
//

import SwiftUI

struct StockDetailsView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @State var stockName: String = "Apple Inc"
    @State var stockPrice: Float = 172.57
    @State var changeInPrice: Float = 1.20
    @State var changeInPricePercent: Float = 0.70
    
    let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 6, alignment: nil),
        GridItem(.flexible(), spacing: 6, alignment: nil),
        GridItem(.flexible(), spacing: 6, alignment: nil)
    ]
        
    @State var showTradeSheet: Bool = false
    @State var showNewsSheet: Bool = false
    
    var body: some View {
            ScrollView (showsIndicators:false){
                // Name, Price and Change in Price
                NamePriceView(stockName: $stockName, stockPrice: $stockPrice, changeInPrice: $changeInPrice, changeInPricePercent: $changeInPricePercent)
                
                // Portfolio subview
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
                            // DO NOT ADD CONDITIONAL LOGIC HERE
                            TradeSheetView()
                        })
                        
                    }
                    .padding(.vertical)
                }
                    
                // Stats subview
                VStack{
                    Text("Stats")
                        .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                    
                    HStack{
                        VStack(alignment: .leading){
                            HStack{
                                Text("High Price:")
                                    .font(.headline)
                                Text("$172.89")
                                    .font(.subheadline)
                            }
                            HStack{
                                Text("Low Price:")
                                    .font(.headline)
                                Text("$172.89")
                                    .font(.subheadline)
                            }
                            
                        }
                        .frame(maxWidth:.infinity, alignment: .leading)
                        
                        
                        VStack(alignment: .leading){
                            HStack{
                                Text("Open Price:")
                                    .font(.headline)
                                Text("$172.89")
                                    .font(.subheadline)
                            }
                            HStack{
                                Text("Prev. Close:")
                                    .font(.headline)
                                Text("$172.89")
                                    .font(.subheadline)
                            }
                        }
                        .frame(maxWidth:.infinity, alignment: .leading)
                    }
                    .padding(.vertical, 5)
                }
                    
                // About subview
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
                            Text("1980-12-12")
                            Text("Technology")
                            Text("Https://www.apple.com")
                            ScrollView(.horizontal, showsIndicators:false, content:{
                                LazyHStack{
                                    ForEach(0..<10){ index in
                                        Text("Dell,".uppercased())
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
                
                // Insights subview
                VStack{
                    Text("Insights")
                        .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                    
                    // Highcharts comes here
                }
                    
                // News subview
                VStack{
                    LazyVStack{
                        Button(action: {
                            showNewsSheet.toggle()
                        }, label: {
                            VStack(alignment: .leading){
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.brown)
                                    .frame(height:200)
                                
                                
                                HStack{
                                    Text("Yahoo")
                                        .font(.caption)
                                        .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                                        .foregroundColor(.gray)
                                    Text("4 hr, 37 min")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                
                                Text("Apple held talks with china's baidu over AI for its devices".capitalized)
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
                        .sheet(isPresented: $showNewsSheet, content: {
                            // DO NOT ADD CONDITIONAL LOGIC HERE
                            NewsSheetScreen()
                        })
                        
                        
                        ForEach(0..<10){ index in
                            Button(action: {
                                showNewsSheet.toggle()
                            }, label: {
                                HStack(alignment:.top){
                                    VStack(alignment: .leading){
                                        HStack{
                                            Text("Yahoo")
                                                .font(.caption)
                                                .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                                                .foregroundColor(.gray)
                                            Text("4 hr, 37 min")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                        Text("Apple Antitrust Case is Surprisingly Simple".capitalized)
                                            .font(.headline)
                                            .foregroundColor(.black)
                                            .multilineTextAlignment(.leading)
                                    }
                                    Spacer()
                                    RoundedRectangle(cornerRadius:10)
                                        .fill(Color.purple)
                                        .frame(width: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, height: 100)
                                        
                                }
                                .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                            })
                            .sheet(isPresented: $showNewsSheet, content: {
                                // DO NOT ADD CONDITIONAL LOGIC HERE
                                NewsSheetScreen()
                            })
                        }
                    }
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
    }
}

struct TradeSheetView: View {
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
        
        
//        VStack{
//            Button(action: {
//                presentationMode.wrappedValue.dismiss()
//            }, label: {
//                Image(systemName: "xmark")
//                    .foregroundColor(.black)
//                    .font(.title)
//                    .padding(20)
//            })
//            .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .trailing)
//            
//            Text("Trade Apple Inc shares")
//                .font(.headline)
//            
//            Spacer()
//            
//            HStack{
//                Text("\(0)")
//                    .font(.largeTitle)
//                    .foregroundColor(.gray)
//                Spacer()
//                Text("Share")
//                    .font(.largeTitle)
//            }
//            .padding(.horizontal)
//            
//            Text(String(format: "x $%.2f/share = %.2f", 172.57, 0.00))
//                .font(.headline)
//                .foregroundColor(.gray)
//                .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .trailing)
//                .padding()
//
//            Spacer()
//            
//            Text("25000.00 available to buy AAPL")
//                .font(.caption)
//                .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
//                .foregroundColor(.gray)
//            
//            
//            HStack{
//                Button {
//                    
//                } label: {
//                    Text("Buy")
//                        .frame(width: 150, height: 50)
//                        .background(.green)
//                        .cornerRadius(30)
//                        .foregroundColor(.white)
//                        .padding()
//                }
//                
//                Button {
//                    
//                } label: {
//                    Text("Sell")
//                        .frame(width: 150, height: 50)
//                        .background(.green)
//                        .cornerRadius(30)
//                        .foregroundColor(.white)
//                        .padding()
//                }
//            }
//        }
    }
}

struct NewsSheetScreen: View {
    
    @Environment(\.presentationMode) var presentationMode
    
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
            
            Text("Yahoo")
                .font(.title)
                .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
            
            Text("March 22, 2024")
                .font(.headline)
                .foregroundColor(.gray)
                .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
            
            Rectangle()
                .fill(.gray)
                .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, maxHeight: 0.5 )
            
            Text("Microsoft deal, apple-google talks show tech giants need ai help".capitalized)
                .font(.headline)
                .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                
            Text("Mauris massa leo, sodales et sapien sed, tristique tempus diam. Curabitur ullamcorper viverra velit, quis euismod nibh aliquam nec. Donec interdum mauris mi, egestas commodo est congue porta. Suspendisse dignissim, lorem non dignissim lacinia, orci tellus tristique nulla, eu tempor metus nunc fermentum nulla. Curabitur vulputate a mi at tempus. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos.")
                .multilineTextAlignment(/*@START_MENU_TOKEN@*/.leading/*@END_MENU_TOKEN@*/)
            
            HStack{
                Text("For more details click")
                    .foregroundColor(.gray)
                Button(action: {
                    
                }, label: {
                    Text("here")
                })
            }
            .font(.footnote)
            .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
            
            HStack{
                Image(systemName: "paperplane.circle.fill")
                Image(systemName: "tray.circle.fill")
            }
            .font(.largeTitle)
            .padding(.vertical)
            .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
            
            
            Spacer()
        }
        .padding(.horizontal)
    }
}

#Preview {
        StockDetailsView()
//        NewsSheetScreen()
//    TradeSheetView()
}

struct NamePriceView: View {
    
    @Binding var stockName: String
    @Binding var stockPrice: Float
    @Binding var changeInPrice: Float
    @Binding var changeInPricePercent: Float
    
    var body: some View {
        VStack(alignment:.leading){
            Text(stockName)
                .font(.title2)
                .foregroundColor(.gray)
                .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
            //                        .background(Color.red)
            
            HStack(alignment: .center){
                Text(String(format: "$%.2f", stockPrice))
                    .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                
                Image(systemName: "arrow.up.forward")
                    .foregroundColor(.green)
                Text(String(format: "$%.2f (%.2f%%)", changeInPrice, changeInPricePercent))
                    .font(.title2)
                    .foregroundColor(.green)
                
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical)
            //                    .background(.red)
        }
    }
}
