//
//  GithubClient.swift
//  SurelyYouGist
//
//  Created by Michael Ward on 7/22/14.
//  Copyright (c) 2014 Big Nerd Ranch. All rights reserved.
//

import UIKit

let GithubUserNameDefaultsKey = "GithubUserNameDefaultsKey"

class GithubClient: NSObject {
    
    // MARK: - Vars and Lets
    
    // From documentation at https://developer.github.com/v3/oauth/
    fileprivate struct GithubURLs {
        static let authorizeURL = URL(string: "https://github.com/login/oauth/authorize")!
        static let tokenURL = URL(string: "https://github.com/login/oauth/access_token")!
        static let apiBaseURL = URL(string: "https://api.github.com/")!
    }
    
    // Our own stuff

    fileprivate var urlSession: URLSession = URLSession.shared
    
    // Github Credentials
    var userID: String? {
        get {
            let defaults = UserDefaults.standard
            return defaults.string(forKey: GithubUserNameDefaultsKey)
        }
        set {
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: GithubUserNameDefaultsKey)
        }
    }
    
    override init() {
        super.init()
        configureSession()
    }
    
    // MARK: - Public Requests

    func fetchGistsWithCompletion(_ completion: @escaping (GithubResult<[GithubGist]>) -> Void ) {
        
        guard let username = self.userID else {
            completion(.failure(GithubError.usernameError))
            return
        }
        
        let url = GithubURLs.apiBaseURL.appendingPathComponent("users/\(username)/gists")
        let request = URLRequest(url: url)
        fetchDataWithRequest(request) { result in
            switch result {
            case .success(let data):
                do {
                    let gists = try GithubImporter.gistsFromData(data)
                    completion(.success(gists))
                } catch (let parseError) {
                    completion(.failure(parseError as! GithubError))
                }
            case .failure(let fetchError):
                completion(.failure(fetchError))
            }
        }
    }
    
    func fetchStringAtURL(_ url: URL, withCompletion completion: @escaping (GithubResult<String>) -> Void ) {
        let request = URLRequest(url: url)
        fetchDataWithRequest(request) { result in
            switch result {
            case .success(let data):
                do {
                    let string = try GithubImporter.stringFromData(data)
                    completion(.success(string))
                } catch (let parseError) {
                    completion(.failure(parseError as! GithubError))
                }
            case .failure(let fetchError):
                completion(.failure(fetchError))
            }
        }
    }
    
    func postGist(_ gist: String,
                  description: String,
                  isPublic: Bool,
                  withCompletion completion: @escaping (GithubResult<String>) -> Void) {
        
        let newGist = [
            "description": description,
            "public": isPublic,
            "files": [ "gist.txt" : [ "content" : gist ] ]
            ] as [String : Any]
        
        let newGistJSON = try! JSONSerialization.data(withJSONObject: newGist,
                                                      options: .prettyPrinted)
        
        let url = GithubURLs.apiBaseURL.appendingPathComponent("gists")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = newGistJSON
        
        fetchDataWithRequest(request as URLRequest) { result in
            switch result {
            case .success(let data):
                do {
                    let string = try GithubImporter.stringFromData(data)
                    completion(.success(string))
                } catch (let parseError) {
                    completion(.failure(parseError as! GithubError))
                }
            case .failure(let fetchError):
                completion(.failure(fetchError))
            }
        }
    }

    // MARK: - Funnel fetcher (all the other fetchers route through here)
    
    fileprivate func fetchDataWithRequest(_ request: URLRequest,
                    withCompletion completion: @escaping (GithubResult<Data>) -> Void ) {

        let task = urlSession.dataTask(with: request, completionHandler: {
            (data: Data?, response: URLResponse?, error: Error?) in

            guard let data = data, let response = response as? HTTPURLResponse else {
                completion(.failure(GithubError.connectionError(error!.localizedDescription)))
                return
            }
            
            print("Received status code \(response.statusCode) and \(data.count) bytes of data from \(String(describing: request.url))")
            completion(.success(data))
        })
        
        task.resume()
    }
    
    // MARK: - Task and Session Management
    
    fileprivate func configureSession() {
        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = [
            "Accept" : "application/json"
        ]
        urlSession = URLSession(configuration: config)
    }

}
