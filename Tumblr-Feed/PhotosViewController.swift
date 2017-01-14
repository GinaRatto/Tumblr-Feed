//
//  PhotosViewController.swift
//  Tumblr-Feed
//
//  Created by Gina Ratto on 1/11/17.
//  Copyright © 2017 Gina Ratto. All rights reserved.
//

import UIKit
import AFNetworking

class PhotosViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    

    @IBOutlet weak var tableView: UITableView!
    
    var posts: [NSDictionary] = []
    
    // INFINTE SCROLL STUFF
    var isMoreDataLoading = false;
    var loadingMoreView:InfiniteScrollActivityView?
    var currentOffset = 0;
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // INFINITE SCROLL STUFF
        // Set up Infinite Scroll loading indicator
        let frame = CGRect(x: 0, y: tableView.contentSize.height, width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.isHidden = true
        tableView.addSubview(loadingMoreView!)
        
        var insets = tableView.contentInset;
        insets.bottom += InfiniteScrollActivityView.defaultHeight;
        tableView.contentInset = insets
        
        //initialize a UIRefreshController
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(refreshControl:)), for: UIControlEvents.valueChanged)
        // add refresh control to table view
        tableView.insertSubview(refreshControl, at: 0)
        
        tableView.dataSource = self
        tableView.delegate = self
     //   tableView.rowHeight = 240;
        
        let url = NSURL(string:"https://api.tumblr.com/v2/blog/humansofnewyork.tumblr.com/posts/photo?api_key=Q6vHoaVm5L1u2ZAW1fqv3Jw48gFzYVg9P0vH0VHl3GVy6quoGV&limit=20&offset=0")
        let request = NSURLRequest(url: url! as URL)
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate:nil,
            delegateQueue:OperationQueue.main
        )
        
        let task : URLSessionDataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) in
            if let data = data {
                if let responseDictionary = try! JSONSerialization.jsonObject(                                                                                with: data, options:[]) as? NSDictionary {                                                                                 print("responseDictionary: \(responseDictionary)")
                    // Recall there are two fields in the response dictionary, 'meta' and 'response'.
                    // This is how we get the 'response' field
                    let responseFieldDictionary = responseDictionary["response"] as! NSDictionary
                    // This is where you will store the returned array of posts in your posts property
                    self.posts = responseFieldDictionary["posts"] as! [NSDictionary]
                    //update table view to display new information
                    self.tableView.reloadData()
                    self.currentOffset = 20
                }
            }
        });
        task.resume()
    }
    
    // Makes a network request to get updated data
    // Updates the tableView with the new data
    // Hides the RefreshControl
    func refreshControlAction(refreshControl: UIRefreshControl) {

        let url = NSURL(string:"https://api.tumblr.com/v2/blog/humansofnewyork.tumblr.com/posts/photo?api_key=Q6vHoaVm5L1u2ZAW1fqv3Jw48gFzYVg9P0vH0VHl3GVy6quoGV&offset=0&limit=20")
        let myRequest = NSURLRequest(url: url! as URL)
        
        // Configure session so that completion handler is executed on main UI thread
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate:nil,
            delegateQueue:OperationQueue.main
        )
        
        let task : URLSessionDataTask = session.dataTask(with: myRequest as URLRequest, completionHandler: { (data, response, error) in
            
            // Use the new data to update the data source ...
            if let responseData = data {
                // ... Use the new data to update the data source ...
                if let responseDictionary = try! JSONSerialization.jsonObject(                                                                                with: responseData, options:[]) as? NSDictionary {                                                                                 print("responseDictionary: \(responseDictionary)")
                    // Recall there are two fields in the response dictionary, 'meta' and 'response'.
                    // This is how we get the 'response' field
                    let responseFieldDictionary = responseDictionary["response"] as! NSDictionary
                    // This is where you will store the returned array of posts in your posts property
                    self.posts.append(contentsOf: responseFieldDictionary["posts"] as! [NSDictionary])
                    //update table view to display new information
                    self.currentOffset = 20
                }
            }
            
            // Reload the tableView now that there is new data
            self.tableView.reloadData()
            refreshControl.endRefreshing()
        });
        task.resume()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //tells the tableview how many cells to create
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PhotoCell") as! PhotoCell

        let post = posts[indexPath.row]
        
        if let photos = post.value(forKey: "photos") as? [NSDictionary] {
            let imageUrlString = photos[0].value(forKeyPath: "original_size.url") as? String
            
            //check if imageUrlString is nil before unwrapping
            if let imageUrl = NSURL(string: imageUrlString!){
                //set the image of the cell
                cell.photoImageView.setImageWith(imageUrl as URL)
            }
        }
        return cell
    }
    
    //deselects the gray area after user pushes on the cell
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        //deselect of the gray cell
        tableView.deselectRow(at: indexPath, animated:true)
    }
    
    // INFINITE SCROLL STUFF
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (!isMoreDataLoading) {
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.isDragging) {
                isMoreDataLoading = true
                
                // Update position of loadingMoreView, and start loading indicator
                let frame = CGRect(x: 0, y: tableView.contentSize.height, width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
                
                loadingMoreView?.frame = frame
                loadingMoreView!.startAnimating()
                
                loadMoreData()
                print("load more data - scrollviewdidscroll)")
            }
            
        }
    }
    
    func loadMoreData() {
        
        print("calling load more data")
        
        // ... Create the NSURLRequest
        let url = NSURL(string:"https://api.tumblr.com/v2/blog/humansofnewyork.tumblr.com/posts/photo?api_key=Q6vHoaVm5L1u2ZAW1fqv3Jw48gFzYVg9P0vH0VHl3GVy6quoGV&offset=\(currentOffset)&limit=20")
        let urlString = url?.absoluteString
        let myRequest = NSURLRequest(url: url! as URL)
        
        
        // Configure session so that completion handler is executed on main UI thread
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate:nil,
            delegateQueue:OperationQueue.main
        )
        
        print ("task")
        let task : URLSessionDataTask = session.dataTask(with: myRequest as URLRequest, completionHandler:
            { (data, response, error) in
                print("update flag")
                // Update flag
                self.isMoreDataLoading = false
                
                // Stop the loading indicator
                self.loadingMoreView!.stopAnimating()
                
                if let responseData = data {
                    // ... Use the new data to update the data source ...
                    if let responseDictionary = try! JSONSerialization.jsonObject(                                                                                with: responseData, options:[]) as? NSDictionary {                                                                                 print("responseDictionary: \(responseDictionary)")
                        // Recall there are two fields in the response dictionary, 'meta' and 'response'.
                        // This is how we get the 'response' field
                        let responseFieldDictionary = responseDictionary["response"] as! NSDictionary
                        // This is where you will store the returned array of posts in your posts property
                        self.posts.append(contentsOf: responseFieldDictionary["posts"] as! [NSDictionary])
                        //update table view to display new information
                        self.currentOffset += 20
                    }
                }
                
                // Reload the tableView now that there is new data
                self.tableView.reloadData()
                print("reloading data - loadmoredata()")
        });
        task.resume()
    }
    
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPath(for: cell)
        let post = posts[(indexPath?.row)!]
        
        let detailViewController = segue.destination as! PhotoDetailViewController
        detailViewController.post = post
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
