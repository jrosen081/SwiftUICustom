//
//  List.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 9/1/20.
//

import Foundation

public struct List<Content: View>: View {
	let viewCreator: Content
	
	public var body: Self {
		return self
	}
	
	public init(@ViewBuilder _ viewCreator: () -> Content) {
		self.viewCreator = viewCreator()
	}
	
	public func _toUIView(enclosingController: UIViewController, environment: EnvironmentValues) -> UIView {
        environment.currentStateNode.buildingBlock = self.viewCreator
		var newEnvironment: EnvironmentValues = environment
		newEnvironment.foregroundColor = newEnvironment.foregroundColor ?? newEnvironment.defaultForegroundColor
        let sectionNode = DOMNode(environment: newEnvironment, viewController: enclosingController, buildingBlock: EmptyView())
        let tableView = SwiftUITableView(style: newEnvironment.listStyle._tableViewStyle,
                                         buildingBlocks: self.viewCreator._makeSequence(currentNode: environment.currentStateNode)
                                            .expanded(node: environment.currentStateNode).toSections(),
                                         environment: newEnvironment,
                                         controller: enclosingController)
        tableView.sectionCreationNode = sectionNode
        tableView.viewController = enclosingController
        tableView.environment = newEnvironment.withUpdates { $0.tableView = tableView }
        
		return tableView
	}
	
	public func _redraw(view: UIView, controller: UIViewController, environment: EnvironmentValues) {
		if let tableView = view as? SwiftUITableView {
			var newEnvironment: EnvironmentValues = environment
            newEnvironment.tableView = tableView
			newEnvironment.foregroundColor = newEnvironment.foregroundColor ?? newEnvironment.defaultForegroundColor
			let view = self.viewCreator
            tableView.environment = environment
            tableView.viewController = controller
            tableView.diff(buildingBlocks: view._makeSequence(currentNode: environment.currentStateNode)
                            .expanded(node: environment.currentStateNode).toSections(), controller: controller, environment: environment)
		}
	}
    
}

extension Array where Element == (_BuildingBlockRepresentable, DOMNode) {
    func toSections() -> [(SectionProtocol, DOMNode)] {
        var sections: [(SectionProtocol, DOMNode)] = []
        var nonSectionedElements: [(_BuildingBlock, DOMNode)] = []
        for (representable, node) in self {
            let buildingBlock = representable.buildingBlock
            if let section = buildingBlock as? SectionProtocol {
                if !nonSectionedElements.isEmpty {
                    sections.append((UngroupedSection(buildingBlocks: nonSectionedElements), DOMNode(environment: EnvironmentValues(), viewController: nil, buildingBlock: EmptyView())))
                    nonSectionedElements = []
                }
                sections.append((section, node))
            } else {
                nonSectionedElements.append((buildingBlock, node))
            }
        }
        if !nonSectionedElements.isEmpty {
            sections.append((UngroupedSection(buildingBlocks: nonSectionedElements), DOMNode(environment: EnvironmentValues(), viewController: nil, buildingBlock: EmptyView())))
        }
        return sections
    }
}

extension Array where Element == _BuildingBlock {
    func toSections(baseNode: DOMNode) -> [SectionProtocol] {
        var sections: [SectionProtocol] = []
        var currentNode = baseNode.values.first as? DOMNode ?? DOMNode(environment: baseNode.environment, viewController: baseNode.viewController, buildingBlock: EmptyView())
        baseNode.update(value: currentNode, index: 0)
        var nonSectionedElements: [(_BuildingBlock, DOMNode)] = []
        for element in self {
            if let section = element as? SectionProtocol {
                if !nonSectionedElements.isEmpty {
                    sections.append(UngroupedSection(buildingBlocks: nonSectionedElements))
                    nonSectionedElements = []
                    currentNode = baseNode.safeGet(valueAtIndex: sections.count) as? DOMNode ?? DOMNode(environment: baseNode.environment, viewController: baseNode.viewController, buildingBlock: EmptyView())
                    baseNode.update(value: currentNode, index: sections.count)
                }
                sections.append(section)
                currentNode = baseNode.safeGet(valueAtIndex: sections.count) as? DOMNode ?? DOMNode(environment: baseNode.environment, viewController: baseNode.viewController, buildingBlock: EmptyView())
                baseNode.update(value: currentNode, index: sections.count)
            } else {
                let childNode: DOMNode
                if currentNode.childNodes.count > nonSectionedElements.count {
                    childNode = currentNode.childNodes[nonSectionedElements.count]
                } else {
                    childNode = DOMNode(environment: baseNode.environment, viewController: baseNode.viewController, buildingBlock: element)
                    baseNode.addChild(node: childNode, index: nonSectionedElements.count)
                }
                nonSectionedElements.append((element, childNode))
            }
        }
        if !nonSectionedElements.isEmpty {
            sections.append(UngroupedSection(buildingBlocks: nonSectionedElements))
            currentNode = baseNode.safeGet(valueAtIndex: sections.count) as? DOMNode ?? DOMNode(environment: baseNode.environment, viewController: baseNode.viewController, buildingBlock: EmptyView())
            baseNode.update(value: currentNode, index: sections.count)
        }
        return sections
    }
}

private struct CellGetter: EnvironmentKey {
    static var defaultValue: SwiftUITableViewCell? { return nil }
}

extension EnvironmentValues {
    var cell: SwiftUITableViewCell? {
        get {
            self[CellGetter.self]
        }
        
        set {
            self[CellGetter.self] = newValue
        }
    }
}

private class ListDOMNode: DOMNode {
    override var shouldRestartValue: Bool {
        didSet {
            if shouldRestartValue {
                self.shouldRestartValue = false
            }
        }
    }
    
    override class func makeNode(environment: EnvironmentValues, viewController: UIViewController?, buildingBlock: _BuildingBlock) -> DOMNode {
        ListDOMNode(environment: environment, viewController: viewController, buildingBlock: buildingBlock)
    }
}

class SwiftUITableView: UITableView {
    
    lazy var internalRefreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.refresh), for: .valueChanged)
        refreshControl.translatesAutoresizingMaskIntoConstraints = false
        return refreshControl
    }()
    
    override var intrinsicContentSize: CGSize {
        return UIView.layoutFittingExpandedSize
    }
    
	var buildingBlocks: [SectionProtocol]
    var sectionCreationNode: DOMNode!
    var draggingFunctions: [DOMNode: (IndexSet, Int) -> Void] = [:]
    
    fileprivate var sectionNodes = [DOMNode]()
	    
    var environment = EnvironmentValues() {
        didSet {
            self.refreshControl = environment.refreshAction == nil ? nil : self.internalRefreshControl
        }
    }
    
    var actualEnvironment: EnvironmentValues {
        return environment.withUpdates({
            $0.tableView = self
            $0.refreshAction = nil
        })
    }
    
    weak var viewController: UIViewController?
    
    var usableController: UIViewController {
        return self.viewController ?? UIViewController()
    }
    
    @objc func refresh() {
        environment.refreshAction? { [weak self] in
            self?.refreshControl?.endRefreshing()
        }
    }
    
    // TODO: This
    func diff(buildingBlocks: [(SectionProtocol, DOMNode)], controller: UIViewController, environment: EnvironmentValues) {
        self.performBatchUpdates({
            if self.buildingBlocks.count < buildingBlocks.count {
                self.insertSections(IndexSet(self.buildingBlocks.count ..< buildingBlocks.count), with: .automatic)
            } else if self.buildingBlocks.count > buildingBlocks.count {
                self.deleteSections(IndexSet(buildingBlocks.count ..< self.buildingBlocks.count), with: .automatic)
            }
            zip(self.buildingBlocks.enumerated(), buildingBlocks).forEach { oldSectionInfo, newSection in
                let (index, oldSection) = oldSectionInfo
                let (newSectionBuildingBlocks, newSectionNodes) = newSection
                let oldBuildingBlockAndNodes = oldSection.buildingBlocks(topNode: self.sectionNodes[index])
                let changes = oldBuildingBlockAndNodes.map(\.0).diff(other: newSectionBuildingBlocks.buildingBlocks(topNode: newSectionNodes).map(\.0))
                self.deleteRows(at: changes.deletion.map { IndexPath(row: $0, section: index) }, with: .automatic)
                self.insertRows(at: changes.additions.map { IndexPath(row: $0, section: index) }, with: .automatic)
                changes.moved.forEach { (old, new) in
                    guard old != new else { return }
                    self.moveRow(at: IndexPath(row: old, section: index), to: IndexPath(row: new, section: index))
                }
            }
            self.buildingBlocks = buildingBlocks.map(\.0)
            self.sectionNodes = buildingBlocks.map(\.1)
        }) { _ in
            if let visibleRows = self.indexPathsForVisibleRows {
                for row in visibleRows {
                    if let cell = self.cellForRow(at: row) as? SwiftUITableViewCell, let view = cell.view {
                        var environment = self.actualEnvironment
                        environment.cell = cell
                        let (swiftUIView, node) = self.buildingBlocks[row.section].buildingBlocks(topNode: self.sectionNodes[row.section])[row.row]
                        environment.currentStateNode = node
                        environment.tableView = self
                        swiftUIView._redraw(view: view, controller: controller, environment: environment)
                    }
                }
            }
        }
    }
	
    init(style: UITableView.Style, buildingBlocks: [(SectionProtocol, DOMNode)], environment: EnvironmentValues, controller: UIViewController) {
        self.buildingBlocks = buildingBlocks.map(\.0)
		super.init(frame: .zero, style: style)
        self.sectionNodes = buildingBlocks.map(\.1)
		self.translatesAutoresizingMaskIntoConstraints = false
		self.dataSource = self
		self.delegate = self
        self.dragDelegate = self
        self.dropDelegate = self
		self.estimatedRowHeight = 85.0
		self.rowHeight = UITableView.automaticDimension
		self.register(SwiftUITableViewCell.self, forCellReuseIdentifier: "SwiftUI")
        self.refreshControl = environment.refreshAction == nil ? nil : self.internalRefreshControl
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

struct UIViewWrapper: UIViewRepresentable {
	let view: UIView
	
	func makeUIView(context: Context) -> UIView {
		return view
	}
	
	func updateUIView(_ view: UIViewType, context: Context) {
		// Do nothing
	}
	
	func makeCoordinator() -> () {
		return ()
	}
}

class HeaderFooterView: UITableViewHeaderFooterView {
    override var intrinsicContentSize: CGSize {
        return self.contentView.subviews[0].intrinsicContentSize
    }
}

extension SwiftUITableView: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.buildingBlocks.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var environment = self.actualEnvironment
        environment.currentStateNode = DOMNode(environment: environment, viewController: nil, buildingBlock: EmptyView())
        return (self.buildingBlocks[section].headerView?._toUIView(enclosingController: usableController, environment: environment)).map({ underlyingView in
            let sectionHeader = HeaderFooterView(frame: .zero)
            sectionHeader.contentView.addSubview(underlyingView)
            sectionHeader.setupFullConstraints(sectionHeader.contentView, underlyingView)
            return sectionHeader
        })
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        var environment = self.actualEnvironment
        environment.currentStateNode = DOMNode(environment: environment, viewController: nil, buildingBlock: EmptyView())
        return (self.buildingBlocks[section].footerView?._toUIView(enclosingController: usableController, environment: environment)).map({ underlyingView in
            let sectionHeader = HeaderFooterView(frame: .zero)
            sectionHeader.contentView.addSubview(underlyingView)
            sectionHeader.setupFullConstraints(sectionHeader.contentView, underlyingView)
            return sectionHeader
        })
    }
    
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.buildingBlocks[section].buildingBlocks(topNode: self.sectionNodes[section]).count
	}
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? SwiftUITableViewCell else { return }
        cell.view?.removeFromSuperview()
        cell.view = nil
        cell.menuItems = nil
        cell.onClick = nil
        cell.leadingConfiguration = nil
        cell.trailingConfiguration = nil
        cell.nodeIndexPair = nil
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        guard let cell = tableView.cellForRow(at: indexPath) as? SwiftUITableViewCell else { return false }
        return cell.onClick != nil
    }
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SwiftUI") as? SwiftUITableViewCell else { return UITableViewCell() }
        cell.view?.removeFromSuperview()
        cell.view = nil
        cell.menuItems = nil
        cell.onClick = nil
        var environment = self.actualEnvironment
        environment.cell = cell
        let (swiftUIView, domNode) = self.buildingBlocks[indexPath.section].buildingBlocks(topNode: self.sectionNodes[indexPath.section])[indexPath.row]
        domNode.environment = environment
        environment.currentStateNode = domNode
        let view = swiftUIView._toUIView(enclosingController: usableController, environment: environment)
        domNode.uiView = view
        cell.view = view
        if cell.onClick != nil {
            cell.view?.isUserInteractionEnabled = false
        }
		return cell
	}
}

extension SwiftUITableView: UITableViewDelegate {
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? SwiftUITableViewCell else { return }
        cell.onClick?()
		tableView.deselectRow(at: indexPath, animated: true)
	}
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let cell = tableView.cellForRow(at: indexPath) as? SwiftUITableViewCell else { return nil }
        return cell.leadingConfiguration
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let cell = tableView.cellForRow(at: indexPath) as? SwiftUITableViewCell else { return nil }
        return cell.trailingConfiguration
    }
    
    @available(iOS 13.0, *)
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard let cell = tableView.cellForRow(at: indexPath) as? SwiftUITableViewCell,
              let menuItems = cell.menuItems as? [UIMenuElement],
              !menuItems.isEmpty else { return nil }
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            return UIMenu(title: "", image: nil, identifier: nil, options: .displayInline, children: menuItems)
        }
    }
}

extension SwiftUITableView: UITableViewDragDelegate {
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        guard let cell = tableView.cellForRow(at: indexPath) as? SwiftUITableViewCell else { return [] }
        guard let (node, index) = cell.nodeIndexPair else { return [] }
        let item = UIDragItem(itemProvider: NSItemProvider())
        item.localObject = (node, index)
        return [item]
    }
    
    func tableView(_ tableView: UITableView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
        guard let cell = tableView.cellForRow(at: indexPath) as? SwiftUITableViewCell else { return [] }
        guard let (node, index) = cell.nodeIndexPair else { return [] }
        let allNodes = session.items.compactMap(\.localObject).compactMap { $0 as? (DOMNode, Int) }
        guard allNodes.contains(where:  { $0.0 === node }) else { return [] }
        let item = UIDragItem(itemProvider: NSItemProvider())
        item.localObject = (node, index)
        return [item]

    }
}

extension SwiftUITableView: UITableViewDropDelegate {
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
        guard let indexPath = coordinator.destinationIndexPath else { return }
        let items = coordinator.items.map(\.dragItem).compactMap(\.localObject).compactMap { $0 as? (DOMNode, Int) }
        let indexes = items.map(\.1)
        let indexSet = IndexSet(indexes)
        guard let domNode = items.map(\.0).first, let cell = tableView.cellForRow(at: indexPath) as? SwiftUITableViewCell else { return }
        guard let (node, index) = cell.nodeIndexPair else { return }
        guard node === domNode else { return }
        self.draggingFunctions[domNode]?(indexSet, index)
    }
    
    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        guard let indexPath = destinationIndexPath else { return UITableViewDropProposal(operation: .cancel) }
        guard let (dropNode, _) = session.localDragSession?.items.compactMap(\.localObject).compactMap({ $0 as? (DOMNode, Int)}).first else { return UITableViewDropProposal(operation: .cancel)}
        guard let cell = tableView.cellForRow(at: indexPath) as? SwiftUITableViewCell, let (cellNode, _) = cell.nodeIndexPair, cellNode === dropNode else {
            return UITableViewDropProposal(operation: .cancel)
        }
        return UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
    }
}

class SwiftUITableViewCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    var onClick: (() -> ())? = nil
    
    var menuItems: [Any]? = nil
    
    var leadingConfiguration: UISwipeActionsConfiguration? = nil
    var trailingConfiguration: UISwipeActionsConfiguration? = nil
    
    var nodeIndexPair: (DOMNode, Int)? = nil
    
	
	weak var view: UIView? {
		didSet {
			if let view = self.view {
                let tableViewCell = self.contentView
				tableViewCell.addSubview(view)
				NSLayoutConstraint.activate([
                    view.leadingAnchor.constraint(equalTo: tableViewCell.leadingAnchor, constant: 5),
					view.trailingAnchor.constraint(lessThanOrEqualTo: tableViewCell.trailingAnchor),
					view.topAnchor.constraint(equalTo: tableViewCell.topAnchor),
					view.bottomAnchor.constraint(equalTo: tableViewCell.bottomAnchor)
				])
                tableViewCell.sizeToFit()
			}
		}
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
