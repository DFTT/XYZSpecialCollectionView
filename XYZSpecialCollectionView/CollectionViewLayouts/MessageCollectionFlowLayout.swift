//
//  MessageCollectionFlowLayout.swift
//  XYZSpecialCollectionView
//
//  Created by dadadongl on 2024/10/25.
//

import UIKit

// 仿tableView
// 主要解决cell少时 底部对齐
class MessageCollectionFlowLayout: UICollectionViewFlowLayout {
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let atts = super.layoutAttributesForItem(at: indexPath) else { return nil }
        // 横向滚动
        if scrollDirection == .horizontal {
            return atts
        }
        // 纵向滚动
        guard let collectionView = collectionView else {
            return atts
        }

        // cell已经超过bounds
        let minContentSizeH = collectionView.bounds.size.height
        let currentContentSizeH = collectionViewContentSize.height
        if minContentSizeH < currentContentSizeH {
            return atts
        }

        //
        if atts.frame.minY < minContentSizeH {
            var rect = atts.frame
            rect.origin.y = minContentSizeH
            atts.frame = rect
        }
        return atts
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let atts = super.layoutAttributesForElements(in: rect) else { return nil }
        guard atts.isEmpty == false else { return atts }

        // 横向滚动
        if scrollDirection == .horizontal {
            return atts
        }

        // 纵向滚动
        guard let collectionView = collectionView else {
            return atts
        }
        // cell已经超过bounds
        let minContentSizeH = collectionView.bounds.size.height
        let currentContentSizeH = collectionViewContentSize.height
        if minContentSizeH < currentContentSizeH {
            return atts
        }

        //
        var lastFrame: CGRect?
        for att in atts.reversed() {
            var frame = att.frame
            if let lastFrame = lastFrame {
                frame.origin.y = lastFrame.minY - minimumLineSpacing - frame.height
            } else {
                frame.origin.y = minContentSizeH - frame.height
            }
            att.frame = frame
            lastFrame = frame
        }
        return atts
    }
}
