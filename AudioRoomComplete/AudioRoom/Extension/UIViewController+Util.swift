//
//  UIViewController+Util.swift
//  AudioRoom
//
//  Created by Dmitry Fedoseyev on 07.10.2021.
//  Copyright © 2021 100ms. All rights reserved.
//

import UIKit

extension UIViewController {
    func showError(_ error: String, completion: @escaping (() -> Void)) {
        let title = "Error"

        let alertController = UIAlertController(title: title,
                                                message: error,
                                                preferredStyle: .alert)

        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { _ in
            completion()
        }))

        present(alertController, animated: true)
    }
}
