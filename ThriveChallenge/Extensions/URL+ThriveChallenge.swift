//
//  URL+ThriveChallenge.swift
//  ThriveChallenge
//
//  Created by George Brickley on 8/4/18.
//  Copyright © 2018 George Brickley. All rights reserved.
//

import Foundation
import UIKit

extension URL {
    
    /// Whether or not the file type of the url is gif
    func isGif() -> Bool
    {
        let fileExtension = self.pathExtension.lowercased()
        return fileExtension == "gif"
    }
}
