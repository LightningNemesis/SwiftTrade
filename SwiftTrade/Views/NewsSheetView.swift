//
//  NewsSheetView.swift
//  SwiftTrade
//
//  Created by Abhishek Kumar on 4/28/24.
//

import SwiftUI

struct NewsSheetView: View {
    
    let newsItem: StockNewsModel
    
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
            
            Text(newsItem.source)
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
            
            Text(newsItem.headline.capitalized)
                .font(.headline)
                .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                
            Text(newsItem.summary)
                .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
            
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

//#Preview {
//    NewsSheetView()
//}
