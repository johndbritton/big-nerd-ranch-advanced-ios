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
        // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
    
        // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
    }

    override func configurationItems() -> [Any]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        return []
    }

}
