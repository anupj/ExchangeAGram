//
//  FeedViewController.swift
//  ExchangeAGram
//
//  Created by Anup on 04/01/2015.
//  Copyright (c) 2015 Anup. All rights reserved.
//

import UIKit


/*
* Step 1 - This class was created after deleting the original ViewController class.
* It is a Cocoa Touch Class (under iOS)
*
* Step 3 - Now setup the our delegate and data source protocols for the CollectionView.
* Step 3.1 - Then ctrl drag from CollectionView in the Main.storyboard to Feed View Controller twice
* to let CollectionView know that the F V C is going to be both delegate and data source
* 
*
*/
class FeedViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    // Step 2 - This is the first thing we did after setting up the story board
    // with a UICollectionView, and a NavigationController
    // We created a ibOutlet by ctrl dragging from the CollectionView component to this class
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // UICollectionViewDataSource methods
    // Step 4 - confirm to the data source protocol
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    // Step 4.1 - continued
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    // Step 4.2 - continued
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        return UICollectionViewCell()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
