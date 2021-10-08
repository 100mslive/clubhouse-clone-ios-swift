//
//  Collection+Util.swift
//  AudioRoom
//
//  Created by Dmitry Fedoseyev on 07.10.2021.
//  Copyright © 2021 100ms. All rights reserved.
//

import Foundation

extension Collection {
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
