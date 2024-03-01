//
//  AlignCollectionViewController.swift
//  XYZSpecialCollectionView
//
//  Created by 大大东 on 2024/3/1.
//

import UIKit

class AlignCollectionViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        view.addSubview(collcetionView)
        view.addSubview(collcetionView2)
        view.addSubview(collcetionView3)

        let rect = view.bounds
        var rect1 = CGRect(x: 0, y: 150, width: rect.size.width, height: 180)
        collcetionView.frame = rect1
        rect1.origin.y += 200
        collcetionView2.frame = rect1
        rect1.origin.y += 200
        collcetionView3.frame = rect1
    }

    private let dataTexts: [String] = [
        "一",
        "一二",
        "一二三",
        "一二三四",
        "一二三",
        "一二三四五六七八九",
        "一二三四五",
        "一二",
        "一二",
        "一二三",
        "一二三四五",
        "一",
        "一二",
        "六七八九",
        "一二",
    ]

    private lazy var collcetionView: UICollectionView = {
        let layout = AlignCollectionViewFollowLayout()
        layout.align = .left
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10

        let view = UICollectionView(frame: self.view.bounds, collectionViewLayout: layout)
        view.delegate = self
        view.dataSource = self
        view.register(CollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        view.backgroundColor = .red
        return view
    }()

    private lazy var collcetionView2: UICollectionView = {
        let layout = AlignCollectionViewFollowLayout()
        layout.align = .right
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10

        let view = UICollectionView(frame: self.view.bounds, collectionViewLayout: layout)
        view.delegate = self
        view.dataSource = self
        view.register(CollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        view.backgroundColor = .green
        return view
    }()

    private lazy var collcetionView3: UICollectionView = {
        let layout = AlignCollectionViewFollowLayout()
        layout.align = .center
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10

        let view = UICollectionView(frame: self.view.bounds, collectionViewLayout: layout)
        view.delegate = self
        view.dataSource = self
        view.register(CollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        view.backgroundColor = .yellow
        return view
    }()
}

extension AlignCollectionViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataTexts.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
        cell.label.text = dataTexts[indexPath.item]
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let text = (dataTexts[indexPath.item] as NSString)
        var size = text.boundingRect(with: CGSize(width: collectionView.bounds.size.width, height: 30),
                                     attributes: [.font: UIFont.systemFont(ofSize: 20)],
                                     context: nil).size
        size.width += 10
        return size
    }
}

class CollectionViewCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.addSubview(label)
        label.frame = self.contentView.bounds
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    lazy var label: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.black
        label.font = UIFont.systemFont(ofSize: 20)
        label.backgroundColor = .blue
        label.textAlignment = .center
        return label
    }()
}
