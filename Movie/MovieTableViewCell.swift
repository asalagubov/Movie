//
//  MovieTableViewCell.swift
//  Movie
//
//  Created by Aleksandr Salagubov on 01.12.2024.
//


import UIKit

class MovieTableViewCell: UITableViewCell {
    private let movieImageView = UIImageView()
    private let titleLabel = UILabel()
    private let ratingLabel = UILabel()
    private let editButton = UIButton(type: .system)

    var onEdit: (() -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        movieImageView.translatesAutoresizingMaskIntoConstraints = false
        movieImageView.contentMode = .scaleAspectFit

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 16, weight: .bold)

        ratingLabel.translatesAutoresizingMaskIntoConstraints = false
        ratingLabel.font = .systemFont(ofSize: 14, weight: .regular)
        ratingLabel.textColor = .gray

        editButton.translatesAutoresizingMaskIntoConstraints = false
        editButton.setTitle("Edit", for: .normal)
        editButton.addTarget(self, action: #selector(editTapped), for: .touchUpInside)

        contentView.addSubview(movieImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(ratingLabel)
        contentView.addSubview(editButton)

        NSLayoutConstraint.activate([
            movieImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            movieImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            movieImageView.widthAnchor.constraint(equalToConstant: 60),
            movieImageView.heightAnchor.constraint(equalToConstant: 90),

            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: movieImageView.trailingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),

            ratingLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            ratingLabel.leadingAnchor.constraint(equalTo: movieImageView.trailingAnchor, constant: 10),
            ratingLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),

            editButton.topAnchor.constraint(equalTo: ratingLabel.bottomAnchor, constant: 10),
            editButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            editButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }

    func configure(with movie: LocalMovie) {
        titleLabel.text = movie.title
        ratingLabel.text = "Rating: \(movie.imDbRating)"
        
        if let url = URL(string: movie.image) {
            Task {
                if let data = try? await URLSession.shared.data(from: url).0 {
                    let image = UIImage(data: data)
                    DispatchQueue.main.async {
                        self.movieImageView.image = image
                    }
                }
            }
        }
    }

    @objc private func editTapped() {
        onEdit?()
    }
}
