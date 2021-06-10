//
//  CardCollectionViewCell.swift
//  cardMatching
//
//  Created by LuanLing on 1/14/20.
//  Copyright © 2020 LuanLing. All rights reserved.
//

import Foundation
import UIKit

// MARK: UIImageView extention
extension UIImageView {
    // cached images set to avoid redudant API calls
    static let imageCache = NSCache<AnyObject, AnyObject>()
    
    // load image
    public func loadImageFromUrl(urlString: String, placeHolderImage:UIImage) {
        guard let url = URL(string: urlString) else {
            return
        }
        self.image = nil
        if let imageFromCache = UIImageView.imageCache.object(forKey: urlString as AnyObject) as? UIImage {
            self.image = imageFromCache
            return
        }
        URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) -> Void in
            if error != nil {
                print(error ?? "No Error")
                DispatchQueue.main.async {
                    self.image = placeHolderImage
                }
                return
            }
            DispatchQueue.main.async {
                if let image = UIImage(data: data!) {
                    UIImageView.imageCache.setObject(image, forKey: urlString as AnyObject)
                    self.image = image
                } else {
                    self.image = placeHolderImage
                }
            }

        }).resume()
}}

// MARK: CardCollectionViewCell
class CardCollectionViewCell:UICollectionViewCell {
    @IBOutlet weak var frontImage:UIImageView!
    @IBOutlet weak var backImage:UIImageView!
    private var imageUrl:String?
    private var flipped:Bool = false
    
    /// this method is called from collectionView and passed in url string as dynamic load image
    /// - Parameter url: String
    public func setImage(_ url:String, _ index:Int) {
        flipped = false
        frontImage.isHidden = false
        frontImage.alpha = 0.0
        frontImage.layer.cornerRadius = 6
        frontImage.clipsToBounds = true
        backImage.isHidden = false
        backImage.alpha = 0.0
        backImage.layer.cornerRadius = 6
        backImage.clipsToBounds = true
        
        UIView.animate(withDuration: 0.2, delay: 0.1*Double(index), animations: {[unowned self] in
            self.frontImage.alpha = 1.0
            self.backImage.alpha = 1.0
        })
        self.imageUrl = url
        backImage.contentMode = .scaleAspectFill
        backImage.loadImageFromUrl(urlString: url, placeHolderImage: UIImage())
    }
    
    
    /// flip animation
    public func flip() {
        if !flipped {
            UIView.transition(from: frontImage, to: backImage , duration: 0.3, options: [.transitionFlipFromLeft, .showHideTransitionViews, .curveEaseInOut], completion: nil)
            flipped = true
        }
    }
    
    /// flipBack animation with delay
    public func flipBack() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {[unowned self] in
            UIView.transition(from: self.backImage, to: self.frontImage, duration: 0.3, options: [.transitionFlipFromLeft, .showHideTransitionViews, .curveEaseInOut], completion: nil)
        })
        flipped = false
    }
}
