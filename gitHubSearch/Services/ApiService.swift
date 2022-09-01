//
//  ApiService.swift
//  gitHubSearch
//
//  Created by Zahidul Islam on 2022/08/30.
//


import Foundation

// github url
extension URL {
    static let searchRepoURLString: String = "https://api.github.com/search/repositories?"
    static let sortString: String = "&sort=stars&order=desc"
}

enum HTTPMethod: String {
    case GET
}

enum APIError: Error {
    case emptyBody
    case unexpectedResponseType
}

enum APIResult {
    case success(SearchResult)
    case failure(Error)
}

struct SearchResult: JSONDecodable {
    let items: [Repository]
    
    init(JSON: JSONObject) throws {
        self.items = try JSON.get("items")
    }
}

struct Repository: JSONDecodable {
    let htmlUrl: URL
    let fullName: String
    let language: String?
    let stargazersCount: Int
    
    init(JSON: JSONObject) throws {
        self.htmlUrl = try JSON.get("html_url")
        self.fullName = try JSON.get("full_name")
        self.language = try JSON.get("language")
        self.stargazersCount = try JSON.get("stargazers_count")
    }
}

protocol Endpoint {
    var url: URL { get }
    var method: HTTPMethod { get }
    var query: String { get }
}

extension Endpoint {
    fileprivate var urlRequest: URLRequest {
        var req = URLRequest(url: url)
        req.httpMethod = method.rawValue
        return req
    }
}

// end point
class SearchRepository: Endpoint {
    var url: URL
    var method: HTTPMethod
    var query: String
    
    init(query: String) {
        guard let url = URL(string: URL.searchRepoURLString + "q=\(query)" + URL.sortString) else { fatalError("Could not configure URL") }
        self.url = url
        self.method = .GET
        self.query = query
    }
    
    // result fatch from url
    func request(callback: @escaping (APIResult) -> Void) {
        URLSession.shared.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
            if let e = error {
                callback(.failure(e))
            } else if let data = data {
                do {
                    guard let dic = try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject] else {
                        throw APIError.unexpectedResponseType
                    }
                    let jsonObject = JSONObject(JSON: dic)
                    let response = try SearchResult(JSON: jsonObject)
                    callback(.success(response))
                } catch {
                    callback(.failure(error))
                }
            } else {
                callback(.failure(APIError.emptyBody))
            }
        }).resume()
    }
}


