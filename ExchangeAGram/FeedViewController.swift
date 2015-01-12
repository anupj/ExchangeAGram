//
//  FeedViewController.swift
//  ExchangeAGram
//
//  Created by Anup on 04/01/2015.
//  Copyright (c) 2015 Anup. All rights reserved.
//

import UIKit
import MobileCoreServices
import CoreData
import MapKit

/*
* Step 1 - This class was created after deleting the original ViewController class.
* It is a Cocoa Touch Class (under iOS)
*
* Step 3 - Now setup the our delegate and data source protocols for the CollectionView.
* Step 3.1 - Then ctrl drag from CollectionView in the Main.storyboard to Feed View Controller twice
* to let CollectionView know that the F V C is going to be both delegate and data source
* 
* Step 7.1 - Now we are confirming to more delegates so that we can assign FVC instance as a delegate
* to UIImagePickerController
*/
class FeedViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate {
    
    // Step 2 - This is the first thing we did after setting up the story board
    // with a UICollectionView, and a NavigationController
    // We created a ibOutlet by ctrl dragging from the CollectionView component to this class
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    // Step 12 -  manually construct an NSFetchRequest, which will "describe search criteria used to retrieve data from persistent store." By doing this, we will get a good look at the inner workings of the class. see 12.1 below
    var feedArray: [AnyObject] = [] // FeeItem array
    
    // Location manager to be used with MapKit
    var locationManager: CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set background image
        let backgroundImage = UIImage(named: "AutumnBackground")
        self.view.backgroundColor = UIColor(patternImage: backgroundImage!)
        
        // setup the location manager
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        
        locationManager.distanceFilter = 100.0
        locationManager.startUpdatingLocation()
    }
    
    override func viewDidAppear(animated: Bool) {
        // Step 12.1 - get appdelegate, create nsfetchrequest and assign to feedarray
        let request = NSFetchRequest(entityName: "FeedItem")
        let appDelegate:AppDelegate = (UIApplication.sharedApplication().delegate as AppDelegate)
        let context:NSManagedObjectContext = appDelegate.managedObjectContext!
        feedArray = context.executeFetchRequest(request, error: nil)!
        collectionView.reloadData()
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // UIImageViewPickerControllerDelegate
    // Step 9 - Now, we are going to implement one of the UIImagePickerController delegate functions which will determine which photo we are selecting from the camera or photo library.
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        let image = info[UIImagePickerControllerOriginalImage] as UIImage
        
        // Step 11 - get jpeg representation, then create feed item instance
        // then save context
        let imageData = UIImageJPEGRepresentation(image, 1.0)
        // This was done after updating the Core Data Model by adding the thumbNail field
        let thumbNailData = UIImageJPEGRepresentation(image, 0.1)
        
        let managedObjectContext = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext
        let entityDescription = NSEntityDescription.entityForName("FeedItem", inManagedObjectContext: managedObjectContext!)
        let feedItem = FeedItem(entity: entityDescription!, insertIntoManagedObjectContext: managedObjectContext!)
        feedItem.image = imageData
        feedItem.caption = "Test Caption"
        feedItem.thumbNail = thumbNailData
        
        // add location information

        feedItem.latitude = locationManager.location.coordinate.latitude
        feedItem.longitude = locationManager.location.coordinate.longitude
        
        feedItem.uniqueID = NSUUID().UUIDString
        feedItem.filtered = false
        
        (UIApplication.sharedApplication().delegate as AppDelegate).saveContext()
        
        // added this in step 13.2
        feedArray.append(feedItem)
        
        // added this line in step 9
        self.dismissViewControllerAnimated(true, completion: nil)
        
        // added this in step 13.3
        self.collectionView.reloadData()

    }
    
    
    // UICollectionViewDataSource methods
    // Step 4 - confirm to the data source protocol
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    // Step 4.1 - continued
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // Step 13 - change from 1 to proper feedArray count
        return feedArray.count
    }
    
    // Step 4.2 - continued
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        // Step 13.1 
        var cell:FeedCell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as FeedCell
        let thisItem = feedArray[indexPath.row] as FeedItem
        
        if thisItem.filtered == true {
            let returnedImage = UIImage(data: thisItem.image)!
            let image = UIImage(CGImage: returnedImage.CGImage, scale: 1.0, orientation: UIImageOrientation.Right)
            cell.imageView.image = image
        }
        else {
            cell.imageView.image = UIImage(data: thisItem.image)
        }
        
        //cell.imageView.image = UIImage(data: thisItem.image)
        cell.captionLabel.text = thisItem.caption
        
        return cell
    }

    
    @IBAction func profileTapped(sender: UIBarButtonItem) {
        self.performSegueWithIdentifier("profileSegue", sender: nil)
    }
    
    // Step 6 - linked the camera button item to this action below
    // Step 6.1 - then go to the Proj settings and add MobileCoreServices.framework, then import it at the top of the class
    //
    @IBAction func snapBarButtonItemTapped(sender: UIBarButtonItem) {
        // Step 7 - add the code below to create and use instance of UIImagePickerController
        // which is sub class of Navigation controller which means that we have to confirm to 
        // NavigationControllerDelegate
        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)) {
            var cameraController = UIImagePickerController()
            cameraController.delegate = self // added this as self since FVC confirms to required delegates now
            cameraController.sourceType = UIImagePickerControllerSourceType.Camera
            // Step 7.2 now specify that the media type your cam controller is going to support is Images
            let mediaTypes: [AnyObject] = [kUTTypeImage]
            cameraController.mediaTypes = mediaTypes // these 2 lines are pretty much copy  and paste to specify image media types
            cameraController.allowsEditing = false // we don't want user to edit the images
            self.presentViewController(cameraController, animated: true, completion: nil)
        }
        // Step 8 - if no camera is available select image from Photo Library
        else if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary)) {
            var photoLibraryController = UIImagePickerController()
            photoLibraryController.delegate = self
            photoLibraryController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            let mediaTypes: [AnyObject] = [kUTTypeImage]
            photoLibraryController.mediaTypes = mediaTypes
            photoLibraryController.allowsEditing = false
            self.presentViewController(photoLibraryController, animated: true, completion: nil)
        }
        // Step 8.1 - otherwise just show an error message
        else {
            var alertController = UIAlertController(title: "Alert", message: "Your device does not support the camera or photo library", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    // step 14.1 (14 is in FilterViewController) 
    // UICollectionViewDelegate
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let thisItem = feedArray[indexPath.row] as FeedItem
        // step 14.2: Instead of using prepareForSegue, this is an alternate (and in this case) only
        // way to pass our feedItem from FVC to FilterViewController
        var filterVC = FilterViewController()
        filterVC.feedItem = thisItem
        
        self.navigationController?.pushViewController(filterVC, animated: false)
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        println("locations = \(locations)")
    }
    
    

}
