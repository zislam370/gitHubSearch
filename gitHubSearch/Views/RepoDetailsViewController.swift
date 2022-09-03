//
//  RepoDetailsViewController.swift
//  gitHubSearch
//
//  Created by Zahidul Islam on 2022/08/30.
//

import UIKit
import WebKit

class RepoDetailsViewController: UIViewController {
    // Properties
    var url: URL?
    var viewModel = SearchViewModel()
    //  User Interface
    @IBOutlet var repoPageWebView: WKWebView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    //  View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.activityIndicator.hidesWhenStopped = true
        self.activityIndicator.isHidden = true
        guard let url = url else { return }
        repoPageWebView.navigationDelegate = self
        repoPageWebView.isUserInteractionEnabled = true
        self.repoPageWebView.load(URLRequest(url: url))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(self.openInSafari))
    }
    // Open defult browser 
    @objc func openInSafari() {
        guard let url = url else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}

extension RepoDetailsViewController: WKNavigationDelegate {
 func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
     activityIndicator.startAnimating()
}

 func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
     activityIndicator.stopAnimating()
}

 func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
     viewModel.showMessage(title: AppConstants.errorTitle, msg: AppConstants.errorMessage, on: self)
}
}
