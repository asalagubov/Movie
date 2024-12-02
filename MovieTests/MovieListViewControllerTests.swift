//
//  MovieListViewControllerTests.swift
//  Movie
//
//  Created by Aleksandr Salagubov on 02.12.2024.
//


import XCTest
@testable import Movie

@MainActor
final class MovieListViewControllerTests: XCTestCase {
    var sut: MovieListViewController!
    var navigationController: UINavigationController!

    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = MovieListViewController()
        navigationController = UINavigationController(rootViewController: sut)
        _ = sut.view 
    }

    override func tearDownWithError() throws {
        sut = nil
        navigationController = nil
        try super.tearDownWithError()
    }

    func testViewDidLoad_setsTitleAndBackgroundColor() async {
        XCTAssertEqual(sut.title, "Top Movies")
        XCTAssertEqual(sut.view.backgroundColor, .white)
    }

    func testTableViewSetup_isCorrect() async {
        XCTAssertNotNil(sut.tableView.delegate)
        XCTAssertNotNil(sut.tableView.dataSource)
        XCTAssertEqual(sut.tableView.rowHeight, UITableView.automaticDimension)
        XCTAssertEqual(sut.tableView.estimatedRowHeight, 120)
    }

    func testNumberOfRowsInSection_matchesMoviesCount() async {
        sut.movies = [LocalMovie.mock(), LocalMovie.mock()]
        XCTAssertEqual(sut.tableView(sut.tableView, numberOfRowsInSection: 0), 2)
    }

    func testCellForRowAtIndexPath_configuresCellCorrectly() async {
        let movie = LocalMovie.mock(userRating: "8")
        sut.movies = [movie]
        sut.tableView.reloadData()

        let cell = sut.tableView(sut.tableView, cellForRowAt: IndexPath(row: 0, section: 0)) as? MovieTableViewCell

        XCTAssertNotNil(cell)
        XCTAssertEqual(cell?.descriptionLabel.text, movie.description)
        XCTAssertEqual(cell?.userRatingLabel.text, "Мой рейтинг: 8")
    }

    func testDeleteMovie_removesMovieFromList() async {
        let movie1 = LocalMovie.mock(id: UUID().uuidString, userRating: "7")
        let movie2 = LocalMovie.mock(id: UUID().uuidString, userRating: "9")
        sut.movies = [movie1, movie2]
        sut.tableView.reloadData()

        sut.deleteMovie(movie1)

        XCTAssertEqual(sut.movies.count, 1)
        XCTAssertFalse(sut.movies.contains(where: { $0.id == movie1.id }))
    }
}

// MARK: - Mock Data
extension LocalMovie {
    static func mock(
        id: String = UUID().uuidString,
        rank: String = "1",
        title: String = "Mock Title",
        fullTitle: String = "Mock Full Title",
        year: String = "2024",
        image: String = "https://example.com/mock.jpg",
        imDbRating: String = "9.5",
        imDbRatingCount: String = "10000",
        userRating: String? = nil
    ) -> LocalMovie {
        return LocalMovie(
            id: id,
            rank: rank,
            title: title,
            fullTitle: fullTitle,
            year: year,
            image: image,
            imDbRating: imDbRating,
            imDbRatingCount: imDbRatingCount,
            userRating: userRating
        )
    }
}
