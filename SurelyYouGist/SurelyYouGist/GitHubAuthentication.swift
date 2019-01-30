//
//  GitHubAuthentication.swift
//  SurelyYouGist
//
//  Created by John Britton on 1/29/19.
//  Copyright © 2019 Big Nerd Ranch. All rights reserved.
//

import UIKit

extension GithubClient {
    func beginAuthorizationByFetchingGrant() {
        currentStateString = UUID().uuidString
        
        var urlComponents = URLComponents(url: GithubURLs.authorizeURL, resolvingAgainstBaseURL: true)!
        
        let queryItems = [
            URLQueryItem(name: "client_id", value: clientID),
            URLQueryItem(name: "redirect_uri", value: clientRedirectURLString),
            URLQueryItem(name: "state", value: currentStateString),
            URLQueryItem(name: "scope", value: "gist")
        ]
        
        urlComponents.queryItems = queryItems
        
        if let url = urlComponents.url {
            UIApplication.shared.open(url)
        }
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(GithubClient.observeSygistDidOpenURLNotification(_:)),
                                               name: .SygistDidReceiveURLNotification,
                                               object: nil)
    }
    
    @objc func observeSygistDidOpenURLNotification(_ note: Notification) {
        NotificationCenter.default.removeObserver(self,
                                                  name: .SygistDidReceiveURLNotification,
                                                  object: nil)
        
        guard let url = (note as NSNotification).userInfo?[SygistOpenURLInfoKey] as? URL,
            let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: true)?.queryItems,
            url.host == "oauth" && url.path == "/callback" else {
                
                print("SygistDidReceiveURLNotification had invalid or non-URL SygistOpenURLInfoKey")
                return
        }
        
        for queryItem in queryItems where queryItem.name == "code" {
            let grantCode = queryItem.value!
            fetchTokenUsingGrant(grantCode)
        }
    }
    
    func fetchTokenUsingGrant(_ grantCode:String) {
        
        let bodyDict = [
            "client_id": clientID,
            "client_secret": clientSecret,
            "code": grantCode,
            "redirect_uri": clientRedirectURLString
        ]
        
        let url = GithubURLs.tokenURL
        var request = URLRequest(url: url)
        let bodyData = try! JSONSerialization.data(withJSONObject: bodyDict, options: [])
        request.httpMethod = "POST"
        request.httpBody = bodyData
        request.setValue(nil, forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        fetchDataWithRequest(request) { (result) in
            switch result {
            case .success(let data):
                do {
                    let token = try GithubImporter.tokenFromData(data)
                    self.accessToken = token
                    print("Fetched access token \(token)")
                } catch(let parseError) {
                    print("Error: Can't parse token data: \(parseError)")
                }
            case .failure(let error):
                print("Error: No token data: \(error)")
            }
        }
    }
}
