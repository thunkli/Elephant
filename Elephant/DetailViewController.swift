//
//  DetailViewController.swift
//  Elephant
//
//  Created by admin on 15/10/24.
//  Copyright (c) 2015年 w3cmm. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,NSURLConnectionDataDelegate {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var detailPoster: UIImageView!
    //@IBOutlet weak var detailSummary: UITextView!
    @IBOutlet weak var movieDetailTable: UITableView!
    var id : NSString!
    var objects : NSDictionary!
    var customDatas = [Dictionary<String,String>]()
    var datas : NSMutableData!
    override func viewDidLoad() {
        super.viewDidLoad()
        movieDetailTable.dataSource = self
        movieDetailTable.delegate = self
        
        self.startRequest()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.contentView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 600)
        self.scrollView.contentSize = CGSize(width: self.view.frame.size.width, height: 600)
    }
    
    
    func startRequest(){
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        var strURL = NSString(format: ("//api.douban.com/v2/movie/subject/" + String(self.id) + "?apikey=0da7cb6c5ed3ec6528f762451c7bc52f"))
        strURL = strURL.addingPercentEscapes(using: String.Encoding.utf8)!
        let url = URL(string: strURL as String)!
        
        let request = URLRequest(url: url)
        let connection = NSURLConnection(request:request,delegate:self)
        //nil 不是指针，它表示特定类型的值不存在
        if connection != nil {
            self.datas = NSMutableData()
        }
    }
    // MARK: --NSURLConnection 回调方法
    func connection(_ connection: NSURLConnection, didReceive data: Data) {
        self.datas.append(data)
        //NSLog("请求完成...")
    }
    
    func connection(_ connection: NSURLConnection, didFailWithError error: Error) {
        NSLog("%@",error.localizedDescription)
        //MovieDetailView.dataSource = customDatas
    }
    
    func connectionDidFinishLoading(_ connection: NSURLConnection) {
        
        let resDict = (try? JSONSerialization.jsonObject(with: self.datas as Data, options: JSONSerialization.ReadingOptions.allowFragments)) as! NSDictionary!
        
        if resDict != nil {
            self.reloadView(resDict!)
        }
    }
    
    //告知视图，有多少个section需要加载到table里
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    //告知controller每个section需要加载多少个单元或多少行
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return customDatas.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:CustomDetailCell = tableView.dequeueReusableCell(withIdentifier: "movieDetailTableCell", for: indexPath) as! CustomDetailCell

        let dict = self.customDatas[(indexPath as NSIndexPath).row] as NSDictionary

        cell.detailKey!.text = (dict["key"] as! String) + ":"
        cell.detailValue? .text = dict["value"] as? String
        
        return cell
    }
    
    
    // MARK: --处理通知
    func reloadView(_ res : NSDictionary) {
        //let count: NSNumber = res.objectForKey("count") as! NSNumber
        self.objects = res
        
        
        if let directors = res["directors"] as? NSArray {
            
            if let directorsName = directors[0]["name"] as? String {
                
                customDatas.append(["key":"导演","value":directorsName])
            }
        }
        
        if let year = res["year"] as? String {
            customDatas.append(["key":"上映日期","value":year])
        }
        
        if let casts = res["casts"] as? NSArray {
            
            if (casts.count>0) {
                var castsName = [String]()
                for key in casts {
                    castsName.append(key["name"] as! String)
                }
                customDatas.append(["key":"主演","value":castsName.joined(separator: " / ")])
            } else {
                customDatas.append(["key":"主演","value":"未知"])
            }
            
        } else {
            customDatas.append(["key":"主演","value":"未知"])
        }
        
        if let genres = res["genres"] as? NSArray {
            
            if (genres.count > 0 ){
                var genresName = [String]()
                for key in genres {
                    genresName.append(key as! String)
                }
                customDatas.append(["key":"类型","value":genresName.joined(separator: " / ")])
            }

        }

        if let movieRating = res["rating"] as? NSDictionary {
            
            if let average = movieRating["average"] as? Float32 {
                customDatas.append(["key":"评分","value":String(average)])
            }
            
        }
        if let ratings_count = res["ratings_count"] as? Float32 {
            customDatas.append(["key":"评分人数","value":String(format: "%.0f", ratings_count)])
        }
        if let wish_count = res["wish_count"] as? Float32 {
            customDatas.append(["key":"想看人数","value":String(format: "%.0f", wish_count)])
        }
        if let collect_count = res["collect_count"] as? Float32 {
            customDatas.append(["key":"看过人数","value":String(format: "%.0f", collect_count)])
        }
        movieDetailTable.reloadData()
        
        if let posterImages = res["images"] as? NSDictionary {
            let detailPosterString = UIImage(data: try! Data(contentsOf: URL(string: posterImages.object(forKey: "large") as! String)!))
            detailPoster.image = detailPosterString
        }
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showDouban") {
            //Swift1.1 -> Swift1.2修改点 start
            let doubanView = segue.destination as! DoubanViewController
            doubanView.webUrl = self.objects["mobile_url"] as! String as NSString!
            //Swift1.1 -> Swift1.2修改点 end
            
        }
    }
    
    
}
