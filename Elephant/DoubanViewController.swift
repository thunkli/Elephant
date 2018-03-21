//
//  doubanViewController.swift
//  Elephant
//
//  Created by 李金标 on 15/11/3.
//  Copyright © 2015年 w3cmm. All rights reserved.
//

import UIKit

class DoubanViewController: UIViewController, UIWebViewDelegate {

    @IBOutlet weak var webView: UIWebView!
    var webUrl : NSString!
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let url = URL(string: self.webUrl as String)
        let request = URLRequest(url: url!)
        self.webView.loadRequest(request)
        self.webView.delegate = self
        // Do any additional setup after loading the view.
    }
    @IBAction func doRefresh(_ sender: AnyObject) {
        webView.reload()
    }
    func webViewDidFinishLoad(_ webView: UIWebView) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        print("finish")
    }
    func webView(_ webView: UIWebView, didFailLoadWithError error:Error) {
        print(error)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
