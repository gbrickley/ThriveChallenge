//
//  UIImage+ThriveChallenge.swift
//  ThriveChallenge
//
//  Created by George Brickley on 8/3/18.
//  Copyright © 2018 George Brickley. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    
    func aspectRatio() -> CGFloat
    {
        let size = self.size
        return size.width / size.height
    }

}
