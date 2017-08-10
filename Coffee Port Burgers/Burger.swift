//
//  Burger.swift
//  Coffee Port Burgers
//
//  Created by Frederick Dupray on 09/08/2017.
//  Copyright © 2017 Nattr. All rights reserved.
//

import UIKit
import Gloss

class Burger: Decodable {

    //Use optionals to avoid errors if JSON key returns a nil value.
    var imageLinkString: String!
    var isVegetarian: Bool!
    var burgerName: String!
    var burgerNotes: String!
    var isPromoted: Bool!
    var burgerPrice: Int!
    var id: Int!
    
    required init?(json: JSON) {
        
        self.imageLinkString = "image" <~~ json
        self.isVegetarian = "vegetarian" <~~ json
        self.id = "id" <~~ json
        self.burgerName = "name" <~~ json
        self.burgerNotes = "notes" <~~ json
        self.burgerPrice = "bitcoin" <~~ json
        self.isPromoted = "promoted" <~~ json
    }
}

