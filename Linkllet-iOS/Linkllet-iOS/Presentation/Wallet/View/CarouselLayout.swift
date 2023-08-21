//
//  CarouselLayout.swift
//  Linkllet-iOS
//
//  Created by Juhyeon Byun on 2023/07/28.
//

import UIKit

class CarouselLayout: UICollectionViewFlowLayout {
    
    private var sideItemScale: CGFloat = 0.93
    private var spacing: CGFloat = -180
    
    private var isSetup: Bool = false
    
    override public func prepare() {
        super.prepare()
        if isSetup == false {
            setupLayout()
            isSetup = true
        }
    }
    
    private func setupLayout() {
        guard let collectionView = self.collectionView else {return}
                
        let collectionViewSize = collectionView.bounds.size

        self.itemSize = CGSize(width: collectionViewSize.width - 26, height: 200)
        
        let xInset = (collectionViewSize.width - self.itemSize.width) / 2
        let yInset = (collectionViewSize.height - self.itemSize.height) / 2
        
        self.sectionInset = UIEdgeInsets(top: yInset, left: xInset, bottom: yInset, right: xInset)
        
        let itemHeight = self.itemSize.height
        
        let scaledItemOffset =  (itemHeight - (itemHeight * (self.sideItemScale + (1 - self.sideItemScale) / 2))) / 2
        self.minimumLineSpacing = spacing - scaledItemOffset
        
        self.scrollDirection = .vertical
    }
    
    public override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let superAttributes = super.layoutAttributesForElements(in: rect),
            let attributes = NSArray(array: superAttributes, copyItems: true) as? [UICollectionViewLayoutAttributes]
            else { return nil }
        
        return attributes.map({ self.transformLayoutAttributes(attributes: $0) })
    }
    
    private func transformLayoutAttributes(attributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        
        guard let collectionView = self.collectionView else { return attributes }
        
        let collectionCenter = collectionView.frame.size.height / 2
        let contentOffset = collectionView.contentOffset.y
        let center = attributes.center.y - contentOffset

        let maxDistance = 2 * (self.itemSize.height + self.minimumLineSpacing)
        let distance = min(abs(collectionCenter - center), maxDistance)

        let ratio = (maxDistance - distance)/maxDistance
        let scale = ratio * (1 - self.sideItemScale) + self.sideItemScale

        if abs(collectionCenter - center) > maxDistance + 1 {
            attributes.alpha = 0
        }

        let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)
        let dist = attributes.frame.midY - visibleRect.midY
        var transform = CATransform3DScale(CATransform3DIdentity, scale, scale, 1)
        transform = CATransform3DTranslate(transform, 0, 0, -abs(dist/1000))
        attributes.transform3D = transform
        attributes.zIndex = Int(-abs(dist/1000) * 100)
        
        return attributes
    }

    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {

        guard let collectionView = self.collectionView else {
            let latestOffset = super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity)
            return latestOffset
        }

        let targetRect = CGRect(x: 0, y: proposedContentOffset.y, width: collectionView.frame.width, height: collectionView.frame.height)
        guard let rectAttributes = super.layoutAttributesForElements(in: targetRect) else { return .zero }

        var offsetAdjustment = CGFloat.greatestFiniteMagnitude
        let verticalCenter = proposedContentOffset.y + collectionView.frame.height / 2

        for layoutAttributes in rectAttributes {
            let itemVerticalCenter = layoutAttributes.center.y
            if (itemVerticalCenter - verticalCenter).magnitude < offsetAdjustment.magnitude {
                offsetAdjustment = itemVerticalCenter - verticalCenter
            }
        }

        return CGPoint(x: proposedContentOffset.x, y: proposedContentOffset.y + offsetAdjustment)
    }
}
