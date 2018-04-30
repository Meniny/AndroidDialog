//
//  ViewController.swift
//  Sample
//
//  Created by Meniny on 2018-04-29.
//  Copyright © 2018年 Meniny Lab. All rights reserved.
//

import UIKit
import AndroidDialog
import JustLayout

extension Array {
    var random: Element? {
        let index = Int(arc4random_uniform(UInt32(self.count)))
        let element = self[index]
        return element
    }
}

func exec(_ closure: (UInt) -> Void, times: UInt = 1) {
    guard times > 0 else {
        closure(0)
        return
    }
    for i in 0..<times {
        closure(i)
    }
}

struct TableRow {
    let title: String
    let queueType: AndroidDialog.QueueType
    let coverType: AndroidDialog.CoverType
}

class ViewController: UIViewController {

    lazy var tableView: UITableView = {
        let t = UITableView.init()
        t.delegate = self
        t.dataSource = self
        t.tableFooterView = UIView.init()
        t.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        return t
    }()
    
    var dataSource: [TableRow] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = #colorLiteral(red: 0.99, green:0.78, blue:0.49, alpha:1.00)
        self.tableView.backgroundColor = self.view.backgroundColor
        self.view.translates(subViews: self.tableView)
        self.view.layout(0, |-0-self.tableView-0-|, 0)
        
        self.dataSource.append(contentsOf: [
            TableRow.init(title: "Default Queue\nTranslucent Cover", queueType: .default, coverType: .translucent(.black, 0.3)),
            TableRow.init(title: "No Queue\nNo Cover", queueType: .none, coverType: .none),
            TableRow.init(title: "Default Queue\nDark Blur Cover", queueType: .default, coverType: .blurred(.dark)),
            TableRow.init(title: "Default Queue\nLight Blur Cover", queueType: .default, coverType: .blurred(.light)),
            TableRow.init(title: "Custom Queue\nExtra Light Blur Cover", queueType: .custom(self.queue, self.semaphore), coverType: .blurred(.extraLight))
            ])
    }
    
    var queue = DispatchQueue.init(label: "SomeQueue")
    var semaphore = DispatchSemaphore.init(value: 1)
    
    public func alert(_ arg: String, to container: UIView?, queueType: AndroidDialog.QueueType, coverType: AndroidDialog.CoverType) {
        let dialog = AndroidDialog.init()
        dialog.setTitle("Alert [\(arg)]")
        dialog.setMessage("This is a message!!!\nWith multi-lines!O(∩_∩)O~\nAnd of couse emojis 😆")
        dialog.setPositiveButton("Done") { (d) in
            d.hide()
        }
        if [true, false].random ?? false {
            dialog.setNegativeButton("Cancel")
        }
        dialog.coverType = coverType
        dialog.show(to: container, animated: true, queue: queueType)
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = self.dataSource[indexPath.row]
        exec({ i in
            self.alert("\(i)", to: nil, queueType: row.queueType, coverType: row.coverType)
        }, times: 3)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        if cell == nil {
            cell = UITableViewCell.init(style: .default, reuseIdentifier: "Cell")
        }
        cell?.accessoryType = .disclosureIndicator
        cell?.textLabel?.numberOfLines = 0
        let row = self.dataSource[indexPath.row]
        cell?.textLabel?.text = row.title
        cell?.selectionStyle = .none
        return cell!
    }
}
