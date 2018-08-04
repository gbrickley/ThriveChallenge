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

    public func setImageFrom(url: URL, placholder: UIImage)
    {
        self.af_setImage(withURL: url, placeholderImage: placholder)
        
        /*
        self.image = placholder
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else {
                    completion(false)
                    return
            }
            
            DispatchQueue.main.async() {
                self.image = image
                completion(true)
            }
            
            }.resume()
         */
    }
}
