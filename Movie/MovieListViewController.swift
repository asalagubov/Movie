//
//  MovieListViewController.swift
//  Movie
//
//  Created by Aleksandr Salagubov on 01.12.2024.
//


import UIKit
import SwiftData

@MainActor
class MovieListViewController: UIViewController {
    let tableView = UITableView()
    let movieService = MovieService()
    var movies: [LocalMovie] = []
    let modelContext = PersistenceController.shared.mainContext
    
    var presentAlert: ((UIAlertController) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadMoviesFromCache()
        loadMoviesFromStorage()
        fetchMovies()
    }
    
    private func setupUI() {
        title = "Top Movies"
        view.backgroundColor = .white

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(MovieTableViewCell.self, forCellReuseIdentifier: "MovieCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.estimatedRowHeight = 120
        tableView.rowHeight = UITableView.automaticDimension

        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func fetchMovies() {
        movieService.fetchMovies { [weak self] result in
            Task {
                switch result {
                case .success(let fetchedMovies):
                    self?.saveMoviesToStorage(fetchedMovies)
                    self?.loadMoviesFromStorage()
                case .failure(let error):
                    print("Failed to fetch movies:", error)
                }
            }
        }
    }
    
    private func saveMoviesToStorage(_ fetchedMovies: [Movie]) {
        for movie in fetchedMovies {
            let localMovie = LocalMovie.from(movie: movie)
            modelContext.insert(localMovie)
        }
        
        do {
            try modelContext.save()
        } catch {
            print("Failed to save movies to storage: \(error)")
        }
    }
    
    private func loadMoviesFromStorage() {
        do {
            movies = try modelContext.fetch(FetchDescriptor<LocalMovie>())
            tableView.reloadData()
        } catch {
            print("Failed to load movies from storage: \(error)")
        }
    }
    
    private func loadImage(from url: String, completion: @escaping (UIImage?) -> Void) {

        guard let imageURL = URL(string: url) else {
            completion(nil)
            return
        }

        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: imageURL)
                if let image = UIImage(data: data) {
                    completion(image)
                } else {
                    completion(nil)
                }
            } catch {
                completion(nil)
            }
        }
    }

    func updateMovieRating(_ movie: LocalMovie, rating: String) {
        movie.userRating = rating
        
        do {
            try modelContext.save()
            saveMoviesToCache() 
            if let index = movies.firstIndex(where: { $0.id == movie.id }) {
                reloadRow(at: index)
            }
        } catch {
            print("Ошибка сохранения пользовательского рейтинга: \(error)")
        }
    }
    
    private func reloadRow(at index: Int) {
        let indexPath = IndexPath(row: index, section: 0)
        tableView.reloadRows(at: [indexPath], with: .none)
    }
    
    func deleteMovie(_ movie: LocalMovie) {
            modelContext.delete(movie)
            
            do {
                try modelContext.save()
                if let index = movies.firstIndex(where: { $0.id == movie.id }) {
                    movies.remove(at: index)
                    tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                }
            } catch {
                print("Ошибка удаления фильма: \(error)")
            }
        }
}

extension MovieListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as? MovieTableViewCell else {
            return UITableViewCell()
        }
        
        let movie = movies[indexPath.row]
        cell.configure(with: movie)
        cell.onRate = { [weak self] in
            self?.showEditDialog(for: movie)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteMovie(movies[indexPath.row])
        }
    }
}

extension MovieListViewController {
    private func showEditDialog(for movie: LocalMovie) {
        let alertController = UIAlertController(
            title: "Оцените фильм",
            message: "Введите вашу оценку (1-10)",
            preferredStyle: .alert
        )
        
        alertController.addTextField { textField in
            textField.placeholder = "Рейтинг (1-10)"
            textField.keyboardType = .decimalPad
            textField.text = movie.userRating
        }
        
        let saveAction = UIAlertAction(title: "Сохранить", style: .default) { _ in
            if let ratingText = alertController.textFields?.first?.text, !ratingText.isEmpty {
                if let rating = Int(ratingText), rating >= 1, rating <= 10 {
                    self.updateMovieRating(movie, rating: ratingText)
                } else {
                    let errorAlert = UIAlertController(
                        title: "Ошибка",
                        message: "Пожалуйста, введите число от 1 до 10.",
                        preferredStyle: .alert
                    )
                    errorAlert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(errorAlert, animated: true)
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }
}

extension MovieListViewController {
    private func saveMoviesToCache() {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(movies.map { $0.toMovie() }) {
            UserDefaults.standard.set(data, forKey: "cachedMovies")
        }
    }
    
    private func loadMoviesFromCache() {
        if let data = UserDefaults.standard.data(forKey: "cachedMovies") {
            let decoder = JSONDecoder()
            if let cachedMovies = try? decoder.decode([Movie].self, from: data) {
                movies = cachedMovies.map { LocalMovie.from(movie: $0) }
            }
        }
    }
}
