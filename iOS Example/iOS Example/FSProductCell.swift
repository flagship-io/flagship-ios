//
//  FSProductCell.swift
//  FlagShipDemo
//
//  Created by Adel on 26/09/2019.
//  Copyright © 2019 FlagShip. All rights reserved.
//

import UIKit

class FSProductCell: UITableViewCell {
    
    
    @IBOutlet var productImageView:UIImageView!
    
    @IBOutlet var nameLabel:UILabel!
    
    @IBOutlet var sizeLabel:UILabel!
    
    @IBOutlet var priceLabel:UILabel!


    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }


    
    func configCell(_ product:FSProduct){
        // Set name
        nameLabel.text = product.name
        // set Size
        priceLabel.text = product.price
        // Set Picture
        productImageView.image = UIImage(imageLiteralResourceName: product.imageString)
        // Set price
        sizeLabel.text = String(format: "Size : %@", product.size)
    }

}
