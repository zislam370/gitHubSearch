//
//  ViewModel.swift
//  gitHubSearch
//
//  Created by Zahidul Islam on 2022/08/30.
//

import UIKit

class SearchViewModel {
    func showMessage(title: String, msg: String, `on` controller: UIViewController) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: AppConstants.okButtonTitle, style: UIAlertAction.Style.default, handler: nil))
        controller.present(alert, animated: true, completion: nil)
    }
}
