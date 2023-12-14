//
//  StackCollectionCell.swift
//  SwiftRPN
//
//  Created by Patrick Gelvin on 12/14/23.
//

import UIKit


class StackCollectionDataSource : NSObject {
    typealias DataSource = UICollectionViewDiffableDataSource<Int, SwiftStackItem.ID>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Int, SwiftStackItem.ID>
    
    private var stack: [SwiftStackItem] = []
    
    private var dataSource: DataSource! = nil
    private var collectionView: StackCollectionView! = nil
    
    var onScrollStarted: (()->())? = nil
    
    public var queerActive: Bool = Settings.shared.colorTheme == .Queer {
        didSet {
            applySnapshot(refreshingVisible: true)
        }
    }
    
    init(collectionView: StackCollectionView) {
        super.init()
        
        let cellRegistration = UICollectionView.CellRegistration<StackCollectionCell, SwiftStackItem.ID> { [weak self] (cell, indexPath, id) in
            guard let index = self?.stack.firstIndex(where: { item in item.id == id }) else { fatalError() }
            let item = self!.stack[index]
            
            let foregroundColor = self?.foregroundColorForIndex(index)
            let backgroundColor = self?.backgroundColorForIndex(index)
            
            cell.updateWithItem(item, foregroundColor: foregroundColor, backgroundColor: backgroundColor)
            
            var bg_config = UIBackgroundConfiguration.listPlainCell()
            bg_config.backgroundColor = .clear
            cell.backgroundConfiguration = bg_config
        }
        
        dataSource = UICollectionViewDiffableDataSource<Int, SwiftStackItem.ID>(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, item: SwiftStackItem.ID) -> UICollectionViewCell? in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
        }
        
        var snapshot = Snapshot()
        snapshot.appendSections([0])
        snapshot.appendItems([])
        dataSource.apply(snapshot, animatingDifferences: false)
        
        self.collectionView = collectionView
        
        Settings.shared.subscribe(to: \.colorTheme) { [weak self] in
            self?.queerActive = Settings.shared.colorTheme == .Queer
        }
    }
    
    func add_stack_item(_ item: SwiftStackItem) {
        stack.append(item)
        collectionView.itemAdded = true
    }
    
    func remove_stack_item() {
        if !stack.isEmpty {
            stack.removeLast()
        }
    }
    
    func clear_stack() {
        stack.removeAll()
    }
    
    func applySnapshot(refreshingVisible: Bool = false) {
        var snapshot = Snapshot()
        snapshot.appendSections([0])
        snapshot.appendItems(stack.map { item in item.id })
        
        if refreshingVisible {
            snapshot.reloadItems(stack.map { item in item.id })
        }
        
        dataSource.apply(snapshot)
    }
    
    func foregroundColorForIndex(_ index: Int) -> UIColor? {
        guard queerActive else { return nil }
        return StackColor.foreground(with: index)
    }
    
    func backgroundColorForIndex(_ index: Int) -> UIColor? {
        guard queerActive else { return nil }
        return StackColor.background(with: index, style: collectionView.traitCollection.userInterfaceStyle)
    }
}


extension StackCollectionDataSource : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.frame.width
        let id = dataSource.itemIdentifier(for: indexPath)
        guard let item = stack.first(where: { item in item.id == id }) else { fatalError() }
        
        let entry = DisplayEntry(stackItem: item)
        entry.calculateSize(maxWidth: availableWidth)
        
        return CGSize(width: availableWidth, height: entry.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        16.0
    }
}

extension StackCollectionDataSource : UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if let callback = onScrollStarted {
            callback()
        }
    }
}
