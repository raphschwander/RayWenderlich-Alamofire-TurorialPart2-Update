//
//  PhotoBrowserCollectionViewController.swift
//  Photomania
//
//  Created by Essan Parto on 2014-08-20.
//  Copyright (c) 2014 Essan Parto. All rights reserved.
//

import UIKit
import Alamofire

class PhotoBrowserCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
  var photos = NSMutableOrderedSet() // Defined var photos = NSMutableOrderedSet() as a set; since all items in a set must be unique, this guarantees you won’t show a photo more than once.
  
    let imageCache = NSCache()
  let refreshControl = UIRefreshControl()
    var populatingPhotos = false
    var currentPage = 1
  
  let PhotoBrowserCellIdentifier = "PhotoBrowserCell"
  let PhotoBrowserFooterViewIdentifier = "PhotoBrowserFooterView"
  
  // MARK: Life-cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupView()
    
    populatePhotos()
    
//    Alamofire.request(.GET, "https://api.500px.com/v1/photos", parameters: ["consumer_key": "eSEbYZiDOYlzdy0tJcQDxTvtaSJ5c2X1CUQP9jtX"]).responseJSON() { response in
//        
//        if let JSON = response.result.value {
//
//            let photoInfos = (JSON.valueForKey("photos") as! [NSDictionary]).filter({
//                ($0["nsfw"] as! Bool) == false
//            }).map {
//                PhotoInfo(id: $0["id"] as! Int, url: $0["image_url"] as! String)
//            }
//            
//            self.photos.addObjectsFromArray(photoInfos)
//            
//            self.collectionView?.reloadData()
//        }
//        
//    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  // MARK: CollectionView
  
  override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return photos.count
  }
  
  override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(PhotoBrowserCellIdentifier, forIndexPath: indexPath) as! PhotoBrowserCollectionViewCell
    
    let imageURL = (photos.objectAtIndex(indexPath.row) as! PhotoInfo).url
    
    cell.request?.cancel() // The dequeued cell may already have an Alamofire request attached to it. You can simply cancel it because it’s no longer valid for this new cell
    
    //Use optional binding to check if you have a cached version of this photo. If so, use the cached version instead of downloading it again
    if let image = self.imageCache.objectForKey(imageURL) as? UIImage {
        cell.imageView.image = image
    } else {
        
        //If you don’t have a cached version of the photo, download it. However, the the dequeued cell may be already showing another image; in this case, set it to nil so that the cell is blank while the requested photo is downloaded
        cell.imageView.image = nil
        
        //Download the image from the server, but this time validate the content-type of the returned response. If it’s not an image, error will contain a value and therefore you won’t do anything with the potentially invalid image response. The key here is that you you store the Alamofire request object in the cell, for use when your asynchronous network call returns
        cell.request = Alamofire.request(.GET, imageURL).validate(contentType: ["image/*"]).responseImage() {
            response in
            
            //If you did not receive an error and you downloaded a proper photo, cache it for later
            if let img = response.result.value where response.result.error == nil {
                
                //Set the cell’s image accordingly
                self.imageCache.setObject(img, forKey: response.request!.URLString)
                
                cell.imageView.image = img
            } else {
                /*
                If the cell went off-screen before the image was downloaded, we cancel it and
                an NSURLErrorDomain (-999: cancelled) is returned. This is a normal behavior.
                */
            }
        }
    }
    
//    Alamofire.request(.GET, imageURL).responseImage() { response in
//        
//        if let img = response.result.value {
//            cell.imageView.image = img
//        }
//    }
//    
//    Alamofire.request(.GET, imageURL).response() { _,_,data,_ in
//        
//        let image = UIImage(data: data!)
//        dispatch_async(dispatch_get_main_queue()) {
//            cell.imageView.image = image
//        }
//        
//    }
    
    
    return cell
  }
  
  override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
    return collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: PhotoBrowserFooterViewIdentifier, forIndexPath: indexPath) 
  }
  
  override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    performSegueWithIdentifier("ShowPhoto", sender: (self.photos.objectAtIndex(indexPath.item) as! PhotoInfo).id)
  }
  
  // MARK: Helper
  
  func setupView() {
    navigationController?.setNavigationBarHidden(false, animated: true)
    
    let layout = UICollectionViewFlowLayout()
    let itemWidth = (view.bounds.size.width - 2) / 3
    layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
    layout.minimumInteritemSpacing = 1.0
    layout.minimumLineSpacing = 1.0
    layout.footerReferenceSize = CGSize(width: collectionView!.bounds.size.width, height: 100.0)
    
    collectionView!.collectionViewLayout = layout
    
    navigationItem.title = "Featured"
    
    collectionView!.registerClass(PhotoBrowserCollectionViewCell.classForCoder(), forCellWithReuseIdentifier: PhotoBrowserCellIdentifier)
    collectionView!.registerClass(PhotoBrowserCollectionViewLoadingCell.classForCoder(), forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: PhotoBrowserFooterViewIdentifier)
    
    refreshControl.tintColor = UIColor.whiteColor()
    refreshControl.addTarget(self, action: "handleRefresh", forControlEvents: .ValueChanged)
    collectionView!.addSubview(refreshControl)
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "ShowPhoto" {
      (segue.destinationViewController as! PhotoViewerViewController).photoID = sender!.integerValue
      (segue.destinationViewController as! PhotoViewerViewController).hidesBottomBarWhenPushed = true
    }
  }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.y + view.frame.size.height > scrollView.contentSize.height * 0.8 { // Loads more photos once the user has scrolled 80% of the view
            populatePhotos()
        }
    }
    
   func populatePhotos() {
    // Loads photos in the "currentPage" and uses "populatingPhotos" as a flag to avoid loading the next page while you are still loading the current page
    if populatingPhotos {
        return
    }
    
    populatingPhotos = true
    
    // Using our router to make the request by simply passing the page numer. 500px.com returns at most 50 photos in each API call
    Alamofire.request(Five100px.Router.PopularPhotos(self.currentPage)).responseJSON {
        response in
        
        if let JSON = response.result.value {
            //  Get a queue that isn't the main queue with a given priority , in our case "HIGH"
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
                
                // Retrieving the photo info, filtering NSFW contents and maping it into the PhotoInfo objects
                let photoInfos =  ((JSON as! NSDictionary).valueForKey("photos") as! [NSDictionary]).filter({
                    ($0["nsfw"] as! Bool) == false }).map {
                        PhotoInfo(id: ($0["id"] as! Int), url: $0["image_url"] as! String)
                }
                
                // Store the current number of photos before adding any new batch
                let lastItem = self.photos.count
                
                //If someone uploaded new photos to 500px.com before you scrolled, the next batch of photos you get might contain a few photos that you’d already downloaded. That’s why you defined var photos = NSMutableOrderedSet() as a set; since all items in a set must be unique, this guarantees you won’t show a photo more than once
                self.photos.addObjectsFromArray(photoInfos)
                
                // Create an aray of NSIndexPath objects to insert into collectionView
                let indexPaths = (lastItem..<self.photos.count).map { NSIndexPath(forItem: $0, inSection: 0)}
                
                // UIKit operations must be executed on the main queue
                dispatch_async(dispatch_get_main_queue()) {
                    self.collectionView!.insertItemsAtIndexPaths(indexPaths)
                }
                
                //Increment the current page, to fetch a new bacth of images with the next request
                self.currentPage++
                }
            }
        // Notify that we are no longer populating photos
        self.populatingPhotos = false
        }
    }
  
  func handleRefresh() {
    
    //The code below simply empties your current - All it does is empty your model (self.photos), reset the currentPage, and refresh the U
    refreshControl.beginRefreshing()
    
    self.photos.removeAllObjects()
    self.currentPage = 1
    
    self.collectionView!.reloadData()
    refreshControl.endRefreshing()
    populatePhotos()
    
  }
}

class PhotoBrowserCollectionViewCell: UICollectionViewCell {
  let imageView = UIImageView()
    var request: Alamofire.Request?
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    backgroundColor = UIColor(white: 0.1, alpha: 1.0)
    
    imageView.frame = bounds
    addSubview(imageView)
  }
}

class PhotoBrowserCollectionViewLoadingCell: UICollectionReusableView {
  let spinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    spinner.startAnimating()
    spinner.center = self.center
    addSubview(spinner)
  }
}

