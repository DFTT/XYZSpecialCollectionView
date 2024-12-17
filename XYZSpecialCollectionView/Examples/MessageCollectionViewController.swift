//
//  MessageCollectionViewController.swift
//  XYZSpecialCollectionView
//
//  Created by dadadongl on 2024/10/25.
//

import UIKit

private class DataItem {
    let string: String
    var size: CGSize = .zero

    init(string: String) {
        self.string = string
    }

    func saveSize(_ size: CGSize) {
        self.size = size
    }
}

class MessageCollectionViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        view.addSubview(collcetionView)

        let rect = view.bounds
        collcetionView.frame = CGRect(x: 0, y: 180, width: rect.size.width, height: 450)

        let tap = UITapGestureRecognizer(target: self, action: #selector(aa))
        view.addGestureRecognizer(tap)
    }

    @objc func aa() {
        dataTexts.append(DataItem(string: "\(dataTexts.count + 1)"))
        let idxp = IndexPath(row: dataTexts.count - 1, section: 0)

//        collcetionView.reloadData()
//        DispatchQueue.main.async {
//            self.collcetionView.scrollToItem(at: idxp, at: .bottom, animated: true)
//        }
//
//        return;

//        UIView.performWithoutAnimation {
        collcetionView.performBatchUpdates {
            collcetionView.insertItems(at: [idxp])
        } completion: { _ in
            self.collcetionView.scrollToItem(at: idxp, at: .bottom, animated: true)
        }
//        }
    }

    private var dataTexts: [DataItem] = [
        DataItem(string: "一"),
    ]

    private lazy var collcetionView: UICollectionView = {
        let layout = MessageCollectionFlowLayout()
        layout.minimumLineSpacing = 10

        let view = UICollectionView(frame: self.view.bounds, collectionViewLayout: layout)
        view.delegate = self
        view.dataSource = self
        view.register(CollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        view.backgroundColor = .red
        return view
    }()
}

extension MessageCollectionViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataTexts.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
        cell.label.text = dataTexts[indexPath.item].string
        cell.label.backgroundColor = .green.withAlphaComponent(0.6)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let item = dataTexts[indexPath.item]
        if item.size != .zero {
            return item.size
        }

        let w = collectionView.bounds.size.width
//        let text = dataTexts[indexPath.item]
//        var size = (text as NSString).boundingRect(with: CGSize(width: w, height: 1000),
//                                                   attributes: [.font: UIFont.systemFont(ofSize: 20)],
//                                                   context: nil).size
//        size.width = w
//        return size
        let size = CGSize(width: w, height: CGFloat(10 + Int(arc4random()) % 100))
        item.saveSize(size)
        return size
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        aa()
    }
}

private class CollectionViewCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(label)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = contentView.bounds
    }

    lazy var label: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.black
        label.font = UIFont.systemFont(ofSize: 20)
        label.textAlignment = .center
        return label
    }()
}
