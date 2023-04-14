//
//  MiddleExpandCollectionViewViewController.swift
//  XYZSpecialCollectionView
//
//  Created by 大大东 on 2023/4/14.
//

import UIKit

class MiddleExpandCollectionViewViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
    
        let nomalSpace: CGFloat = 30
        let w: CGFloat = (self.view.bounds.size.width - nomalSpace * 3) / 3
        let h = w * CGFloat(114) / CGFloat(95) + CGFloat(25)

        let vvv = MiddleExpandCollectionView(delegate: self,
                                             itemSize: CGSizeMake(w, h),
                                             itemSpace: nomalSpace,
                                             maxScale: 1.3)
        vvv.frame = CGRect(x: 0, y: 200, width: self.view.bounds.size.width, height: h * 1.3)
        vvv.isLoop = true
        vvv.autoScroll = true
        vvv.registCollecitonViewCell(for: MExampleCell.self, reuseIdentifier: "cell")
        vvv.backgroundColor = .lightGray
        self.view.addSubview(vvv)
        vvv.reloadData([1, 2, 3, 4, 5, 6, 7, 8, 9, 10])
    }
}

extension MiddleExpandCollectionViewViewController: MiddleExpandCollectionViewDelegate {
    func cell(for _: Any, collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! MExampleCell
        cell.label.text = String(indexPath.row)
        return cell
    }

    func cellDidClick(with index: Int, inDataArr: [Any]) {
        print("点击了 : \(inDataArr[index])")
    }

    func cellWillDisplay(with index: Int, inDataArr: [Any]) {
        print("即将展现 : \(inDataArr[index])")
    }
}

class MExampleCell: UICollectionViewCell {
    let label = UILabel()
    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(label)
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 30)
        label.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        label.center = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        label.textAlignment = .center
        contentView.backgroundColor = .red
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
