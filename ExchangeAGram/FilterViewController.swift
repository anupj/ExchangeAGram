//
//  FilterViewController.swift
//  ExchangeAGram
//
//  Created by Anup on 04/01/2015.
//  Copyright (c) 2015 Anup. All rights reserved.
//

import UIKit

class FilterViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    // step 14 - added this class and the new variable 
    var feedItem: FeedItem!
    
    // step 15 - we are now making collection views in our code
    var collectionView: UICollectionView!
    
    // step 18.1 - added this constant to use them in the CIFilters instantiation
    let kIntensity = 0.7
    
    // step 19
    var context:CIContext = CIContext(options: nil)
    
    // step 20 
    var filters:[CIFilter] = []
    
    let placeHolderImage = UIImage(named: "Placeholder")
    
    // this temporary directory is used for caching
    let tmp = NSTemporaryDirectory()


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 150.0, height: 150.0)
        collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        collectionView.dataSource = self // you can do this because FilterVC confirms to data source protocol
        collectionView.delegate = self // you can do this because FilterVC confirms to view delegate protocol
        
        // step 17 - register the filtercell class with this collection view
        collectionView.registerClass(FilterCell.self, forCellWithReuseIdentifier: "MyCell")
        
        
        // step 15.2 - setup background color and add a subView
        collectionView.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(collectionView)
        
        // step 20.1 initialise the filters
        filters = photoFilters()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // step 15.1 added this to confirm to the datasource protocol
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // step 20.2 - return the number of filters
        return filters.count
    }
    
    // step 15.1 added this to confirm to the datasource protocol
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell: FilterCell = collectionView.dequeueReusableCellWithReuseIdentifier("MyCell", forIndexPath: indexPath) as FilterCell
        
        cell.imageView.image = placeHolderImage
        
        // Since displaying the image on the phone adds a significant lag, we will use GCD to do our image
        // filtering
        let filterQueue: dispatch_queue_t = dispatch_queue_create("filter queue", nil)
        // this will run the code in the closure in a seperate thread
        dispatch_async(filterQueue, { () -> Void in
            let filterImage = self.getCachedImage(indexPath.row)
            
            // now add this to the main thread
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                cell.imageView.image = filterImage
            })
        })
        
        return cell
    }
    
    // UICollectionViewDelegate
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        createUIAlertController(indexPath)
        
    }
    
    // UI Alert Controller Helper functions
    func createUIAlertController (indexPath : NSIndexPath) {
        let alert = UIAlertController(title: "Photo Options", message: "Please choose an option", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.placeholder = "Add Caption!"
            textField.secureTextEntry = false
        }
        
        // first we are going to create a variable to grab the text from the text field input
        var text:String
        let textField = alert.textFields![0] as UITextField
        
        // now we need to add actions to the UIAlertController
        // add photo action
        let photoAction = UIAlertAction(title: "Post photo to Facebook with caption", style: UIAlertActionStyle.Destructive) { (UIAlertAction) -> Void in
            self.shareToFacebook(indexPath)
            var text = textField.text
            self.saveFilterToCoreData(indexPath, caption: text)
        }
        alert.addAction(photoAction)
        
        // save photo action
        let saveFilterAction = UIAlertAction(title: "Save Filter without posting on Facebook", style: UIAlertActionStyle.Default) { (UIAlertAction) -> Void in
            var text = textField.text
            self.saveFilterToCoreData(indexPath, caption: text)
        }
        alert.addAction(saveFilterAction)
        
        // cancel photo action
        let cancelAction = UIAlertAction(title: "Select another Filter", style: UIAlertActionStyle.Cancel) { (UIAlertAction) -> Void in
        }
        alert.addAction(cancelAction)
        
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    // save the filter image to core data
    func saveFilterToCoreData( indexPath: NSIndexPath, caption: String) {
        
        let filterImage = self.filteredImageFromImage(self.feedItem.image
            , filter: self.filters[indexPath.row])
        let imageData = UIImageJPEGRepresentation(filterImage, 1.0)
        self.feedItem.image = imageData
        let thumbNailData = UIImageJPEGRepresentation(filterImage, 0.1)
        self.feedItem.thumbNail = thumbNailData
        self.feedItem.caption = caption
        self.feedItem.filtered = true
        (UIApplication.sharedApplication().delegate as AppDelegate).saveContext()
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    // share photo to facebook
    func shareToFacebook (indexPath: NSIndexPath) {
        let filterImage = self.filteredImageFromImage(self.feedItem.image
            , filter: self.filters[indexPath.row])
        let photos: NSArray = [filterImage]
        var params = FBPhotoParams()
        
        FBDialogs.presentShareDialogWithPhotoParams(params, clientState: nil) { (call, result, error) -> Void in
            if (result? != nil) {
                println(result)
            } else {
                println(error)
            }
        }
    }
    
    // setp 18 - add a bunch of CI Filters in a helper function
    // List of core image filters can be found here:
    // https://developer.apple.com/library/mac/documentation/GraphicsImaging/Reference/CoreImageFilterReference/index.html
    // Helper functions
    
    func photoFilters() -> [CIFilter] {
        // step 18
        let blur = CIFilter(name: "CIGaussianBlur")
        let instant = CIFilter(name: "CIPhotoEffectInstant")
        let noir = CIFilter(name: "CIPhotoEffectNoir")
        let transfer = CIFilter(name: "CIPhotoEffectTransfer")
        let unsharpen = CIFilter(name: "CIUnsharpMask")
        let monochrome = CIFilter(name: "CIColorMonochrome")
        
        // step 18.1 add more filters 
        let colorControls = CIFilter(name: "CIColorControls")
        colorControls.setValue(0.5, forKey: kCIInputSaturationKey)
        
        let sepia = CIFilter(name: "CISepiaTone")
        sepia.setValue(kIntensity, forKey: kCIInputIntensityKey)
        
        let colorClamp = CIFilter(name: "CIColorClamp")
        colorClamp.setValue(CIVector(x: 0.9, y: 0.9, z: 0.9, w: 0.9), forKey: "inputMaxComponents")
        colorClamp.setValue(CIVector(x: 0.2, y: 0.2, z: 0.2, w: 0.2), forKey: "inputMinComponents")
        
        // step 18.2 add composite filters
        let composite = CIFilter(name: "CIHardLightBlendMode")
        composite.setValue(sepia.outputImage, forKey: kCIInputImageKey)
        
        let vignette = CIFilter(name: "CIVignette")
        vignette.setValue(composite.outputImage, forKey: kCIInputImageKey)
        
        vignette.setValue(kIntensity * 2, forKey: kCIInputIntensityKey)
        vignette.setValue(kIntensity * 30, forKey: kCIInputRadiusKey)
        
        return [blur, instant, noir, transfer, unsharpen, monochrome, colorControls, sepia, colorClamp, composite, vignette]
        
    }
    
    // step 19.1 created another helper function that'll filter a given image
    func filteredImageFromImage (imageData: NSData, filter: CIFilter) -> UIImage {
        
        let unfilteredImage = CIImage(data: imageData)
        filter.setValue(unfilteredImage, forKey: kCIInputImageKey)
        let filteredImage:CIImage = filter.outputImage
        
        let extent = filteredImage.extent()
        let cgImage:CGImageRef = context.createCGImage(filteredImage, fromRect: extent)
        
        let finalImage = UIImage(CGImage: cgImage)
        
        return finalImage!
    }
    
    
    // this function is used to cache the image in a folder
    func cacheImage(imageNumber: Int) {
        let fileName = "\(feedItem.uniqueID)\(imageNumber)"
        let uniquePath = tmp.stringByAppendingPathComponent(fileName)
        if !NSFileManager.defaultManager().fileExistsAtPath(uniquePath) {
            let data = self.feedItem.thumbNail
            let filter = self.filters[imageNumber]
            let image = filteredImageFromImage(data, filter: filter)
            UIImageJPEGRepresentation(image, 1.0).writeToFile(uniquePath, atomically: true)
        }
    }
    
    // this function is used to retrieve the image from the cache
    // if it is available OR add it to the cache otherwise
    func getCachedImage( imageNumber: Int) -> UIImage {
        let fileName = "\(feedItem.uniqueID)\(imageNumber)"
        let uniquePath = tmp.stringByAppendingPathComponent(fileName)
        var image: UIImage
        
        if NSFileManager.defaultManager().fileExistsAtPath(uniquePath) {
            var returnedImage = UIImage(contentsOfFile: uniquePath)!
            image = UIImage(CGImage: returnedImage.CGImage, scale: 1.0, orientation: UIImageOrientation.Right)!
        }
        else {
            self.cacheImage(imageNumber)
            var returnedImage = UIImage(contentsOfFile: uniquePath)!
            image = UIImage(CGImage: returnedImage.CGImage, scale: 1.0, orientation: UIImageOrientation.Right)!
        }
        
        return image
        
    }
    
    

    

}
