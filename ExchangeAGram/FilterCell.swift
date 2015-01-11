//
//  FilterCell.swift
//  ExchangeAGram
//
//  Created by Anup on 05/01/2015.
//  Copyright (c) 2015 Anup. All rights reserved.
//

import UIKit

/*
* Step 16 - create a FilterCell cocoa class which is a sub class of 
* UICollectionViewCell by doing command+n
*/
class FilterCell: UICollectionViewCell {
    
    // Step 16.1 - We then want to create an imageView which
    // will be initialised immediately and will cover the entire
    // Collection view cell
    var imageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
        contentView.addSubview(imageView)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
