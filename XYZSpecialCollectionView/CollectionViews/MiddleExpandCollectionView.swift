//
//  MiddleExpandCollectionView.swift
//  SwiftDemo
//
//  Created by 大大东 on 2023/3/6.
//  Copyright © 2023 大大东. All rights reserved.
//

import UIKit

protocol MiddleExpandCollectionViewDelegate: AnyObject {
    func cell(for dataItem: Any, collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell
    func cellDidClick(with index: Int, inDataArr: [Any]) -> Void
    func cellWillDisplay(with index: Int, inDataArr: [Any]) -> Void
}

private let SC_LoopCount = 150

class MiddleExpandCollectionView: UIView {
    // 滚动方向
    let direction: UICollectionView.ScrollDirection
    // 普通状态的间距
    let itemSpace: CGFloat
    // 普通状态item大小
    let itemSize: CGSize
    // 中间放大item的放大系数 放大后会挤压两边的间距
    let maxScale: CGFloat

    // 代理
    private weak var delegate: MiddleExpandCollectionViewDelegate?

    // 是否可以循环滚动
    var isLoop = false

    // 是否可以自动滚动
    var autoScroll = false
    // 自动滚动时间间隔
    var autoScrollTimeInterval = TimeInterval(3.5)
    // 自动滚动定时器
    private var autoScrollTimer: Timer?

    // 数据源
    private var dataArr = [Any]()
    // CollectionView
    private let colletView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())

    init(delegate: MiddleExpandCollectionViewDelegate,
         itemSize: CGSize,
         itemSpace: CGFloat = 0,
         maxScale: CGFloat = 1.2,
         direction: UICollectionView.ScrollDirection = .horizontal)
    {
        self.delegate = delegate
        self.direction = direction
        self.itemSpace = itemSpace
        self.itemSize = itemSize
        self.maxScale = maxScale

        super.init(frame: .zero)
    }

    @available(*, unavailable)
    override init(frame: CGRect) {
        self.delegate = nil
        self.direction = .horizontal
        self.itemSpace = 0
        self.itemSize = .zero
        self.maxScale = 0
        super.init(frame: frame)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // 刷新
    func reloadData(_ datas: [Any]) {
        DispatchQueue.main.async {
            self.dataArr = datas
            self.tryReload()

            if datas.isEmpty == false, self.autoScroll == true {
                self.startAutoScroll()
            } else {
                self.self.stopAutoScroll()
            }
        }
    }

    // 注册cell
    func registCollecitonViewCell(for cellClass: AnyClass, reuseIdentifier: String) {
        colletView.register(cellClass, forCellWithReuseIdentifier: reuseIdentifier)
    }

    override func willMove(toWindow newWindow: UIWindow?) {
        if newWindow != nil {
            pauseAutoScroll(false)
        } else {
            pauseAutoScroll(true)
        }
    }

    private func tryReload() {
        if colletView.superview == nil {
            let layout = ScalCollectionViewLayout()
            layout.scrollDirection = direction
            layout.itemSize = itemSize
            layout.maxScale = maxScale
            if direction == .horizontal {
                layout.minimumLineSpacing = itemSpace
            } else {
                layout.minimumInteritemSpacing = itemSpace
            }

            colletView.contentInset = UIEdgeInsets(top: 0, left: itemSpace / 2, bottom: 0, right: itemSpace / 2)
            colletView.dataSource = self
            colletView.delegate = self
            colletView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "ididididid")
            colletView.collectionViewLayout = layout
            addSubview(colletView)

            colletView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "TmP")
            colletView.showsVerticalScrollIndicator = false
            colletView.showsHorizontalScrollIndicator = false

            colletView.backgroundColor = .clear
        }

        colletView.frame = bounds

        colletView.reloadData()
        tryFixIndex()
    }
}

extension MiddleExpandCollectionView {
    // 暂停/继续 自动滚动
    func pauseAutoScroll(_ pause: Bool) {
        guard let timer = autoScrollTimer, timer.isValid else { return }
        timer.fireDate = pause ? .distantFuture : .distantPast
    }

    private func startAutoScroll() {
        if let timer = autoScrollTimer, timer.isValid { return }
        let timer = Timer.scheduledTimer(withTimeInterval: autoScrollTimeInterval, repeats: true) { [weak self] ttime in
            guard let self = self else {
                ttime.invalidate()
                return
            }
            self.timerFire()
        }
        autoScrollTimer = timer
    }

    private func stopAutoScroll() {
        autoScrollTimer?.invalidate()
        autoScrollTimer = nil
    }

    private func timerFire() {
        if colletView.isDragging || colletView.isTracking || colletView.isDecelerating { return }
        guard let cIndexPath = colletView.indexPathForItem(at: CGPoint(x: colletView.bounds.midX, y: colletView.bounds.midY)) else {
            return
        }
        let toIndexPath: IndexPath
        if isLoop {
            toIndexPath = IndexPath(row: cIndexPath.row + 1, section: 0)
        } else {
            let totalCount = colletView.numberOfItems(inSection: 0)
            let offset = direction == .horizontal ? colletView.contentOffset.x : colletView.contentOffset.y
            let maxOffset = direction == .horizontal ? colletView.contentSize.width - colletView.bounds.size.width : colletView.contentSize.height - colletView.bounds.size.height
            if cIndexPath.row == totalCount - 1 || offset >= maxOffset {
                toIndexPath = IndexPath(row: 0, section: 0)
            } else {
                toIndexPath = IndexPath(row: cIndexPath.row + 1, section: 0)
            }
        }
        colletView.scrollToItem(at: toIndexPath,
                                at: direction == .horizontal ? .centeredHorizontally : .centeredVertically,
                                animated: true)
    }
}

extension MiddleExpandCollectionView: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return isLoop ? dataArr.count * SC_LoopCount : dataArr.count
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        delegate?.cellWillDisplay(with: indexPath.row % dataArr.count, inDataArr: dataArr)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let del = delegate else {
            return collectionView.dequeueReusableCell(withReuseIdentifier: "TmP", for: indexPath)
        }
        return del.cell(for: dataArr[indexPath.row % dataArr.count],
                        collectionView: collectionView,
                        indexPath: indexPath)
    }
}

extension MiddleExpandCollectionView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.cellDidClick(with: indexPath.row % dataArr.count,
                               inDataArr: dataArr)
    }
}

extension MiddleExpandCollectionView {
    private func tryFixIndex() {
        guard isLoop else { return }

        guard let cIndexPath = colletView.indexPathForItem(at: CGPoint(x: colletView.bounds.midX, y: colletView.bounds.midY)) else {
            return
        }
        let maxCount = colletView.numberOfItems(inSection: 0)
        // 还剩一个循环则为临界值
        if maxCount - cIndexPath.row <= dataArr.count || cIndexPath.row <= dataArr.count {
            // 滚动到总个数的0.4位置
            colletView.scrollToItem(at: IndexPath(row: dataArr.count * Int(Float(SC_LoopCount) * 0.4) + cIndexPath.row % dataArr.count,
                                                  section: 0),
                                    at: direction == .horizontal ? .centeredHorizontally : .centeredVertically,
                                    animated: false)
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        tryFixIndex()
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate == false {
            tryFixIndex()
        }
    }

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        tryFixIndex()
    }
}

private class ScalCollectionViewLayout: UICollectionViewFlowLayout {
    var maxScale = CGFloat(1.2)

    /// 1. 预布局 计算layoutAttribute
    override func prepare() {
        super.prepare()
    }

    /// 2. 根据预布局的信息 计算contentSize
    override var collectionViewContentSize: CGSize {
        return super.collectionViewContentSize
    }

    /// 3. 根据特定矩形区域(一般是可视区域) 调整可视区域内的cellLayoutAttribute
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let resArr = super.layoutAttributesForElements(in: rect) else { return nil }

        let collectionView = self.collectionView!

        let animateDistance = (scrollDirection == .horizontal ? itemSize.width + minimumLineSpacing : itemSize.height + minimumInteritemSpacing)

        let halfBounceValue = (scrollDirection == .horizontal ? collectionView.bounds.size.width : collectionView.bounds.size.height) / 2

        for subAtt in resArr {
            let distancePoint = CGPoint(x: abs(subAtt.center.x - collectionView.contentOffset.x - halfBounceValue),
                                        y: abs(subAtt.center.y - collectionView.contentOffset.y - halfBounceValue))

            let targetDistance = scrollDirection == .horizontal ? distancePoint.x : distancePoint.y

            if targetDistance <= animateDistance {
                let scal = 1.0 + ((animateDistance - targetDistance) / animateDistance) * (maxScale - 1)
                subAtt.transform = .init(scaleX: scal, y: scal)
            } else {
                subAtt.transform = .identity
            }
        }
        return resArr
    }

    // 如果布局在滑动中 时刻都是变化的 这个方法固定return true
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }

    // 控制collectionView停止滚动时的位置
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        let collectionView = self.collectionView!
        let targetRect = CGRect(origin: proposedContentOffset, size: collectionView.bounds.size)

        let middelPoint = CGPointMake(targetRect.midX, targetRect.midY)

        var targetAtt: UICollectionViewLayoutAttributes?

        layoutAttributesForElements(in: targetRect)!.forEach { att in
            if targetAtt == nil {
                targetAtt = att
                return
            }
            if self.scrollDirection == .horizontal {
                if abs(att.center.x - middelPoint.x) < abs(targetAtt!.center.x - middelPoint.x) {
                    targetAtt = att
                }
            } else {
                if abs(att.center.y - middelPoint.y) < abs(targetAtt!.center.y - middelPoint.y) {
                    targetAtt = att
                }
            }
        }

        if scrollDirection == .horizontal {
            return CGPointMake(proposedContentOffset.x + (targetAtt!.center.x - middelPoint.x),
                               proposedContentOffset.y)
        } else {
            return CGPointMake(proposedContentOffset.x,
                               proposedContentOffset.y + (targetAtt!.center.y - middelPoint.y))
        }
    }
}
