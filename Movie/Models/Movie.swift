//
//  Movie.swift
//  Movie
//
//  Created by Aleksandr Salagubov on 01.12.2024.
//


import Foundation

struct Movie: Identifiable, Codable {
    let id: String
    let rank: String
    let title: String
    let fullTitle: String
    let year: String
    let image: String
    let imDbRating: String
    let imDbRatingCount: String
}
