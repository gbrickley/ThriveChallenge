//
//  UIImageView+ThriveChallenge.swift
//  ThriveChallenge
//
//  Created by George Brickley on 8/3/18.
//  Copyright © 2018 George Brickley. All rights reserved.
//

import Foundation
import UIKit
import AlamofireImage

extension UIImageView {

    public func setImageFrom(url: URL, placholder: UIImage, completion: @escaping (_ succedd: Bool) -> Void )
    {
        self.af_setImage(withURL: url, placeholderImage: placholder, filter: nil, progress: nil, progressQueue: DispatchQueue.main, imageTransition: UIImageView.ImageTransition.noTransition, runImageTransitionIfCached: false, completion: { response in
            completion(response.result.isSuccess)
        })
    }
}
