//
//  RepoDetailsViewController.swift
//  gitHubSearch
//
//  Created by Zahidul Islam on 2022/08/30.
//

import UIKit

class RepoDetailsViewController: UIViewController {
    
    // Properties
    var url: URL?
    
    //  User Interface
    @IBOutlet private weak var repoPageWebView: UIWebView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //  View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.activityIndicator.hidesWhenStopped = true
        self.activityIndicator.isHidden = true
        guard let url = url else { return }
        self.repoPageWebView.loadRequest(URLRequest(url: url))
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(self.openInSafari))
    }
    
    // open defult browser 
    @objc func openInSafari() {
        guard let url = url else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}

extension RepoDetailsViewController: UIWebViewDelegate {
    func webViewDidStartLoad(_ webView: UIWebView) {
        activityIndicator.startAnimating()
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        activityIndicator.stopAnimating()
    }
}

