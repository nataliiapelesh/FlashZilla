//
//  EditView.swift
//  Flashzilla
//
//  Created by Наталья Пелеш on 05.07.2023.
//

import SwiftUI

struct EditView: View {
    @Environment(\.dismiss) var dismiss
    @State private var cards = [Card]()
    @State private var newPrompt = ""
    @State private var newAnswer = ""
    
    var body: some View {
        NavigationView {
            List{
                Section{
                    TextField("Prompt", text: $newPrompt)
                    TextField("Answer", text: $newAnswer)
                    Button("Add", action: addNewCard)
                }
                
                Section{
                    ForEach(0..<cards.count, id: \.self) { index in
                        VStack(alignment: .leading){
                            Text(cards[index].prompt)
                                .font(.headline)
                            Text(cards[index].answer)
                                .foregroundColor(.secondary)
                        }
                    }
                    .onDelete(perform: removeCard)
                    
                }
            }
            .navigationTitle("Edit Card")
            .toolbar {
                Button("Done", action: done)
            }
            .listStyle(.grouped)
            .onAppear(perform: loadData)
            
        }
        
    }
    func saveData(){
        if let data = try? JSONEncoder().encode(cards){
            UserDefaults.standard.set(data, forKey: "Cards")
        }
    }
    
    func addNewCard(){
        let trimmedPrompt = newPrompt.trimmingCharacters(in: .whitespaces)
        let trimmedAnswer = newAnswer.trimmingCharacters(in: .whitespaces)
        guard trimmedAnswer.isEmpty == false && trimmedPrompt.isEmpty == false else { return }
        let card = Card(prompt: trimmedPrompt, answer: trimmedAnswer)
        cards.insert(card, at: 0)
        saveData()
        newAnswer = ""
        newPrompt = ""
    }
    
    func removeCard(at offsets: IndexSet){
        cards.remove(atOffsets: offsets)
        saveData()
    }
    
    func done(){
        dismiss()
    }
    
    func loadData(){
        if let data = UserDefaults.standard.data(forKey: "Cards"){
            if let decoded = try? JSONDecoder().decode([Card].self, from: data){
                cards = decoded
            }
        }
    }
}

struct EditView_Previews: PreviewProvider {
    static var previews: some View {
        EditView()
    }
}
