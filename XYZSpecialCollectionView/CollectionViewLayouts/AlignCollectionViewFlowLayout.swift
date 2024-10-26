//
//  AlignCollectionViewFollowLayout.swift
//  Lico
//
//  Created by 大大东 on 2024/2/27.
//

import UIKit

// 主要支持纵向滚动的.
//  对于横向滚动的, 仅对只有一行cell场景才有效
class AlignCollectionViewFlowLayout: UICollectionViewFlowLayout {
    enum AlignType {
        case center
        case left
        case right
    }
    
    var align: AlignType = .center
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let atts = super.layoutAttributesForElements(in: rect) else { return nil }
        guard atts.isEmpty == false else { return atts }
        
        // 横向滚动
        if scrollDirection == .horizontal {
            guard let collectionView = collectionView else {
                return atts
            }
            if collectionViewContentSize.width >= collectionView.bounds.size.width {
                return atts
            }
            if case .left = align {
                return atts
            }
            
            // 只有一行时才生效
            let firstAtt = atts.first!
            let otherLineArtt = atts.first { att in
                if att.frame.minY > firstAtt.frame.minY {
                    return att.frame.minY - firstAtt.frame.minY > firstAtt.frame.size.height
                } else {
                    return firstAtt.frame.minY - att.frame.minY > att.frame.size.height
                }
            }
            if otherLineArtt != nil {
                assertionFailure("横向滚动 且 超过1行 不支持")
                return atts
            }
            
            let padding: UIEdgeInsets = sectionInset
            
            if case .right = align {
                var suffixAtt: UICollectionViewLayoutAttributes? = nil
                for att in atts.reversed() {
                    if suffixAtt == nil || att.frame.minY != suffixAtt!.frame.minY {
                        var newFrame = att.frame
                        newFrame.origin.x = collectionView.bounds.size.width - padding.right - newFrame.size.width
                        att.frame = newFrame
                        suffixAtt = att
                        continue
                    }
                    // 同一行
                    var newFrame = att.frame
                    newFrame.origin.x = suffixAtt!.frame.minX - minimumInteritemSpacing - newFrame.size.width
                    att.frame = newFrame
                    suffixAtt = att
                }
                return atts
            }
            
            if case .center = align {
                let sumW = atts.reduce(CGFloat(0)) { $0 + $1.frame.size.width }
                let sumSpace = CGFloat(atts.count - 1) * minimumInteritemSpacing
                var beginX = (collectionView.bounds.size.width - sumW - sumSpace) / CGFloat(2)
                for attEle in atts {
                    var new = attEle.frame
                    new.origin.x = beginX
                    attEle.frame = new
                    beginX = new.maxX + minimumInteritemSpacing
                }
            }
            
            return atts
        }
        
        // 纵向滚动
       
        // 居中对齐
        if case .center = align {
            func __tryMakeAlignCenter(_ seamLineAtts: [UICollectionViewLayoutAttributes]) {
                guard seamLineAtts.isEmpty == false else { return }
                //
                let sumW = seamLineAtts.reduce(CGFloat(0)) { $0 + $1.frame.size.width }
                let sumSpace = CGFloat(seamLineAtts.count - 1) * minimumInteritemSpacing
                var beginX = (collectionViewContentSize.width - sumW - sumSpace) / CGFloat(2)
                for attEle in seamLineAtts {
                    var new = attEle.frame
                    new.origin.x = beginX
                    attEle.frame = new
                    beginX = new.maxX + minimumInteritemSpacing
                }
            }
            var seamLineAtts = [UICollectionViewLayoutAttributes]()
            var preAtt: UICollectionViewLayoutAttributes? = nil
            for att in atts {
                if preAtt == nil || att.frame.minY != preAtt!.frame.minY {
                    __tryMakeAlignCenter(seamLineAtts)
                    seamLineAtts.removeAll()
                    seamLineAtts.append(att)
                    preAtt = att
                    continue
                }
                if att.representedElementKind == UICollectionView.elementKindSectionHeader || att.representedElementKind == UICollectionView.elementKindSectionFooter {
                    continue
                }
                // 同一行
                seamLineAtts.append(att)
                preAtt = att
            }
            __tryMakeAlignCenter(seamLineAtts)
            return atts
        }
        
        let padding: UIEdgeInsets = sectionInset
        
        // 右对齐
        if case .right = align {
            var suffixAtt: UICollectionViewLayoutAttributes? = nil
            for att in atts.reversed() {
                if suffixAtt == nil || att.frame.minY != suffixAtt!.frame.minY {
                    var newFrame = att.frame
                    newFrame.origin.x = collectionViewContentSize.width - padding.right - newFrame.size.width
                    att.frame = newFrame
                    suffixAtt = att
                    continue
                }
                if att.representedElementKind == UICollectionView.elementKindSectionHeader || att.representedElementKind == UICollectionView.elementKindSectionFooter {
                    continue
                }
                // 同一行
                var newFrame = att.frame
                newFrame.origin.x = suffixAtt!.frame.minX - minimumInteritemSpacing - newFrame.size.width
                att.frame = newFrame
                suffixAtt = att
            }
            return atts
        }
        
        // 左对齐
        var preAtt: UICollectionViewLayoutAttributes? = nil
        for att in atts {
            if preAtt == nil || att.frame.minY != preAtt!.frame.minY {
                var newFrame = att.frame
                newFrame.origin.x = padding.left
                att.frame = newFrame
                preAtt = att
                continue
            }
            if att.representedElementKind == UICollectionView.elementKindSectionHeader || att.representedElementKind == UICollectionView.elementKindSectionFooter {
                continue
            }
            // 同一行
            var newFrame = att.frame
            newFrame.origin.x = preAtt!.frame.maxX + minimumInteritemSpacing
            att.frame = newFrame
            preAtt = att
        }
        return atts
    }
}
