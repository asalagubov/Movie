//
//  MovieService.swift
//  Movie
//
//  Created by Aleksandr Salagubov on 01.12.2024.
//


import Foundation

class MovieService {
    private let baseURL = "https://tv-api.com/en/API/Top250Movies/k_zcuw1ytf"

    func fetchMovies(completion: @escaping (Result<[Movie], Error>) -> Void) {
        guard let url = URL(string: baseURL) else {
            completion(.failure(URLError(.badURL)))
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(URLError(.badServerResponse)))
                return
            }

            do {
                let response = try JSONDecoder().decode(MovieResponse.self, from: data)
                completion(.success(response.items))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}

struct MovieResponse: Codable {
    let items: [Movie]
}
