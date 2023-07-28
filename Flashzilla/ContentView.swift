//
//  ContentView.swift
//  Flashzilla
//
//  Created by Наталья Пелеш on 29.06.2023.
//

import SwiftUI

extension View{
    func stucked(at position: Int, in total: Int) -> some View{
        let offset = Double(total - position)
        return self.offset(x: 0, y: offset * 10)
    }
}

struct ContentView: View {
    
    @State private var cards = [Card]()
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor
    @Environment(\.accessibilityVoiceOverEnabled) var voiceOverEnabled
    
    @State private var showingEditScreen = false
    
    @State private var timeRemaining = 100
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @Environment(\.scenePhase) var scenePhase
    @State private var isActive = true
    
    @State private var offset = CGSize.zero
    
    var body: some View {
        ZStack{
            Image("background")
                .resizable()
                .ignoresSafeArea()
            
            VStack {
                Text("Time: \(timeRemaining)")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 5)
                    .background(.black.opacity(0.75))
                    .clipShape(Capsule())
                
                ZStack{
                    ForEach(0..<cards.count, id: \.self) { index in
//                        ForEach(cards, id: cards[index].id) { card in
                          
                            
                            CardView(card: cards[index]){
                                withAnimation{
                                    removeCard(at: index)
                                }
//                            }
                        }
                            .stucked(at: index, in: cards.count)
                            .allowsHitTesting(index == cards.count - 1)
                            .accessibilityHidden(index < cards.count - 1)
                    }
                }
                .allowsHitTesting(timeRemaining > 0)
                
                if cards.isEmpty{
                    Button("Start again", action: resetCards)
                        .padding()
                        .foregroundColor(.black)
                        .background(.white)
                        .clipShape(Capsule())
                }
            }
            
            VStack{
                HStack{
                    Spacer()
                    Button{
                        showingEditScreen = true
                    } label: {
                        Image (systemName: "plus.circle")
                            .padding()
                            .background(.black.opacity(0.7))
                            .clipShape(Circle())
                    }
                }
                Spacer()
            }
            .foregroundColor(.white)
            .font(.largeTitle)
            .padding()
            
            if differentiateWithoutColor || voiceOverEnabled {
                VStack{
                    Spacer()
                    
                    HStack{
                        Button{
                            withAnimation{
                                removeCard(at: cards.count - 1)
                            }
                        } label: {
                            Image(systemName: "xmark.circle")
                                .padding()
                                .background(.black.opacity(0.7))
                                .clipShape(Circle())
                        }
                        .accessibilityLabel("Wrong")
                        .accessibilityHint("Mark your answer as being incorrect")
                        
                        Spacer()
                        
                        Button{
                            withAnimation{
                                removeCard(at: cards.count - 1)
                            }
                        }label: {
                            Image(systemName: "checkmark.circle")
                                .padding()
                                .background(.black.opacity(0.7))
                                .clipShape(Circle())
                        }
                        .accessibilityLabel("Correct")
                        .accessibilityHint("Mark your answer as being correct")
                    
                    }
                    .foregroundColor(.white)
                    .font(.largeTitle)
                    .padding()
                }
            }
        }
        .onReceive(timer) { time in
            guard isActive else { return }
            
            if timeRemaining > 2{
                timeRemaining -= 1
            }
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active{
                if cards.isEmpty == false {
                    isActive = true
                }
            } else {
                isActive = false
            }
        }
        .sheet(isPresented: $showingEditScreen, onDismiss: resetCards, content: EditView.init )
        .onAppear(perform: resetCards)
    }
    func loadData(){
        if let data = UserDefaults.standard.data(forKey: "Cards"){
            if let decoded = try? JSONDecoder().decode([Card].self, from: data){
                cards = decoded
            }
        }
    }
    
    func reInsertCard(at index: Int){
        guard index >= 0 else { return }
        let wrongAnswerCard = cards.remove(at: index)
        cards.insert(wrongAnswerCard, at: cards.count - 1)
    }
    
    func removeCard(at index: Int){
        guard index >= 0 else { return }
        if offset.width < 0{
            let wrongAnswerCard = cards.remove(at: index)
            cards.insert(wrongAnswerCard, at: cards.count - 1)
            return
        }
        cards.remove(at: index)
        
        if cards.isEmpty{
            isActive = false
        }
    }
    
    func resetCards(){
        timeRemaining = 100
        isActive = true
        loadData()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
