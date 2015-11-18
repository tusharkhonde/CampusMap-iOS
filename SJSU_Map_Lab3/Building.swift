//
//  Building.swift
//  SJSU_Map_Lab3
//
//  Created by TUSHAR KHONDE on 11/10/15.
//  Copyright © 2015 TUSHAR KHONDE. All rights reserved.
//

import UIKit

class Building {
    
    var name: String
    var address: String
    var image: UIImage?
    var tag: String
    

    init(name: String, address: String, image: UIImage?, tag: String) {
        
        self.name = name
        self.address = address
        self.image = image
        self.tag = tag
        
    }
    
    }
