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
            
            Text(convertTimestampToDate(timestamp: newsItem.datetime))
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
//                Button(action: {
//                    
//                }, label: {
//                    Text("here")
//                })
                if let url = URL(string: newsItem.url) {
                    Link("here", destination: url)
                }

            }
            .font(.footnote)
            .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
            
            HStack{
                Button {
                    shareOnTwitter(headline: newsItem.headline, url: newsItem.url)
                } label: {
                    Image("X")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 35, height: 35)
                }
                
                Button {
                    shareOnFacebook(url: newsItem.url)
                } label: {
                    Image("FB")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 35, height: 35)
                }
            }
            .font(.largeTitle)
            .padding(.vertical)
            .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
            
            
            Spacer()
        }
        .padding(.horizontal)
    }
    
    func convertTimestampToDate(timestamp: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: timestamp)
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long // month, day & year included
        dateFormatter.timeStyle = .none // time component not included
        dateFormatter.locale = Locale(identifier: "en_US") // ensuring English language date strings
        return dateFormatter.string(from: date)
    }
    
    func shareOnTwitter(headline: String, url: String) {
        let tweetText = "\(headline) \(url)"
        let tweetUrl = "https://twitter.com/intent/tweet?text=\(tweetText)"
        UIApplication.shared.open(URL(string: tweetUrl)!)
    }

    func shareOnFacebook(url: String) {
        let shareUrl = "https://www.facebook.com/sharer/sharer.php?u=\(url)"
        UIApplication.shared.open(URL(string: shareUrl)!)
    }
    
}

//#Preview {
//    NewsSheetView()
//}
