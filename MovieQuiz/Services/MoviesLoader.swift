//
//  MoviesLoader.swift
//  MovieQuiz
//
//  Created by Aleksey Kosov on 12.01.2023.
//

import Foundation

protocol MoviesLoading {
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void)
}

struct MoviesLoader: MoviesLoading {

    private let networkClient = NetworkClient()

    private let apiKey = "k_yvmven88" //"k_r0j8eqer"

    private var mostPopularMoviesUrl: URL {
        guard let endpoint = URL(string: "https://imdb-api.com/en/API/Top250Movies/\(apiKey)") else {
            preconditionFailure("Unable to construct mostPopularMoviesUrl")
        }
        return endpoint
    }

    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void) {
        networkClient.fetch(url: mostPopularMoviesUrl) { result in
            switch result {
            case .success(let data):
                do {
                    let mostPopularMovies = try JSONDecoder().decode(MostPopularMovies.self, from: data)
                    guard mostPopularMovies.errorMessage == "" else {
                        handler(.failure(YPError.errorInvalidResponse))
                        return
                    }

                    handler(.success(mostPopularMovies))
                } catch let decodingErr {
                    handler(.failure(decodingErr))
                }
            case .failure(let error):
                handler(.failure(error))
            }
        }
    }
}
