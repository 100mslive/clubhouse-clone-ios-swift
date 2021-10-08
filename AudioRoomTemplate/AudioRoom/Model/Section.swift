//
//  Section.swift
//  AudioRoom
//
//  Created by Dmitry Fedoseyev on 07.10.2021.
//  Copyright © 2021 100ms. All rights reserved.
//

import Foundation
import HMSSDK


//List of sections to display in UI
enum SectionType: Int, CaseIterable {
    case speakers
    case raisedHand
    case audience
}

class Section {
    
    var type: SectionType
    var peers = [HMSPeer]()
    
    init(type: SectionType) {
        self.type = type
    }
    
    // Section title to show in UI. Speakers is a topmost section that
    // should not show a name for a cleaner UI.
    func sectionDisplayName() -> String? {
        switch type {
        case .speakers:
            return nil
        case .raisedHand:
            return "Raised hand"
        case .audience:
            return "Audience"
        }
    }
    
    // Which roles go into which section. Speakers and hosts are clubbed together.
    // Only hosts can section for people who raised their hand, rest will see
    // them as audience
    class func sectionType(for role: Role, showRaisedHand: Bool) -> SectionType {
            switch role {
            case .speaker, .host:
                return .speakers
            case .audience:
                return .audience
            case .speakerwannabe:
                return showRaisedHand ? .raisedHand : .audience
            default:
                return .audience
            }
    }
}
