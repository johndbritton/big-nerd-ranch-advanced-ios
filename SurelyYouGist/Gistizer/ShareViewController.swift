//
//  ShareViewController.swift
//  Gistizer
//
//  Created by John Britton on 1/29/19.
//  Copyright © 2019 Big Nerd Ranch. All rights reserved.
//

import UIKit
import Social

class ShareViewController: SLComposeServiceViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let token = GithubKeychain.token()
        print("Did we get a token? \(token == nil ? "no" : "yes")")
        
        let defs = UserDefaults(suiteName: "group.com.johndbritton.SurelyYouGist")
        let username = defs?.string(forKey: "GithubUserNameDefaultsKey")
        print("Got username: \(username)")
        
    }
    
    override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext attachments here
        return true
    }

    override func didSelectPost() {
        guard let context = self.extensionContext,
            let items = context.inputItems as? [NSExtensionItem],
            let item = items.first,
            let string = item.attributedContentText else {
                self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
                return
        }
        
        let plainString = string.string
        
        let githubClient = GithubClient()
        githubClient.postGist(plainString, description: "hello extension!", isPublic: true) { _ in
            self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
        }
    }

    override func configurationItems() -> [Any]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        return []
    }

}
