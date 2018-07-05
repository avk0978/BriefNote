//
//  ImageViewController.swift
//  Snote
//
//  Created by Andrey Kolpakov on 07.12.2017.
//  Copyright © 2017 Andrey Kolpakov. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    var image: UIImageView!
    
    override var prefersStatusBarHidden: Bool { return true }

    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image.image
        
        // Do any additional setup after loading the view.
    }

    
    @IBAction func exitImageVC(_ sender: UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
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
