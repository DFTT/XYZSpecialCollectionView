//
//  MessageCollectionViewController.swift
//  XYZSpecialCollectionView
//
//  Created by dadadongl on 2024/10/25.
//

import UIKit

class MessageCollectionViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        view.addSubview(collcetionView)

        let rect = view.bounds
        collcetionView.frame = CGRect(x: 0, y: 300, width: rect.size.width, height: 200)
    }

    private var dataTexts: [String] = [
        "一",
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
        cell.label.text = dataTexts[indexPath.item]
        cell.label.backgroundColor = .green.withAlphaComponent(0.6)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let w = collectionView.bounds.size.width
//        let text = dataTexts[indexPath.item]
//        var size = (text as NSString).boundingRect(with: CGSize(width: w, height: 1000),
//                                                   attributes: [.font: UIFont.systemFont(ofSize: 20)],
//                                                   context: nil).size
//        size.width = w
//        return size
        return CGSize(width: w, height: 50)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        dataTexts.append("\(dataTexts.count + 1)")
        collectionView.reloadData()
        DispatchQueue.main.async {
            collectionView.scrollToItem(at: IndexPath(row: self.dataTexts.count - 1, section: 0), at: .bottom, animated: true)
        }
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
