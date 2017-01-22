//
//  PhotoDetailViewController.swift
//  Tumblr-Feed
//
//  Created by Gina Ratto on 1/11/17.
//  Copyright © 2017 Gina Ratto. All rights reserved.
//

import UIKit

class PhotoDetailViewController: UIViewController {

    var post: NSDictionary!
    
    @IBOutlet weak var photoImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let photos = post.value(forKey: "photos") as? [NSDictionary] {
            
            //get the image in its original size
            let imageUrlString = photos[0].value(forKeyPath: "original_size.url") as? String
            
            //check if imageUrlString is nil before unwrapping
            if let imageUrl = NSURL(string: imageUrlString!){
                //set the image of the cell
                photoImageView.setImageWith(imageUrl as URL)
            }
            
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
