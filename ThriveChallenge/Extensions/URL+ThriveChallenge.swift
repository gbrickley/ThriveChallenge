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
        print("[ZZZ]: Checking if gif: \(self)")
        let fileExtension = self.pathExtension.lowercased()
        print("[ZZZ]: Extension: \(fileExtension)")
        let result = fileExtension == "gif"
        print("[ZZZ]: Result: \(result)")
        return result
    }
}
