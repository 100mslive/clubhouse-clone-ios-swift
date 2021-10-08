//
//  RoomViewController.swift
//  AudioRoom
//
//  Created by Dmitry Fedoseyev on 29.09.2021.
//  Copyright © 2021 100ms. All rights reserved.
//

import UIKit

class RoomViewController: UIViewController {
    @IBOutlet weak var bottomOverlay: UIImageView!
    @IBOutlet var participantsView: UICollectionView!
    @IBOutlet weak var muteButton: UIButton!
    @IBOutlet weak var raiseHandButton: UIButton!
    
    var token = ""
    var name = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        join()
        
        bottomOverlay.image = UIImage(named: "bottomOverlay")?.resizableImage(withCapInsets: .zero, resizingMode: .stretch)
        participantsView.register(UINib(nibName: "SectionHeader", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
    }

    override func viewWillAppear(_ animated: Bool) {
        UIApplication.shared.isIdleTimerDisabled = true
        
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func endAppearanceTransition() {
        super.endAppearanceTransition()
        
        if isBeingDismissed {
            UIApplication.shared.isIdleTimerDisabled = false
        }
    }
    
    @IBAction func leaveTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func raiseHandTapped(_ sender: UIButton) {
    }
    
    @IBAction func muteTapped(_ sender: Any) {
    }
    
    private func join() {
    }
    
    private func reloadModel() {
    }
}

extension RoomViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return UICollectionViewCell()
    }
}

extension RoomViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 30)
    }
}
