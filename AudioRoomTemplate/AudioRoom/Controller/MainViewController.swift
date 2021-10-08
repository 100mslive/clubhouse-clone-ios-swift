//
//  MainViewController.swift
//  AudioRoom
//
//  Created by Dmitry Fedoseyev on 29.09.2021.
//  Copyright © 2021 100ms. All rights reserved.
//

import UIKit

class MainViewController: UITableViewController {

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var avatarView: UIImageView!
    @IBOutlet weak var profileIcon: UIImageView!
    @IBOutlet weak var avatarLabel: UIImageView!
    @IBOutlet weak var roleSwitch: UISegmentedControl!
    
    let tokenProvider = TokenProvider()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        avatarView.image = UIImage(named: "gradient")?.resizableImage(withCapInsets: .zero, resizingMode: .stretch)
    }

    @IBAction func onJoinTapped(_ sender: UIButton) {
        guard let name = nameField.text, !name.isEmpty else {
            return
        }
        
        guard let role = roleSwitch.titleForSegment(at: roleSwitch.selectedSegmentIndex)?.lowercased() else {
            return
        }
        
        tokenProvider.getToken(for: UUID().uuidString, role: role) { [weak self] token, error in
            guard let token = token, error == nil else {
                print(#function, error?.localizedDescription ?? "Unknown error")
                return
            }
            
            self?.showRoom(name: name, token: token)
        }
        
    }
    
    @IBAction func doneTapped(_ sender: UITextField) {
        sender.resignFirstResponder()
    }
    
    func showRoom(name: String, token: String) {
        guard let vc = storyboard?.instantiateViewController(identifier: "RoomController") as? RoomViewController else {
            return
        }
        
        vc.token = token
        vc.name = name
        
        present(vc, animated: true, completion: nil)
    }
    
}

