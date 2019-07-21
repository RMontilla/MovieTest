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

public struct Movie: Codable {
    var id: Int
    var title: String?
    var originalTitle: String?
    var popularity: Double
    var backdropPath: String?
    var posterPath: String?
    var overview: String
    var releaseDate: Date?
    var voteAverage: Double
    var voteCount: Int
    public var posterURL: URL {
        return URL(string: Constants.URL.posterURL + (posterPath ?? ""))!
    }
    public var backdropURL: URL {
        return URL(string: Constants.URL.backdropURL + (backdropPath ?? ""))!
    }

    // MARK: - Realm methods
    @discardableResult public func isMovieLiked() -> Bool {
        do {
            let realm = try Realm()
            let movieArray = realm.objects(MovieObject.self).filter("id == \(self.id)")
            return movieArray.count > 0
        } catch _ {
            return false
        }
    }

    @discardableResult public func save() -> Bool {
        do {
            let realm = try Realm()
            try realm.write {
                realm.create(MovieObject.self, value: [self.id, self.title ?? ""])
            }
            return true
        } catch _ {
            return false
        }
    }

    @discardableResult public func delete() -> Bool {
        do {
            let realm = try Realm()
            let objects = realm.objects(MovieObject.self).filter("id == \(self.id)")
            if objects.count > 0 {
                try realm.write {
                    let movieObject = objects[0]
                    realm.delete(movieObject)
                }
            }
            return true
        } catch _ {
            return false
        }
    }
}
