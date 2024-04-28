//
//  HomeScreen.swift
//  SwiftTrade
//
//  Created by Abhishek Kumar on 4/27/24.
//

import SwiftUI

struct HomeScreen: View {
    @State var fruits: [String] = [
        "apple", "orange", "banana", "peach"
    ]
    
    @State var veggies: [String] = [
        "tomato", "potato", "carrot"
    ]
    
    var body: some View {
        NavigationView{
            List{
                Section(
                    header: Text("Portfolio")
                ){
                    ForEach(fruits, id: \.self){ fruit in
                        Text(fruit.capitalized)
                            .font(.caption)
                    }
                    .onDelete(perform: delete)
                    .onMove(perform: { indices, newOffset in
                        fruits.move(fromOffsets: indices, toOffset: newOffset)
                    })
                }
            }
            .navigationTitle("Stocks")
            .navigationBarItems(trailing: EditButton())
        }
    }
    
    func delete(indexSet: IndexSet) {
        fruits.remove(atOffsets: indexSet)
    }
    
    func move(indices: IndexSet, newOffset: Int) {
        fruits.move(fromOffsets: indices, toOffset: newOffset)
    }
}

#Preview {
    HomeScreen()
}
