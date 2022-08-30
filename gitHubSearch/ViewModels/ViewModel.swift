//
//  ViewModel.swift
//  gitHubSearch
//
//  Created by Zahidul Islam on 2022/08/30.
//

import Foundation
import UIKit

class ViewModel{
    
    
    func showMessage(title: String, msg: String, `on` controller: UIViewController) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        controller.present(alert, animated: true, completion: nil)
        }
    
}
