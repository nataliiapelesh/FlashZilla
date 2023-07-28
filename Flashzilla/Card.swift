//
//  Card.swift
//  Flashzilla
//
//  Created by Наталья Пелеш on 01.07.2023.
//

import Foundation

struct Card: Codable, Identifiable {
    
    let prompt: String
    let answer: String
    var id = UUID()
    
    static let example = Card(prompt: "What is the name of Belly's bear in The Summer I turned preatty?", answer: "Mint junior")
    
}
