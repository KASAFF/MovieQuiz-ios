//
//  NetworkClient.swift
//  MovieQuiz
//
//  Created by Aleksey Kosov on 12.01.2023.
//

import Foundation

protocol NetworkRouting {
    func fetch(url: URL, handler: @escaping (Result<Data, Error>) -> Void)
}

struct NetworkClient: NetworkRouting {

    func fetch(url: URL, handler: @escaping (Result<Data, Error>) -> Void) {
        let request = URLRequest(url: url)

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Проверяем, пришла ли ошибка
            if let _ = error {
                handler(.failure(YPError.codeError))
                return
            }

            // Проверяем, что нам пришёл успешный код ответа
            if let response = response as? HTTPURLResponse,
                response.statusCode < 200 || response.statusCode >= 300 {
                handler(.failure(YPError.codeError))
                return
            }

            // Возвращаем данные
            guard let data = data else { return }
            handler(.success(data))
        }

        task.resume()
    }
}
