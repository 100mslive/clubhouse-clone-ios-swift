//
//  ParticipantCollectionViewCell.swift
//  AudioRoom
//
//  Created by Dmitry Fedoseyev on 30.09.2021.
//  Copyright © 2021 100ms. All rights reserved.
//

import UIKit

class ParticipantCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var muteImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var twoLetterLabel: UILabel!
    @IBOutlet weak var glowImageView: UIImageView!

    var name: String? {
        didSet {
            twoLetterLabel.text = name?.initials()
            nameLabel.text = name
        }
    }
    
    var isMute = false {
        didSet {
            muteImageView.isHidden = !isMute
        }
    }

    var isSpeaking = false {
        didSet {
            glowImageView.isHidden = !isSpeaking
        }
    }
    
    override func awakeFromNib() {
        let bgImage = UIImage(named: "gradient")?.resizableImage(withCapInsets: .zero, resizingMode: .stretch)
        profileImageView.image = bgImage
    }
}

extension String {
    func initials() -> String {
        components(separatedBy: " ").compactMap { $0.first?.uppercased() }.prefix(2).joined()
    }
}
