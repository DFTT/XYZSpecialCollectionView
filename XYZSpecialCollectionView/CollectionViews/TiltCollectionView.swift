//
//  TiltCollectionView.swift
//  SwiftDemo
//
//  Created by 大大东 on 2023/3/28.
//  Copyright © 2023 大大东. All rights reserved.
//

import UIKit

@objc protocol TiltCollectionViewDelegate: AnyObject {
    func cell(for idx: Int, _ dataItem: Any, _ view: TiltCollectionView) -> TiltCollectionView.Cell
    func cellSize(for dataItem: Any) -> CGSize
    @objc optional func didScrollTo(_ idx: Int, _ dataItem: Any) -> Void
    @objc optional func didClickWith(_ idx: Int, _ dataItem: Any) -> Void
}

class TiltCollectionView: UIView {
    struct CellLayoutAttributes {
        var center: CGPoint = .zero
        var scale: CGFloat = 1
        var alpha: CGFloat = 1
    }

    class Cell: UIView {
        func prepareForReuse() {
            // 进入复用队列前重置部分参数
            transform = CGAffineTransform.identity
            alpha = 1
        }
    }

    // 代理
    weak var delegate: TiltCollectionViewDelegate?

    // 右上角最小比例
    var minScal: CGFloat = 0.5
    // 左下角最大比例
    var maxScal: CGFloat = 1.3
    // 左下角最大时cell透明度
    var alphaWhenMax: CGFloat = 0
    // 倾斜的角度(右上角->左下角)
    var angle: CGFloat = .pi / 6

    // 数据源
    private var dataArr = [Any]()
    // scrollView
    private let scrollView = UIScrollView(frame: .zero)

    // 刷新
    func reloadData(_ datas: [Any]) {
        DispatchQueue.main.async {
            self.dataArr = datas
            self.tryReload()

            // 回调一次滚动位置
            self.updateSelectIndex()
        }
    }

    // 尝试从复用队列取cell
    func dequeueReusableCell() -> Cell? {
        guard let cell = reuseAbleCells.popFirst() else { return nil }
        return cell
    }

    override func willMove(toWindow newWindow: UIWindow?) {
        if newWindow != nil {
            tryReload()
        }
    }

    private var visiableCellsMap: [Int: Cell] = [:]

    private var reuseAbleCells: Set<Cell> = .init()

    private func tryReload() {
        // init if not
        if scrollView.superview == nil {
            self.addSubview(scrollView)
            scrollView.showsVerticalScrollIndicator = false
            scrollView.showsHorizontalScrollIndicator = false
            scrollView.delegate = self

            scrollView.isPagingEnabled = true
            scrollView.delaysContentTouches = false

            // 有个问题
            // 如果scrollview在cell上层, 会影响cell点击事件(如果cell上有自定义的响应点击事件的控件)
            // 如果scrollview在cell下层, 手指从cell上滑动时, scollecview无法获得滑动事件
            // 方法:
            // 转移滑动手势到self上, scrollView高度设成1p, 能响应滑动就行
            self.addGestureRecognizer(scrollView.panGestureRecognizer)
        }
        // 更新滚动size
        var rect = self.bounds
        rect.size.height = 1
        scrollView.frame = rect
        scrollView.contentSize = CGSizeMake(rect.size.width * CGFloat(dataArr.count),
                                            rect.size.height)

        // 重建cell
        visiableCellsMap.values.forEach { cell in
            cell.removeFromSuperview()
        }
        visiableCellsMap.removeAll()

        updateCellsLayout()
    }

    private func updateCellsLayout() {
        let viewW: CGFloat = self.bounds.size.width

        let tmpVal = scrollView.contentOffset.x / viewW
        // 基准角标
        let baseIdx = Int(floorf(Float(tmpVal)))
        // 相对当前index偏移到庞边的进度
        let progress = tmpVal - CGFloat(baseIdx)
        // o o i o o
        let halfW = self.bounds.size.width / 2
        let halfY = self.bounds.size.height / 2
        for idx in max(0, baseIdx - 2) ..< min(dataArr.count, baseIdx + 3) {
            let xChangeValue: CGFloat = halfW * CGFloat(idx - baseIdx) - halfW * progress
            let cellCenter = CGPointMake(halfW + xChangeValue,
                                         halfY - xChangeValue * tan(angle))
            let scale: CGFloat
            let alpha: CGFloat
            if cellCenter.x > halfW {
                scale = (cellCenter.x - halfW) < halfW ? minScal + (1 - minScal) * progress : minScal
                alpha = 1
            } else {
                scale = (halfW - cellCenter.x) < halfW ? 1 + (maxScal - 1) * progress : maxScal
                alpha = (halfW - cellCenter.x) < halfW ? 1 - progress : 0
            }

            let cell: Cell
            if let tCell = visiableCellsMap[idx] {
                cell = tCell
            } else {
                let data = dataArr[idx]
                let initSize = delegate!.cellSize(for: data)
                cell = delegate!.cell(for: idx, data, self)

                self.addSubview(cell)
                cell.frame = CGRect(origin: CGPointMake(cellCenter.x - initSize.width / 2, cellCenter.y - initSize.height / 2),
                                    size: initSize)

                visiableCellsMap[idx] = cell
            }

            cell.resetLayout(CellLayoutAttributes(center: cellCenter, scale: scale, alpha: alpha))
        }
    }

    private func updateSelectIndex() {
        let tmpVal = scrollView.contentOffset.x / self.bounds.size.width
        let selIdx = max(0, Int(floorf(Float(tmpVal))))
        delegate?.didScrollTo?(selIdx, dataArr[selIdx])

        // 屏幕外的可以先移除
        for idx in 0 ..< dataArr.count {
            guard idx < selIdx - 2 || idx > selIdx + 2 else { continue }
            guard let cell = visiableCellsMap[idx] else { continue }
            cell.removeFromSuperview()
            visiableCellsMap.removeValue(forKey: idx)
            cell.prepareForReuse()
            reuseAbleCells.insert(cell)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)

        guard let touch = touches.first else { return }

        let point = touch.location(in: self)
        let tmpVal = scrollView.contentOffset.x / self.bounds.size.width
        let idx = max(0, Int(floorf(Float(tmpVal))))
        if let cell = visiableCellsMap[idx], cell.frame.contains(point) {
            delegate?.didClickWith?(idx, dataArr[idx])
        }
    }
}

extension TiltCollectionView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateCellsLayout()
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updateSelectIndex()
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate == false {
            updateSelectIndex()
        }
    }

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        updateSelectIndex()
    }
}

private extension TiltCollectionView.Cell {
    //
    func resetLayout(_ layoutAttributes: TiltCollectionView.CellLayoutAttributes) {
        center = layoutAttributes.center
        transform = CGAffineTransform(scaleX: layoutAttributes.scale, y: layoutAttributes.scale)
        alpha = layoutAttributes.alpha
    }
}
