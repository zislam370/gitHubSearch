//
//  SearchViewController.swift
//  gitHubSearch
//
//  Created by Zahidul Islam on 2022/08/30.
//

import UIKit

class SearchViewController: UIViewController {

    // - Properties

    fileprivate var repositories: [Repository] = [] {
        didSet {
            self.repoTableView.reloadData()
        }
    }
    var timer: Timer?

    // - User Interface

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet private weak var repoTableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    // - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        self.activityIndicator.hidesWhenStopped = true
        self.activityIndicator.isHidden = true
    }
}


// for tableview data source

extension SearchViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.repositories.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        cell.textLabel?.text = repositories[indexPath.row].fullName
        if let language = repositories[indexPath.row].language {
            cell.detailTextLabel?.text = language
        }
        let starLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 22, height: 22))
        starLabel.text = "★\(self.repositories[indexPath.row].stargazersCount)"
        starLabel.textAlignment = .left
        starLabel.sizeToFit()
        cell.accessoryView = starLabel
        return cell
    }
}

extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let sb = self.storyboard else { return }
        let vc = sb.instantiateViewController(withIdentifier: "RepoDetailsViewController") as! RepoDetailsViewController
        vc.url = repositories[indexPath.row].htmlUrl
        vc.title = repositories[indexPath.row].fullName
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

// search view data source
extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.search), userInfo: nil, repeats: false)
    }

    // search function
    @objc func search() {
        self.repositories.removeAll()
        guard let query = self.searchBar.text else { return }
        if query == "" { return }
        self.activityIndicator.startAnimating()
        SearchRepository(query: query).request { (result) in
            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    self.repositories.append(contentsOf: response.items)
                    self.activityIndicator.stopAnimating()
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}
