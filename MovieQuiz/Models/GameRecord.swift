//
//  GameRecord.swift
//  MovieQuiz
//
//  Created by Aleksey Kosov on 28.12.2022.
//

import Foundation

struct GameRecord: Codable {
    
    let correct: Int
    let total: Int
    let date: Date
    
}

extension GameRecord: Comparable {
    
    static func < (lhs: GameRecord, rhs: GameRecord) -> Bool {
        if lhs.total == 0 {
            return true
        }
        let lhsRatio: Double = Double(lhs.correct) / Double(lhs.total)
        let rhsRatio: Double = Double(rhs.correct) / Double(rhs.total)
        
        return lhsRatio < rhsRatio
    }
}
