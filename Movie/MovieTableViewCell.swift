//
//  MovieTableViewCell.swift
//  Movie
//
//  Created by Aleksandr Salagubov on 01.12.2024.
//


import UIKit

class MovieTableViewCell: UITableViewCell {
    private let movieImageView = UIImageView()
    private let descriptionLabel = UILabel()
    private let userRatingLabel = UILabel()
    private let rateButton = UIButton(type: .system)

    var onRate: (() -> Void)?

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

        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.font = .systemFont(ofSize: 14, weight: .regular)
        descriptionLabel.numberOfLines = 0

        userRatingLabel.translatesAutoresizingMaskIntoConstraints = false
        userRatingLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        userRatingLabel.textColor = .systemBlue

        rateButton.translatesAutoresizingMaskIntoConstraints = false
        rateButton.setTitle("Оценить", for: .normal)
        rateButton.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
        rateButton.layer.borderColor = UIColor.systemBlue.cgColor
        rateButton.layer.borderWidth = 1
        rateButton.layer.cornerRadius = 8
        rateButton.setTitleColor(.systemBlue, for: .normal)
        rateButton.addTarget(self, action: #selector(rateTapped), for: .touchUpInside)

        contentView.addSubview(movieImageView)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(userRatingLabel)
        contentView.addSubview(rateButton)

        NSLayoutConstraint.activate([
            movieImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            movieImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            movieImageView.widthAnchor.constraint(equalToConstant: 60),
            movieImageView.heightAnchor.constraint(equalToConstant: 90),

            descriptionLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            descriptionLabel.leadingAnchor.constraint(equalTo: movieImageView.trailingAnchor, constant: 10),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),

            userRatingLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 5),
            userRatingLabel.leadingAnchor.constraint(equalTo: movieImageView.trailingAnchor, constant: 10),
            userRatingLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),

            rateButton.topAnchor.constraint(equalTo: userRatingLabel.bottomAnchor, constant: 10),
            rateButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            rateButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            rateButton.widthAnchor.constraint(equalToConstant: 80),
            rateButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }

    func configure(with movie: LocalMovie) {
        descriptionLabel.text = movie.description
        userRatingLabel.text = movie.userRating != nil
            ? "Мой рейтинг: \(movie.userRating!)"
            : "Мой рейтинг: отсутствует"

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

    @objc private func rateTapped() {
        onRate?()
    }
}
