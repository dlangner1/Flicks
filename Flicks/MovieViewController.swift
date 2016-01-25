//
//  MovieViewController.swift
//  Flicks
//
//  Created by Dustin Langner on 1/7/16.
//  Copyright © 2016 Dustin Langner. All rights reserved.
//

import UIKit
import AFNetworking
import SwiftLoader

class MovieViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    var refreshControl: UIRefreshControl!
    
    @IBOutlet weak var tableView: UITableView!
 
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var networkErrorButton: UIButton!
    
    var config : SwiftLoader.Config = SwiftLoader.Config()
    
    var movies: [NSDictionary]?
    
    var filteredMovies: [NSDictionary]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.backgroundColor = UIColor(white: 0.15, alpha: 1.0)
        
        searchBar.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        
        self.loadingScreen()
        
        self.fetchMovieData()
        self.controlRefresh()

    }
    
    func controlRefresh() {
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        self.scrollView.insertSubview(refreshControl, atIndex: 0)
    
    }
    
    func loadingScreen() {
        
        config.size = 150
        config.spinnerColor = .redColor()
        config.foregroundColor = .blackColor()
        config.foregroundAlpha = 1.0
        SwiftLoader.setConfig(config)
    
    }
    
    @IBAction func networkErrorButtonPressed(sender: AnyObject) {
        self.onRefresh()
    }
    
    func fetchMovieData() {
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string:"https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")
        let request = NSURLRequest(URL: url!)
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue())
        
        self.networkErrorButton.backgroundColor = UIColor.darkGrayColor()
        self.networkErrorButton.titleLabel!.textColor = UIColor.whiteColor()
        
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                
                self.refreshControl.endRefreshing()
                
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            NSLog("response: \(responseDictionary)")
                            
                            self.movies = responseDictionary["results"] as? [NSDictionary]
                            self.filteredMovies = self.movies
                            self.networkErrorButton.hidden = true
                            self.tableView.reloadData()
                    }
                } else {
                    if error != nil {
                        self.networkErrorButton.hidden = false
                    }
                }
        });
        task.resume()
    
    
    
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        SwiftLoader.show(title: "Loading...", animated: true)
        SwiftLoader.hide()
        
    }
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    func onRefresh() {
        self.fetchMovieData()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let unwrappedFilteredMovies = filteredMovies {
            return unwrappedFilteredMovies.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        
        let movie = self.filteredMovies![indexPath.row]
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String
        
        let baseUrl = "http://image.tmdb.org/t/p/w500"
        let posterPath = movie["poster_path"] as! String
        let imageUrl = NSURL(string: baseUrl + posterPath)

        cell.titelLabel.text = title
        cell.overviewLabel.text = overview
        cell.posterView.setImageWithURL(imageUrl!)
        
        cell.titelLabel.textColor = UIColor.orangeColor()
        cell.overviewLabel.textColor = UIColor.whiteColor()
        cell.backgroundColor = UIColor.clearColor()

        return cell
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        filteredMovies = searchText.isEmpty ? movies : movies!.filter({(movie: NSDictionary) -> Bool in
            return (movie["title"] as! String).rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil
        })
        self.tableView.reloadData()
        
    }
 
}
