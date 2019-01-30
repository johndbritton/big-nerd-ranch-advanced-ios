//
//  GithubClient.swift
//  SurelyYouGist
//
//  Created by Michael Ward on 7/22/14.
//  Copyright (c) 2014 Big Nerd Ranch. All rights reserved.
//

import UIKit

let GithubUserNameDefaultsKey = "GithubUserNameDefaultsKey"
let GithubAuthTokenDefaultsKey = "GithubAuthTokenDefaultsKey"
let SharedDefaultsSuiteName = "group.com.johndbritton.SurelyYouGist"

class GithubClient: NSObject {
    
    // MARK: - Vars and Lets
    
    let clientID = "e13289d60e71a4ba12b0"
    let clientSecret = "4e673b710f867c41eb89e29ecb74e5273b610e64"
    let clientRedirectURLString = "sygist://oauth/callback"
    
    // From documentation at https://developer.github.com/v3/oauth/
    struct GithubURLs {
        static let authorizeURL = URL(string: "https://github.com/login/oauth/authorize")!
        static let tokenURL = URL(string: "https://github.com/login/oauth/access_token")!
        static let apiBaseURL = URL(string: "https://api.github.com/")!
    }
    
    // Our own stuff

    var urlSession: URLSession = URLSession.shared
    var currentStateString: String = UUID().uuidString
    
    // Github Credentials
    var userID: String? {
        get {
            let defaultsSuite = UserDefaults(suiteName: SharedDefaultsSuiteName)
            return defaultsSuite?.string(forKey: GithubUserNameDefaultsKey)
        }
        set {
            let defaultsSuite = UserDefaults(suiteName: SharedDefaultsSuiteName)
            defaultsSuite?.set(newValue, forKey: GithubUserNameDefaultsKey)
            configureSession()
        }
    }
    
    var accessToken: String? {
        get {
            return GithubKeychain.token()
        }
        set {
            _ = GithubKeychain.storeToken(newValue)
            configureSession()
        }
    }
    
    override init() {
        super.init()
        configureSession()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
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
    
    func fetchDataWithRequest(_ request: URLRequest,
                    withCompletion completion: @escaping (GithubResult<Data>) -> Void ) {

        let task = urlSession.dataTask(with: request, completionHandler: {
            (data: Data?, response: URLResponse?, error: Error?) in

            guard let data = data, let response = response as? HTTPURLResponse else {
                completion(.failure(GithubError.connectionError(error!.localizedDescription)))
                return
            }
            
            switch response.statusCode {
            case 200:
                completion(.success(data))
            case 401:
                completion(.failure(GithubError.authenticationError))
            default:
                completion(.failure(GithubError.unknownHTTPError(response.statusCode)))
            }
            
            print("Received status code \(response.statusCode) and \(data.count) bytes of data from \(String(describing: request.url))")
        })
        
        task.resume()
    }
    
    // MARK: - Task and Session Management
    
    func configureSession() {
        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = [
            "Accept" : "application/json"
        ]
        if let token = accessToken {
            config.httpAdditionalHeaders!["Authorization"] = "Bearer \(token)"
        }
        urlSession = URLSession(configuration: config)
    }
}
