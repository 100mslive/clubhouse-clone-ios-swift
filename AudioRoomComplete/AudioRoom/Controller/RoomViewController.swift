//
//  RoomViewController.swift
//  AudioRoom
//
//  Created by Dmitry Fedoseyev on 29.09.2021.
//  Copyright © 2021 100ms. All rights reserved.
//

import UIKit
import HMSSDK

class RoomViewController: UIViewController {
    @IBOutlet weak var bottomOverlay: UIImageView!
    @IBOutlet var participantsView: UICollectionView!
    @IBOutlet weak var muteButton: UIButton!
    @IBOutlet weak var raiseHandButton: UIButton!
    
    var token = ""
    var name = ""

    private let hms: HMSSDK = HMSSDK.build()
    
    // Map the role of the local peer to a known role
    private var localRole: Role {
        return hms.localPeer?.mappedRole ?? .unknown
    }
    
    // Wether current peer is a host
    private  var isHost: Bool {
        localRole == .host
    }
    
    private var canSpeak: Bool {
        switch localRole {
        case .host, .speaker:
            return true
        default:
            return false
        }
    }
    
    private var sections = [Section]() {
        didSet {
            participantsView.reloadData()
        }
    }
    
    private var speakers = Set<String>() {
        didSet {
            participantsView.reloadData()
        }
    }
        
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
            hms.leave()
        }
    }
    
    @IBAction func leaveTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func raiseHandTapped(_ sender: UIButton) {
        guard let peer = hms.localPeer else {
            return
        }
        
        sender.isSelected = !sender.isSelected
        sender.tintColor = sender.isSelected ? .red : .white

        // If hand is already raised move ourselves back to audience
        let role = sender.isSelected ? Role.audience : Role.speakerwannabe

        change(peer: peer, to: role)
    }
    
    @IBAction func muteTapped(_ sender: Any) {
        muteButton.isSelected = !muteButton.isSelected
        hms.localPeer?.localAudioTrack()?.setMute(muteButton.isSelected)
        reloadModel()
    }
    
    private func join() {
        let config = HMSConfig(userName: name, userID: "", roomID: "", authToken: token)
        hms.join(config: config, delegate: self)
    }
    
    private func reloadModel() {
        // Get a list of peers in the room
        let peers = hms.room?.peers ?? []
        // Create a section of each type to add peers to
        let sectionsModel = SectionType.allCases.map { Section(type: $0) }
        
        for peer in peers {
            // Get section type for this peer based on its role
            let type = Section.sectionType(for: peer.mappedRole, showRaisedHand: isHost)
            // Find the index of this section in the resulting array
            let index = type.rawValue
            // Add the peer to the respective section
            sectionsModel[index].peers.append(peer)
        }
        
        // Remove empty sections and store the new model
        sections = sectionsModel.filter { !$0.peers.isEmpty }
    }
    
    func change(peer: HMSPeer, to role: Role) {
        // Get a reference to HMSRole instance for required role
        guard let newRole = hms.roles.first(where: { $0.name == role.rawValue }) else {
            return
        }
        // The force flag is used by the backend to decide wether peer
        // should be changed immediately or promted to change instead.
        hms.changeRole(for: peer, to: newRole, force: true)
    }
    
    private func setupButtonStates() {
        muteButton.isHidden = !canSpeak
        raiseHandButton.isHidden = canSpeak
    }
}

extension RoomViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sections[safe: section]?.peers.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let section = sections[safe: indexPath.section], kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        
        let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as! SectionHeader
        sectionHeader.nameLabel.text = section.sectionDisplayName()
        return sectionHeader
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let peer = sections[safe: indexPath.section]?.peers[safe: indexPath.item],
              let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ParticipantCell",
                                                            for: indexPath) as? ParticipantCollectionViewCell else {
                  return UICollectionViewCell()
              }
        
        cell.name = peer.name
        cell.isMute = (peer.audioTrack?.isMute() ?? false)
        cell.isSpeaking = speakers.contains(peer.peerID)
        
        return cell
    }
}

extension RoomViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        guard let section = sections[safe: section], section.type != .speakers else {
            return .zero
        }
        
        return CGSize(width: collectionView.frame.width, height: 30)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let peer = sections[safe: indexPath.section]?.peers[safe: indexPath.item], isHost else {
            return
        }
        
        let action: UIAlertAction
        
        switch peer.mappedRole {
        case .speakerwannabe:
            action = changeRoleAction(peer: peer, role: .speaker, title: "Move to speakers")
        case .speaker:
            action = changeRoleAction(peer: peer, role: .audience, title: "Move to audience")
        default:
            return
        }
        
        let alertController = UIAlertController(title: "",
                                                message: "Select action",
                                                preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alertController.addAction(action)
        
        present(alertController, animated: true)
    }
    
    func changeRoleAction(peer: HMSPeer, role: Role, title: String) -> UIAlertAction {
        UIAlertAction(title: title, style: .default) { [weak self] _ in
           self?.change(peer: peer, to: role)
       }
    }
}

extension RoomViewController: HMSUpdateListener {
    func on(join room: HMSRoom) {
        reloadModel()
        setupButtonStates()
    }
    
    func on(room: HMSRoom, update: HMSRoomUpdate) {
        
    }
    
    func on(peer: HMSPeer, update: HMSPeerUpdate) {
        reloadModel()
    }
    
    func on(track: HMSTrack, update: HMSTrackUpdate, for peer: HMSPeer) {
        reloadModel()
    }
    
    func on(error: HMSError) {
        showError(error.localizedDescription) { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
    }
    
    func on(message: HMSMessage) {
        
    }
    
    func on(updated speakers: [HMSSpeaker]) {
        self.speakers = Set(speakers.map { $0.peer.peerID })
    }
    
    func onReconnecting() {
        
    }
    
    func onReconnected() {
        
    }
}
