//
//  CardMatchViewModel.swift
//  cardMatching
//
//  ViewModel serve for card matching game
//  Created by LuanLing on 1/14/20.
//  Copyright © 2020 LuanLing. All rights reserved.
//

import Foundation

protocol CardMatchDelegate: AnyObject {
    func updateCollectionViewDataSource()
    func updateTapCount(count:Int)
    func resetFlippedState(cardIndices:[Int])
    func displayErrorState()
    func updateSuccessState()
}

class CardMatchViewModel {
    public var totalItemCount:Int = 16
    public weak var delegate:CardMatchDelegate?
    public private(set) var cards:[Card]?
    private var imageSource:[String] = [String]()
    private var groupedImageSets = [String]()
    private var tapCount:Int = 0
    private var flippedCards = [Int]()
    private var matchedSet = Set<Int>()
    
    
    /// the API request method
    public func fetchImages() {
        let url = URL(string: BaseApiEndpoints.urlWithEndpoint(.GET))

        let arguments:[String: AnyObject] = ["query": "dog" as AnyObject, "per_page":totalItemCount as AnyObject]
        let request = BaseApiRequest.composeRequest(type: BaseEnumEndpoint.GET_CARD_IMAGE.requestMethod, url: url!, arguments: arguments)
        BaseServiceManager.shared.performWithRequest(urlRequest: request, success: {[unowned self] (dictionary) in
            
            guard let data = dictionary as? [String:AnyObject], let images = data["photos"] as? [[String:AnyObject]] else {
                DispatchQueue.main.async {
                    self.delegate?.displayErrorState()
                }
                return
            }
            for image in images {
                if let src = image["src"] as? [String:AnyObject], let url = src["small"] as? String {
                    self.imageSource.append(url)
                }
            }
            // check if imageSource is less than totalItemCount meaning it's not good for the random logic
            if self.imageSource.count < totalItemCount {
                DispatchQueue.main.async {
                    self.delegate?.displayErrorState()
                }
                return
            }
            self.generateNewCardDeck()
            DispatchQueue.main.async {
                self.delegate?.updateCollectionViewDataSource()
            }
            
        }) { (error) in
            print("error")
            DispatchQueue.main.async {
                self.delegate?.displayErrorState()
            }
        }
    }
    
    /// being called from collectionView did select cell method by passing indexPath.row value to do the match or not logic
    /// - Parameter index: Int
    public func updateCardState(index:Int) {
        // find the tappedCard by filtered with index match rule
        // find matchedCard by filtered with backgroundImaageUrl match rule and not the same index
        guard let tappedCard = cards?.filter({$0.index == index}).first,
            let matchedCard = cards?.filter({$0.backImageUrl == tappedCard.backImageUrl && $0.index != index}).first else {
            return
        }

        // if tappedCard is matched && flipped then don't do anything
        if tappedCard.isMatched || tappedCard.isFlipped {
            return
        }
        print("tappedCard \(tappedCard.index) matched card id :: \(matchedCard.index)")
        // append index into flippedCards array to keep count
        // will removeAll once count is equal 2 toward the end of the prcedure
        flippedCards.append(tappedCard.index)
        // update it's flipped state
        tappedCard.isFlipped = true

        // if the matchedCard & tappedCard are both flipped already, update isMatched property to true, and append their index in matchedSet
        if matchedCard.isFlipped && tappedCard.isFlipped {
            matchedCard.isMatched = true
            tappedCard.isMatched = true
            matchedSet.insert(tappedCard.index)
            matchedSet.insert(matchedCard.index)
        } else {
            // if not matched and flippedCards count is 2, then we reset isFlipped flag
            if flippedCards.count == 2 {
                _ = cards?.map{$0.isFlipped=false}
                self.delegate?.resetFlippedState(cardIndices: flippedCards)
            }
        }
        // if flippedCards are more than 2 remove it no matter if they are matched or not
        if flippedCards.count == 2 {
            flippedCards.removeAll()
        }
        // update tapCount
        tapCount+=1
        self.delegate?.updateTapCount(count: tapCount)
        // if total matched count is equal to totalItemCount, then display success state
        if (matchedSet.count == totalItemCount) {
            self.delegate?.updateSuccessState()
        }
    }
    
    /// a match validation check method, is used by collectionView didSelectCell method
    /// if return true, then the card don't need to flipback
    /// - Parameter index: Int
    public func checkMatchedState(index:Int) -> Bool {
        return matchedSet.contains(index)
    }
    
    /// once user press restart button, generate new card sets and remove all the matchedSet storage
    /// , flippedCards storage, tapCount and reset UI element by delegate methods
    public func resetGameboard() {
        //reset card state
        tapCount = 0
        generateNewCardDeck()
        matchedSet.removeAll()
        flippedCards.removeAll()
        self.delegate?.updateCollectionViewDataSource()
        self.delegate?.updateTapCount(count: tapCount)
    }
    
    /// method to generate card deck,
    private func generateNewCardDeck() {
        cards = [Card]()
        groupedImageSets = [String]()
        // just use remainder operator to toggle result 0 or 1 and use it to pick what image to use from
        // image source array
        let remainder = Int.random(in: 0...1)
        for (index, value) in imageSource.enumerated() {
            if index%2 == remainder {
                groupedImageSets += Array(repeating: value, count: 2)
            }
        }
        // shuffle the repetitive image order
        groupedImageSets.shuffle()
        // generate card models
        for index in 0..<groupedImageSets.count {
            let card = Card()
            card.index = index
            card.backImageUrl = groupedImageSets[index]
            card.isFlipped = false
            card.isMatched = false
            cards?.append(card)
        }
    }
}
