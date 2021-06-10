//
//  ViewController.swift
//  cardMatching
//
//  Created by LuanLing on 1/14/20.
//  Copyright © 2020 LuanLing. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    private lazy var gameViewModel = CardMatchViewModel()
    private let reuseIdentifier = "cardCell"
    private var items:[Card]?
    private let itemsPerRow:CGFloat = 4
    private let sectionInsets = UIEdgeInsets(top: 20.0, left: 20.0, bottom: 20.0, right: 20.0)
    private var loader : UIView?
    
    @IBOutlet weak var cardCollection: UICollectionView!
    @IBOutlet weak var tapCountLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // configure collection view, assign delegate and data source
        self.cardCollection.isHidden = true
        self.cardCollection.delegate = self
        self.cardCollection.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showLoader()
        gameViewModel.delegate = self
        gameViewModel.fetchImages()
    }
    
    func showLoader() {
        let spinnerView = UIView.init(frame: self.view.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView.init(style: .large)
        ai.startAnimating()
        ai.center = spinnerView.center
        
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            self.view.addSubview(spinnerView)
        }
        
        loader = spinnerView
    }
    
    func removeLoader() {
        DispatchQueue.main.async {
            self.loader?.removeFromSuperview()
            self.loader = nil
        }
    }
    
    @IBAction func pressedRestart(_ sender: Any) {
        gameViewModel.resetGameboard()
    }
}

// MARK: CardMatchDelegate
extension ViewController: CardMatchDelegate {
    func updateCollectionViewDataSource() {
        cardCollection.reloadData()
        self.cardCollection.isHidden = false
        self.removeLoader()
    }
    
    
    func updateTapCount(count: Int) {
        //print("tapCount \(count)")
        tapCountLabel.text = "Total taps: \(count)"
    }
    
    func updateSuccessState() {
        let alertController = UIAlertController(title: "Congratulations", message: "You've completed this game! \n Want to play again?", preferredStyle: .alert)
        let action1 = UIAlertAction(title: "Restart", style: .default) {[unowned self] (action:UIAlertAction) in
            self.gameViewModel.resetGameboard()
        }
        let action2 = UIAlertAction(title: "Cancel", style: .default)
        alertController.addAction(action1)
        alertController.addAction(action2)

        self.present(alertController, animated: true, completion: nil)
    }
    
    func displayErrorState() {
        let alertController = UIAlertController(title: "Oops!", message: "Seems like internet connection is poor. \n Want to retry again?", preferredStyle: .alert)
        let action1 = UIAlertAction(title: "Retry", style: .default) {[unowned self] (action:UIAlertAction) in
            self.gameViewModel.fetchImages()
        }
        alertController.addAction(action1)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func resetFlippedState(cardIndices:[Int]) {
        // use the 2 flipped over card's index to find the collectionViewCell then flip them back
        for index in cardIndices {
            if let cell = cardCollection.cellForItem(at: IndexPath(row: index, section: 0)) as? CardCollectionViewCell {
                cell.flipBack()
            }
        }
    }
}

// MARK: UICollectionViewDataSource
extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gameViewModel.totalItemCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // get a reference to our storyboard cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! CardCollectionViewCell
        // optional binding to check if card is ready in model set
        if let card = gameViewModel.cards?[indexPath.row]{
            cell.setImage(card.backImageUrl ?? "", indexPath.row)
        }
        return cell
    }
}

// MARK: UICollectionViewDelegate
extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // check if it's already matched
        if !gameViewModel.checkMatchedState(index: indexPath.row) {
            let cell = collectionView.cellForItem(at: indexPath) as! CardCollectionViewCell
            // if not matched yet, flip the card and update Card model state by indexPath.row
            cell.flip()
            gameViewModel.updateCardState(index: indexPath.row)
        }
    }
}

// MARK: UICollectionViewDelegate
extension ViewController : UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      sizeForItemAt indexPath: IndexPath) -> CGSize {
    // use collectionView bounds to calculate card's width and height
    let paddingSpace = sectionInsets.left*(itemsPerRow + 1)
    let availableWidth = collectionView.bounds.width - paddingSpace
    let widthPerItem = availableWidth/itemsPerRow
    
    let availableHeight = collectionView.bounds.height - paddingSpace
    let heightPerItem = availableHeight/itemsPerRow
    
    return CGSize(width: widthPerItem, height: heightPerItem)
  }
  
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      insetForSectionAt section: Int) -> UIEdgeInsets {
    return sectionInsets
  }
  
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return sectionInsets.left
  }
}



