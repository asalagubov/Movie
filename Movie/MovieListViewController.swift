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
    private let tableView = UITableView()
    private let movieService = MovieService()
    private var movies: [LocalMovie] = []
    private let modelContext = PersistenceController.shared.mainContext

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
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

        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Refresh",
            style: .plain,
            target: self,
            action: #selector(refreshMovies)
        )
    }

    @objc private func refreshMovies() {
        fetchMovies()
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

    private func deleteMovie(_ movie: LocalMovie) {
        modelContext.delete(movie)

        do {
            try modelContext.save()
            loadMoviesFromStorage()
        } catch {
            print("Failed to delete movie: \(error)")
        }
    }

    private func updateMovie(_ movie: LocalMovie, title: String) {
        movie.title = title

        do {
            try modelContext.save()
            loadMoviesFromStorage()
        } catch {
            print("Failed to update movie: \(error)")
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
        cell.onEdit = { [weak self] in
            let newTitle = "\(movie.title) - Edited"
            self?.updateMovie(movie, title: newTitle)
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
        let alertController = UIAlertController(title: "Edit Movie", message: "Update the movie details", preferredStyle: .alert)

        alertController.addTextField { textField in
            textField.placeholder = "Rating"
            textField.keyboardType = .decimalPad
            textField.text = movie.imDbRating
        }

        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            if let rating = alertController.textFields?.first?.text {
                self.updateMovie(movie, rating: rating)
            }
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)

        present(alertController, animated: true)
    }

    private func updateMovie(_ movie: LocalMovie, rating: String) {
        movie.imDbRating = rating

        do {
            try modelContext.save()
            loadMoviesFromStorage()
        } catch {
            print("Failed to update movie: \(error)")
        }
    }
}
