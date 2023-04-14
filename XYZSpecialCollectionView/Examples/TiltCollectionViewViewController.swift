//
//  TiltCollectionViewViewController.swift
//  XYZSpecialCollectionView
//
//  Created by 大大东 on 2023/4/14.
//

import UIKit

class TiltCollectionViewViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        let tview = TiltCollectionView()
        tview.delegate = self
        tview.frame = CGRect(x: 0, y: 200, width: self.view.bounds.size.width, height: 220)
        tview.backgroundColor = .lightGray
        self.view.addSubview(tview)
        tview.reloadData([1, 2, 3, 4, 5, 6, 7, 8, 9, 10])
    }
}

extension TiltCollectionViewViewController: TiltCollectionViewDelegate {
    func cell(for idx: Int, _: Any, _ view: TiltCollectionView) -> TiltCollectionView.Cell {
        let cell: TExampleCell
        if let tcell = view.dequeueReusableCell() as? TExampleCell {
            cell = tcell
        } else {
            cell = TExampleCell()
        }

        cell.label.text = String(idx)
        return cell
    }

    func cellSize(for _: Any) -> CGSize {
        return CGSizeMake(150, 150)
    }

    func didScrollTo(_ idx: Int, _: Any) {
        print("did scroll to \(idx)")
    }

    func didClickWith(_ idx: Int, _: Any) {
        print("did click \(idx)")
    }
}

private class TExampleCell: TiltCollectionView.Cell {
    let label = UILabel()
    override init(frame: CGRect) {
        super.init(frame: frame)

        self.addSubview(label)
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 30)
        label.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        label.textAlignment = .center
        self.backgroundColor = .red
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        label.center = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
