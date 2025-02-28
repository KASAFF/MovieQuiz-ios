//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Aleksey Kosov on 28.12.2022.
//

import Foundation

final class StatisticServiceImplementation: StatisticService {
    
    private let userDefaults = UserDefaults.standard
    
    private enum Keys: String {
        case correct, total, bestGame, gamesCount
    }
    
    func store(correct count: Int, total amount: Int) {
        let newGame = GameRecord(correct: count, total: amount, date: Date())

        if bestGame < newGame {
            bestGame = newGame
        }
        if gamesCount != 0 { // если игра первая то totalAccuracy = точности в первой игре
            let totalAccurancyBetweenPreviousGames = Double(totalAccuracy) * Double(gamesCount)
            let newGameStats = Double(newGame.correct) / Double(newGame.total)
            totalAccuracy = (totalAccurancyBetweenPreviousGames + newGameStats) / Double(gamesCount + 1)
        } else {
            totalAccuracy = (Double(newGame.correct) / Double(newGame.total)) // если
        }
        gamesCount += 1
    }
    
    
    var totalAccuracy: Double {
        get {
            return userDefaults.double(forKey: Keys.total.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.total.rawValue)
        }
    }
    
    var gamesCount: Int {
        get {
            return userDefaults.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    var bestGame: GameRecord {
        get {
            guard let data = userDefaults.data(forKey: Keys.bestGame.rawValue),
                  let record = try? JSONDecoder().decode(GameRecord.self, from: data) else {
                return .init(correct: 0, total: 0, date: Date())
            }
            
            return record
        }
        
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранить результат")
                return
            }
            
            userDefaults.set(data, forKey: Keys.bestGame.rawValue)
        }
    }
}



