//
//  ViewController.swift
//  Elephant
//
//  Created by admin on 15/10/24.
//  Copyright (c) 2015年 w3cmm. All rights reserved.
//

import UIKit

class ViewController:UITableViewController, NSURLConnectionDataDelegate {
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    //var refreshControl = UIRefreshControl()
    var dateFormatter = DateFormatter()
    //保存数据列表
    var objects = NSMutableArray()
    var datas : NSMutableData!
    var segementValue:String = ""
    var api = "//api.douban.com/v2/movie/in_theaters?apikey=0da7cb6c5ed3ec6528f762451c7bc52f&"
    @IBAction func indexChanged(_ sender: UISegmentedControl){
        switch segmentedControl.selectedSegmentIndex {
            case 0:
                api = "//api.douban.com/v2/movie/in_theaters?apikey=0da7cb6c5ed3ec6528f762451c7bc52f"
                self.startRequest()
            case 1:
                api = "//api.douban.com/v2/movie/coming_soon?apikey=0da7cb6c5ed3ec6528f762451c7bc52f"
                self.startRequest()
            default:
                break;
        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        //初始化UIRefreshControl
        //rc.attributedTitle = NSAttributedString(string: "下拉刷新")
        let rc = UIRefreshControl();
        rc.addTarget(self, action: #selector(ViewController.refreshTableView), for: UIControlEvents.valueChanged)
        self.refreshControl = rc
        self.startRequest()
        //NSThread.sleepForTimeInterval(1.0)
    }
    func refreshTableView() {
        if (self.refreshControl?.isRefreshing == true) {
            
            let now = Date()
            //print(self.dateFormatter.stringFromDate(now))
            let updateString = "最后更新：" + self.dateFormatter.string(from: now)
            self.refreshControl!.attributedTitle = NSAttributedString(string: updateString)
            
            //self.refreshControl?.attributedTitle = NSAttributedString(string: "加载中...")
            //self.refreshControl?.attributedTitle = NSAttributedString(string: "下拉刷新")
            self.refreshControl?.endRefreshing()
            self.startRequest()
        }
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.objects.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //返回的是UITableViewCell对象
        let cellIdentifier = "movieCell"
        let cell:CustomCell = (tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? CustomCell)!
        
        let dict = self.objects[(indexPath as NSIndexPath).row] as! NSDictionary

        let title = dict["title"] as! String
        
        //cell.movieTitle? .text = director + "《" + title + "》"
        cell.movieTitle? .text = title
        
        if let casts = dict["casts"] as? NSArray {
            
            if (casts.count>0) {
                var castsName = [String]()
                for key in casts {
                    castsName.append(key["name"] as! String)
                }
                cell.movieCasts? .text = castsName.joined(separator: " / ")
            } else {
                cell.movieCasts? .text = "未知"
            }
            
        } else {
            cell.movieCasts? .text = "未知"
        }
        if let movieRating = dict["rating"] as? NSDictionary {
            if let average = movieRating["average"] as? Float32 {
                cell.movieScore? .text = String(average)
            } else {
                cell.movieScore? .text = "0.0"
            }
        } else {
            cell.movieScore? .text = "0.0"
        }
        if let directors = dict["directors"] as? NSArray {
            if directors.count > 0 {
                if let movieHead = directors[0]["avatars"] as? NSDictionary {
                    let movieHeadImage = UIImage(data: try! Data(contentsOf: URL(string: movieHead.value(forKey: "medium") as! String)!))
                    cell.movieHead? .image = movieHeadImage
                    
                } else {
                    cell.movieHead? .image = UIImage(named: "director")
                }
            } else {
                cell.movieHead? .image = UIImage(named: "director")
            }
        } else {
            cell.movieHead? .image = UIImage(named: "director")
        }
        
        cell.movieHead.layer.cornerRadius = 8
        cell.movieHead.layer.masksToBounds = true
        
        return cell
    }
    
    func startRequest(){
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        var strURL = NSString(format:api as NSString)
        strURL = strURL.addingPercentEscapes(using: String.Encoding.utf8.rawValue)! as NSString
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
    }
    
    func connectionDidFinishLoading(_ connection: NSURLConnection) {
        
        let resDict = JSONSerialization.jsonObject(with: self.datas as Data, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary!
        
        if resDict != nil {
            self.reloadView(resDict!)
        }
    }
    
    // MARK: --处理通知
    func reloadView(_ res : NSDictionary) {
        //let count: NSNumber = res.objectForKey("count") as! NSNumber
        self.objects = res.object(forKey: "subjects") as! NSMutableArray
        self.tableView.reloadData()
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //选择表视图行时触发
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "ShowMovieDetail") {
            //Swift1.1 -> Swift1.2修改点 start
            let detailViewController = segue.destination as! DetailViewController//as改为as!
            let indexPath = self.tableView.indexPathForSelectedRow as IndexPath?
            let selectedIndex = (indexPath! as NSIndexPath).row
            let selectName = (self.objects[selectedIndex] as! NSDictionary)["title"] as! String
            detailViewController.id = (self.objects[selectedIndex] as! NSDictionary)["id"] as! String as NSString!
            detailViewController.title = selectName
            //Swift1.1 -> Swift1.2修改点 end
            
        }
        
    }


}

