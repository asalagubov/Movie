//
//  LocalMovie.swift
//  Movie
//
//  Created by Aleksandr Salagubov on 01.12.2024.
//

import Foundation
import SwiftData

@Model
final class LocalMovie: Identifiable {
    @Attribute(.unique) var id: String
    var rank: String
    var title: String
    var fullTitle: String
    var year: String
    var image: String
    var imDbRating: String
    var imDbRatingCount: String
    var userRating: String?

    init(
        id: String,
        rank: String,
        title: String,
        fullTitle: String,
        year: String,
        image: String,
        imDbRating: String,
        imDbRatingCount: String,
        userRating: String? = nil
    ) {
        self.id = id
        self.rank = rank
        self.title = title
        self.fullTitle = fullTitle
        self.year = year
        self.image = image
        self.imDbRating = imDbRating
        self.imDbRatingCount = imDbRatingCount
        self.userRating = userRating
    }
}

extension LocalMovie {
    var description: String {
        return "\(title) (\(year)) \nОбщий рейтинг:\(imDbRating)⭐ \n(\(imDbRatingCount) кол-во голосов)"
    }

    static func from(movie: Movie) -> LocalMovie {
        return LocalMovie(
            id: movie.id,
            rank: movie.rank,
            title: movie.title,
            fullTitle: movie.fullTitle,
            year: movie.year,
            image: movie.image,
            imDbRating: movie.imDbRating,
            imDbRatingCount: movie.imDbRatingCount
        )
    }

    func toMovie() -> Movie {
        return Movie(
            id: id,
            rank: rank,
            title: title,
            fullTitle: fullTitle,
            year: year,
            image: image,
            imDbRating: imDbRating,
            imDbRatingCount: imDbRatingCount
        )
    }
}

extension LocalMovie {
    var resizedImageURL: URL? {
        let urlString = image
        let imageUrlString = urlString.components(separatedBy: "._")[0] + "._V0_UX600_.jpg"
        return URL(string: imageUrlString)
    }
}
