//
//  MovieViewController.swift
//  Flicks
//
//  Created by Dustin Langner on 1/7/16.
//  Copyright © 2016 Dustin Langner. All rights reserved.
//
// TODO: add Reachability pod for networking error

import UIKit
import AFNetworking
import SwiftLoader

class MovieViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    var refreshControl: UIRefreshControl!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var networkErrorView: UIView!

    
    var config : SwiftLoader.Config = SwiftLoader.Config()
    
    var movies: [NSDictionary]?
    
    var filteredMovies: [NSDictionary]?
    
    var endpoint: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        self.tableView.backgroundColor = UIColor(white: 0.15, alpha: 1.0)
        
        networkErrorView.hidden = false

        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()

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
        self.tableView.insertSubview(refreshControl, atIndex: 0)
    
    }
    
    func loadingScreen() {
        
        config.size = 150
        config.spinnerColor = .redColor()
        config.foregroundColor = .blackColor()
        config.foregroundAlpha = 1.0
        SwiftLoader.setConfig(config)
    
    }
    
    @IBAction func didTapNetworkError(sender: UITapGestureRecognizer) {
        self.fetchMovieData()
    }
    
    func fetchMovieData() {
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string:"https://api.themoviedb.org/3/movie/\(endpoint)?api_key=\(apiKey)")
        let request = NSURLRequest(URL: url!)
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue())

                let task : NSURLSessionDataTask = session.dataTaskWithRequest(request,
                    completionHandler: { (dataOrNil, response, error) in
                        
                          self.refreshControl.endRefreshing()
                        
                        if let data = dataOrNil {
                            if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                                data, options:[]) as? NSDictionary {
                                    //NSLog("response: \(responseDictionary)")
                                    
                                    self.movies = responseDictionary["results"] as? [NSDictionary]
                                    self.filteredMovies = self.movies
                                    self.tableView.reloadData()
                                    
                                    self.refreshControl.endRefreshing()
                                    self.networkErrorView.hidden = true
                            }
                        } else {
                            self.networkErrorView.hidden = false
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
        if let posterPath = movie["poster_path"] as? String {
            let imageUrl = NSURL(string: baseUrl + posterPath)
            cell.posterView.setImageWithURL(imageUrl!)
        }
        cell.titelLabel.text = title
        cell.overviewLabel.text = overview
        
        cell.titelLabel.textColor = UIColor.orangeColor()
        cell.overviewLabel.textColor = UIColor.whiteColor()
        cell.backgroundColor = UIColor.clearColor()
    
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.lightGrayColor()
        cell.selectedBackgroundView = backgroundView

        return cell
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredMovies = movies
        } else {
            filteredMovies = movies?.filter({ (movie: NSDictionary) -> Bool in
                if let title = movie["title"] as? String {
                    if title.rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil {
                        
                        return  true
                    } else {
                        return false
                    }
                }
                return false
            })
        
        }
        self.tableView.reloadData()
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPathForCell(cell)
        let movie = movies![indexPath!.row]
        
        let detailViewController = segue.destinationViewController as! DetailViewController
        detailViewController.movie = movie
 
    }
    @IBAction func didTapView(sender: AnyObject) {
        view.endEditing(true)
    }
 
}
