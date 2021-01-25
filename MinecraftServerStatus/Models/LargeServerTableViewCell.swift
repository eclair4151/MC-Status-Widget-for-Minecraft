//
//  LargeServerTableViewCell.swift
//  MinecraftServerStatus
//
//  Created by Tomer on 6/27/18.
//  Copyright © 2018 ShemeshApps. All rights reserved.
//

import UIKit
import MarqueeLabel

class LargeServerTableViewCell: CardTableViewCell {

    @IBOutlet weak var motdMessageLabel: MarqueeLabel!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var playerCountLabel: UILabel!
    @IBOutlet weak var playerListLabel: MarqueeLabel!
    @IBOutlet weak var ipLabel: UILabel!
    @IBOutlet weak var portLabel: UILabel!
    @IBOutlet weak var motdLabel: UILabel!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var statusResultLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        createShadow(cardView: self.cardView)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
