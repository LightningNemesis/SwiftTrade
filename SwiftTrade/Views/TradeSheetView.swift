//
//  TradeSheetView.swift
//  SwiftTrade
//
//  Created by Abhishek Kumar on 4/28/24.
//

import SwiftUI

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
#Preview {
    TradeSheetView()
}
