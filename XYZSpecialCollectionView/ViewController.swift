//
//  ViewController.swift
//  XYZSpecialCollectionView
//
//  Created by 大大东 on 2023/4/14.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var dataArr: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        dataArr.append("MiddleExpandCollectionView")
        dataArr.append("TiltCollectionView")

        let tabView = UITableView(frame: view.bounds, style: .plain)
        tabView.delegate = self
        tabView.dataSource = self
        view.addSubview(tabView)
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return dataArr.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let idStr = "cellid"

        var cell = tableView.dequeueReusableCell(withIdentifier: idStr)
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: idStr)
        }
        cell?.textLabel?.text = dataArr[indexPath.row]
        return cell!
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            navigationController?.pushViewController(MiddleExpandCollectionViewViewController(), animated: true)
        } else if indexPath.row == 1 {
            navigationController?.pushViewController(TiltCollectionViewViewController(), animated: true)
        } else {
            let stb = UIStoryboard(name: "LaunchScreen", bundle: .main)
            let ctl = stb.instantiateViewController(withIdentifier: "aaaaaa")
            navigationController?.pushViewController(ctl, animated: true)
        }
    }
}
