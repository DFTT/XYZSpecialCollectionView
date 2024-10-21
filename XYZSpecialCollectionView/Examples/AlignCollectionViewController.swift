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
        var rect1 = CGRect(x: 0, y: 100, width: rect.size.width, height: 150)
        collcetionView.frame = rect1
        rect1.origin.y += 160
        collcetionView2.frame = rect1
        rect1.origin.y += 160
        collcetionView3.frame = rect1

        shortCollectionView.insert(collcetionView4)
        shortCollectionView.insert(collcetionView5)

        view.addSubview(collcetionView4)
        rect1.origin.y += 160
        rect1.size.height = 40
        collcetionView4.frame = rect1

        view.addSubview(collcetionView5)
        rect1.origin.y += 50
        rect1.size.height = 40
        collcetionView5.frame = rect1
    }

    private var shortCollectionView = Set<UICollectionView>()
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

    private var shortDataTexts: [String] = [
        "1",
        "12",
        "123",
        "1234",
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

    private lazy var collcetionView4: UICollectionView = {
        let layout = AlignCollectionViewFollowLayout()
        layout.align = .center
        layout.minimumInteritemSpacing = 10
        layout.scrollDirection = .horizontal

        let view = UICollectionView(frame: self.view.bounds, collectionViewLayout: layout)
        view.delegate = self
        view.dataSource = self
        view.register(CollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        view.backgroundColor = .orange
        return view
    }()

    private lazy var collcetionView5: UICollectionView = {
        let layout = AlignCollectionViewFollowLayout()
        layout.align = .right
        layout.minimumInteritemSpacing = 10
        layout.scrollDirection = .horizontal

        let view = UICollectionView(frame: self.view.bounds, collectionViewLayout: layout)
        view.delegate = self
        view.dataSource = self
        view.register(CollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        view.backgroundColor = .orange
        return view
    }()
}

extension AlignCollectionViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return shortCollectionView.contains(collectionView) ? shortDataTexts.count : dataTexts.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
        cell.label.text = shortCollectionView.contains(collectionView) ? shortDataTexts[indexPath.item] : dataTexts[indexPath.item]
        cell.label.backgroundColor = UIColor(red: CGFloat(Float.random(in: 0 ... 1)),
                                             green: CGFloat(Float.random(in: 0 ... 1)),
                                             blue: CGFloat(Float.random(in: 0 ... 1)), alpha: 1)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let text = shortCollectionView.contains(collectionView) ? shortDataTexts[indexPath.item] : dataTexts[indexPath.item]

        var size = (text as NSString).boundingRect(with: CGSize(width: collectionView.bounds.size.width, height: 30),
                                                   attributes: [.font: UIFont.systemFont(ofSize: 20)],
                                                   context: nil).size
        size.width += 10
        return size
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if shortCollectionView.contains(collectionView) {
            shortDataTexts.append("33")
            collectionView.reloadData()
            collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .left, animated: true)
            return
        }
    }
}

class CollectionViewCell: UICollectionViewCell {
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
