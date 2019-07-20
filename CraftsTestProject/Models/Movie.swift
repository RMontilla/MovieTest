//
//  Movie.swift
//  CraftsTestProject
//
//  Created by Rafael Montilla on 7/18/19.
//  Copyright © 2019 RMontilla. All rights reserved.
//

import Foundation
import RealmSwift

public struct MoviesResponse: Codable {
    public let page: Int
    public let totalResults: Int
    public let totalPages: Int
    public let results: [Movie]
}

public class Movie: Object, Codable {
    @objc dynamic var id: Int
    @objc dynamic var title: String?
    @objc dynamic var originalTitle: String?
    @objc dynamic var popularity: Double
    @objc dynamic var backdropPath: String?
    @objc dynamic var posterPath: String?
    @objc dynamic var overview: String
    @objc dynamic var releaseDate: Date?
    @objc dynamic var voteAverage: Double
    @objc dynamic var voteCount: Int
    public var posterURL: URL {
        return URL(string: "https://image.tmdb.org/t/p/w500\(posterPath ?? "")")!
    }
    public var backdropURL: URL {
        return URL(string: "https://image.tmdb.org/t/p/original\(backdropPath ?? "")")!
    }

    override public class func primaryKey() -> String? {
        return "id"
    }

    // MARK: - Realm methods
    @discardableResult public func isMovieLiked() -> Bool {
        do {
            let realm = try Realm()
            let movieArray = realm.objects(Movie.self).filter { $0.id == self.id}
            return movieArray.count > 0
        } catch _ {
            return false
        }
    }

    @discardableResult public func delete() -> Bool {
        do {
            let realm = try Realm()
            realm.delete(self)
            return true
        } catch _ {
            return false
        }
    }

    @discardableResult public func save() -> Bool {
        do {
            let realm = try Realm()
            try realm.write {
                realm.add(self)
            }
            return true
        } catch _ {
            return false
        }
    }
}
