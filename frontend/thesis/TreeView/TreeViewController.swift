//
//  TreeViewController.swift
//  thesis
//
//  Created by Mac on 2019. 11. 30..
//  Copyright © 2019. Mac. All rights reserved.
//

import UIKit
import RATreeView

class TreeViewController: UIViewController, RATreeViewDelegate, RATreeViewDataSource {
    
    var treeView : RATreeView!
    var data : [DataObject] = []
    var editButton : UIBarButtonItem!
    var selectedText: String = ""
    
    convenience init() {
        self.init(nibName : nil, bundle: nil)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        data = self.initData()
        
        view.backgroundColor = .white
        
        title = "Diet"
        setupTreeView()
        print("viewDidLoad")
    }
    
    func initData() -> [DataObject] {
        var data = [DataObject]()

        var i = 1;
        for day in UserData.shared.diet.days {
            var dayData = [DataObject]()
            for dine_type in ["breakfast", "lunch", "dinner"] {
                var recipes = [DataObject]()
                var name = ""
                if day[dine_type]?.count == 1,
                    day[dine_type]![0].portion != 1 {
                    name = "\(dine_type.capitalized) \(day[dine_type]![0].portion) portions of "
                } else {
                    name = "\(dine_type.capitalized)"
                }
                for (r) in day[dine_type]! {
                    let recipe = DataObject(name: r.name, children: [], details: r.description)
                    recipes.append(recipe)
                }
                
                dayData.append(DataObject(name: name, children: recipes))
            }
            data.append(DataObject(name: "Day \(String(i))", children: dayData))
            i += 1
        }
        
        return data
    }
    
    func setupTreeView() {
        treeView = RATreeView(frame: view.bounds)
        treeView.register(UINib(nibName: String(describing: TreeTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: TreeTableViewCell.self))
        treeView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        treeView.estimatedRowHeight = 600
        treeView.rowHeight = UITableView.automaticDimension
        treeView.delegate = self;
        treeView.dataSource = self;
        treeView.treeFooterView = UIView()
        treeView.backgroundColor = .clear
        view.addSubview(treeView)
    }
    
    //MARK: RATreeView data source
    func treeView(_ treeView: RATreeView, numberOfChildrenOfItem item: Any?) -> Int {
        if let item = item as? DataObject {
            return item.children.count
        } else {
            return self.data.count
        }
    }
    
    func treeView(_ treeView: RATreeView, child index: Int, ofItem item: Any?) -> Any {
        if let item = item as? DataObject {
            return item.children[index]
        } else {
            return data[index] as AnyObject
        }
    }
    
    func treeView(_ treeView: RATreeView, didSelectRowForItem item: Any) {
        let item = item as! DataObject
        
        if item.details != "" {
            selectedText = item.details
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "segueDetails", sender: self)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueDetails" {
            let dc = segue.destination as! DetailsController
            dc.detailsText = selectedText
        }
    }
    
    func treeView(_ treeView: RATreeView, cellForItem item: Any?) -> UITableViewCell {
        let cell = treeView.dequeueReusableCell(withIdentifier: String(describing: TreeTableViewCell.self)) as! TreeTableViewCell
        let item = item as! DataObject
        
        let level = treeView.levelForCell(forItem: item)
        cell.selectionStyle = .none
        cell.setup(withTitle: item.name, detailsText: item.details, level: level, additionalButtonHidden: false)
        
        return cell
    }
}

