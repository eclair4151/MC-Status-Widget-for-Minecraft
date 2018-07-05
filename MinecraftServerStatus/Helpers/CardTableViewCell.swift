//
//  CardTableViewCell.swift
//  MinecraftServerStatus.swift
//
//  Created by Tomer on 4/23/18.
//  Copyright © 2018 Tomer Shemesh. All rights reserved.
//

import UIKit

class CardTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.contentView.layoutIfNeeded()
    }
    
    func createShadow(cardView: UIView) {
        cardView.alpha = 1
        cardView.layer.masksToBounds = false
        cardView.layer.cornerRadius = 1
        cardView.layer.shadowOffset = CGSize(width: 1, height: 1)
        cardView.layer.shadowRadius = 1
        let path = UIBezierPath(rect: cardView.bounds)
        cardView.layer.shadowPath = path.cgPath
        cardView.layer.shadowOpacity = 0.25
    }
}
