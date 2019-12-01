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
                let recipe = DataObject(name: day[dine_type]!.name, children: [], details: day[dine_type]!.description)
                let name = "\(dine_type.capitalized) \(day[dine_type]!.portion) portions of "
                dayData.append(DataObject(name: name, children: [recipe]))
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
    
    func treeView(_ treeView: RATreeView, cellForItem item: Any?) -> UITableViewCell {
        let cell = treeView.dequeueReusableCell(withIdentifier: String(describing: TreeTableViewCell.self)) as! TreeTableViewCell
        let item = item as! DataObject
        
        let level = treeView.levelForCell(forItem: item)
//        let detailsText = "Number of children \(item.children.count)"
        cell.selectionStyle = .none
        cell.setup(withTitle: item.name, detailsText: item.details, level: level, additionalButtonHidden: false)
        cell.additionButtonActionBlock = { [weak treeView] cell in
            guard let treeView = treeView else {
                return;
            }
            let item = treeView.item(for: cell) as! DataObject
            let newItem = DataObject(name: "Added value")
            item.addChild(newItem)
            treeView.insertItems(at: IndexSet(integer: item.children.count-1), inParent: item, with: RATreeViewRowAnimationNone);
            treeView.reloadRows(forItems: [item], with: RATreeViewRowAnimationNone)
        }
        return cell
    }
    
    //MARK: RATreeView delegate
    func treeView(_ treeView: RATreeView, commit editingStyle: UITableViewCell.EditingStyle, forRowForItem item: Any) {
        guard editingStyle == .delete else { return; }
        let item = item as! DataObject
        let parent = treeView.parent(forItem: item) as? DataObject
        
        let index: Int
        if let parent = parent {
            index = parent.children.firstIndex(where: { dataObject in
                return dataObject === item
            })!
            parent.removeChild(item)
            
        } else {
            index = self.data.firstIndex(where: { dataObject in
                return dataObject === item;
            })!
            self.data.remove(at: index)
        }
        
        self.treeView.deleteItems(at: IndexSet(integer: index), inParent: parent, with: RATreeViewRowAnimationRight)
        if let parent = parent {
            self.treeView.reloadRows(forItems: [parent], with: RATreeViewRowAnimationNone)
        }
    }
}
