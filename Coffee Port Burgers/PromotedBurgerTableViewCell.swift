//
//  PromotedBurgerTableViewCell.swift
//  Coffee Port Burgers
//
//  Created by Frederick Dupray on 09/08/2017.
//  Copyright © 2017 Nattr. All rights reserved.
//

import UIKit

class PromotedBurgerTableViewCell: UITableViewCell {

    @IBOutlet weak var burgerImageView: UIImageView!
    @IBOutlet weak var vegetarianSymbolLabel: UILabel!
    @IBOutlet weak var burgerNameLabel: UILabel!
    @IBOutlet weak var purchaseItemButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.burgerNameLabel.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.burgerNameLabel.layer.shadowOpacity = 1
        self.burgerNameLabel.layer.shadowRadius = 6
    }
    
    func enterBurgerInfo (_ burger: Burger) {
        
        //If is vegetarian then show symbol. If not then, don't.
        self.vegetarianSymbolLabel.isHidden = !burger.isVegetarian
        
        //Fill burger name
        self.burgerNameLabel.text = burger.burgerName
        
        //Price tag
        self.purchaseItemButton.setTitle("฿"+String(burger.burgerPrice), for: .normal)
    }
    
    override func prepareForReuse() {
                
        vegetarianSymbolLabel.isHidden = true
    }
}
