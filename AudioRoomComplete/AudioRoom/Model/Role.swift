//
//  Role.swift
//  AudioRoom
//
//  Created by Dmitry Fedoseyev on 08.10.2021.
//  Copyright © 2021 100ms. All rights reserved.
//

import Foundation
import HMSSDK

//List of roles known by the app
enum Role: String {
    case host
    case speaker
    case speakerwannabe
    case audience
    case unknown
}

extension HMSPeer {
    // Maps the role name of a peer to one of the known roles
    var mappedRole: Role {
        return Role(rawValue: role?.name ?? "unknown") ?? .unknown
    }
}
