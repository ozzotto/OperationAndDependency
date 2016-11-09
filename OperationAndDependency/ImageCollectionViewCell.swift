//
//  ImageCollectionViewCell.swift
//  OperationAndDependency
//
//  Created by Othonas Antoniou on 09/11/2016.
//  Copyright © 2016 ozzotto Inc. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 1.0
        imageView!.layer.masksToBounds = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView!.image = nil
    }
}
