//
//  PhotoDetailsViewController.swift
//  Photomania
//
//  Created by Essan Parto on 2014-08-25.
//  Copyright (c) 2014 Essan Parto. All rights reserved.
//

import UIKit

class PhotoDetailsViewController: UIViewController {
  @IBOutlet weak var highestLabel: UILabel!
  @IBOutlet weak var pulseLabel: UILabel!
  @IBOutlet weak var viewsLabel: UILabel!
  @IBOutlet weak var descriptionLabel: UILabel!
  
  
  var photoInfo: PhotoInfo?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let tapGesture = UITapGestureRecognizer(target: self, action: "dismiss")
    tapGesture.numberOfTapsRequired = 1
    tapGesture.numberOfTouchesRequired = 1
    view.addGestureRecognizer(tapGesture)
    
    highestLabel.text = String(format: "%.1f", photoInfo?.highest ?? 0)
    pulseLabel.text = String(format: "%.1f", photoInfo?.pulse ?? 0)
    viewsLabel.text = "\(photoInfo?.views ?? 0)"
    descriptionLabel.text = photoInfo?.desc
  }
  
  func dismiss() {
    self.dismissViewControllerAnimated(true, completion: nil)
  }
}
