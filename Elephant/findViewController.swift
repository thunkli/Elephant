//
//  findViewController.swift
//  Elephant
//
//  Created by 李金标 on 15/11/9.
//  Copyright © 2015年 w3cmm. All rights reserved.
//

import UIKit

@available(iOS 8.0, *)
class findViewController: UITableViewController, UISearchResultsUpdating, NSURLConnectionDataDelegate {

    
    var filteredTableData = [String]()
    
    var resultSearchController :UISearchController!
    
    var objects = NSMutableArray()
    var defaultObjects = NSMutableArray()
    var datas : NSMutableData!
    var defaultDatas : NSMutableData!
    var startNum = arc4random_uniform(240)
    var api = "//api.douban.com/v2/movie/search?apikey=0da7cb6c5ed3ec6528f762451c7bc52f&q="
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let hotSearch = "//api.douban.com/v2/movie/top250?apikey=0da7cb6c5ed3ec6528f762451c7bc52f&count=10&start=\(startNum)"
        
        resultSearchController = UISearchController(searchResultsController: nil)
        resultSearchController.searchResultsUpdater = self
        //resultSearchController.hidesNavigationBarDuringPresentation = false
        //设置开始搜索时背景显示与否
        resultSearchController.dimsBackgroundDuringPresentation = false
        resultSearchController.searchBar.searchBarStyle = UISearchBarStyle.minimal
        resultSearchController.searchBar.sizeToFit()
        self.tableView.tableHeaderView = resultSearchController.searchBar
        
        self.startRequest(hotSearch)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // 1
        // Return the number of sections.
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (resultSearchController.isActive) {
            return self.objects.count
        } else {
            //return self.tableData.count
            return self.defaultObjects.count
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //返回的是UITableViewCell对象
        let cellIdentifier = "searchCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
        if (resultSearchController.isActive) {
            let dict = self.objects[(indexPath as NSIndexPath).row] as! NSDictionary
            let title = dict["title"] as! String
            if let movieRating = dict["rating"] as? NSDictionary {
                if let average = movieRating["average"] as? Float32 {
                    cell.detailTextLabel? .text = String(average)
                }
            } else {
                cell.detailTextLabel? .text = "0.0"
            }
            
            cell.textLabel? .text = title
            
        }  else {
            
            let dict = self.defaultObjects[(indexPath as NSIndexPath).row] as! NSDictionary
            let title = dict["title"] as! String
            
            let movieRating = dict["rating"]
            let average = movieRating!["average"] as! Float32
            
            cell.textLabel? .text = title
            cell.detailTextLabel? .text = String(average)
        }
        
        return cell
    }
    
    
    func startRequest(_ url:String){
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        var strURL = NSString(format:url as NSString)
        strURL = strURL.addingPercentEscapes(using: String.Encoding.utf8.rawValue)! as NSString
        let url = URL(string: strURL as String)!
        
        let request = URLRequest(url: url)
        let connection = NSURLConnection(request:request,delegate:self)
        //nil 不是指针，它表示特定类型的值不存在
        if connection != nil {
            if (resultSearchController.isActive) {
                self.datas = NSMutableData()
            } else {
                //return self.tableData.count
                self.defaultDatas = NSMutableData()
            }
            
        }
    }
    // MARK: --NSURLConnection 回调方法
    func connection(_ connection: NSURLConnection, didReceive data: Data) {
        if (resultSearchController.isActive) {
            self.datas.append(data)
        } else {
            //return self.tableData.count
            self.defaultDatas.append(data)
        }
        
        //NSLog("请求完成...")
    }
    
    func connection(_ connection: NSURLConnection, didFailWithError error: Error) {
        NSLog("%@",error.localizedDescription)
    }
    
    func connectionDidFinishLoading(_ connection: NSURLConnection) {
        var resDict : NSDictionary!
        if (resultSearchController.isActive) {
            resDict = (try? JSONSerialization.jsonObject(with: self.datas as Data, options: JSONSerialization.ReadingOptions.allowFragments)) as! NSDictionary!
        } else {
            //return self.tableData.count
            resDict = (try? JSONSerialization.jsonObject(with: self.defaultDatas as Data, options: JSONSerialization.ReadingOptions.allowFragments)) as! NSDictionary!
        }
        if resDict != nil {
            self.reloadView(resDict)
        }
    }
    func reloadView(_ res : NSDictionary) {
        //let count: NSNumber = res.objectForKey("count") as! NSNumber
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        if ((res.object(forKey: "subjects") as! NSArray).count == 0){
//            let alertController = UIAlertController(title: "提示", message:
//                "没有搜索到结果", preferredStyle: UIAlertControllerStyle.Alert)
//            alertController.addAction(UIAlertAction(title: "确定", style: UIAlertActionStyle.Default,handler: nil))
//            
//            self.presentViewController(alertController, animated: true, completion: nil)
        } else {
            
            if (resultSearchController.isActive) {
                self.objects = res.object(forKey: "subjects") as! NSMutableArray
            }  else {
                self.defaultObjects = res.object(forKey: "subjects") as! NSMutableArray

            }
            self.tableView.reloadData()
        }
    }
    //api.douban.com/v2/movie/search?q=%E5%BC%A0%E8%89%BA%E8%B0%8B
    
    //过滤结果集方法
    func filterContentForSearchText(_ searchText: NSString) {
        if(searchText.length == 0) {
            self.tableView.reloadData()
            //查询所有
            return
        }
        if (!resultSearchController.isActive) {
            self.tableView.reloadData()
            return
        }
        self.startRequest(api+(searchText as String))
        
    }
    //获得焦点，成为第一响应者
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        return true
    }
    
    //点击键盘上的搜索按钮
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("search")
        //resignFirstResponder
    }
    //点击搜索栏取消按钮
    func searchBarCancelButtonClicked(_ searchBar : UISearchBar) {
        print("cancel")
        //查询所有
    }
    func updateSearchResults(for searchController: UISearchController) {
        //删除数组中所有元素
        //self.objects.removeAll(keepCapacity: false)
        self.filterContentForSearchText(searchController.searchBar.text! as NSString)
    }
    
    //选择表视图行时触发
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "ShowMovieDetail") {
            //resultSearchController.searchBar.resignFirstResponder()
            //Swift1.1 -> Swift1.2修改点 start
            let detailViewController = segue.destination as! DetailViewController//as改为as!
            let indexPath = self.tableView.indexPathForSelectedRow as IndexPath?
            let selectedIndex = (indexPath! as NSIndexPath).row
            var selectName = ""
            if (resultSearchController.isActive) {
                selectName = (self.objects[selectedIndex] as! NSDictionary)["title"] as! String
                detailViewController.id = (self.objects[selectedIndex] as! NSDictionary)["id"] as! String as NSString!
            }  else {
                selectName = (self.defaultObjects[selectedIndex] as! NSDictionary)["title"] as! String
                detailViewController.id = (self.defaultObjects[selectedIndex] as! NSDictionary)["id"] as! String as NSString!
            }
            //释放搜索
            resultSearchController.isActive = false
            
            detailViewController.title = selectName
            
            //Swift1.1 -> Swift1.2修改点 end
            
        }
        
    }
    
}
