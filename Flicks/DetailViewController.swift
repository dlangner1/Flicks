//
//  DetailViewController.swift
//  Flicks
//
//  Created by Dustin Langner on 1/25/16.
//  Copyright © 2016 Dustin Langner. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    
    @IBOutlet weak var posterView: UIImageView!
 
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var overviewLabel: UILabel!
    
    var movie: NSDictionary!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let title = movie["title"] as? String
        titleLabel.text = title
        titleLabel.textColor = UIColor.orangeColor()
        
        let overview = movie["overview"] as? String
        overviewLabel.text = overview
        
        let baseUrl = "http://image.tmdb.org/t/p/w500"
        if let posterPath = movie["poster_path"] as? String {
            let imageUrl = NSURL(string: baseUrl + posterPath)
            posterView.setImageWithURL(imageUrl!)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

 
    }
    */

}
