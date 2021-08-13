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
		var newEnvironment: EnvironmentValues = environment
        newEnvironment.inList = true
		newEnvironment.foregroundColor = newEnvironment.foregroundColor ?? newEnvironment.defaultForegroundColor
        let tableView = SwiftUITableView(style: environment.listStyle._tableViewStyle, buildingBlocks: self.viewCreator.expanded().toSections, environment: environment, controller: enclosingController)
        tableView.viewController = enclosingController
        tableView.environment = newEnvironment
        
		return tableView
	}
	
	public func _redraw(view: UIView, controller: UIViewController, environment: EnvironmentValues) {
		if let tableView = view as? SwiftUITableView {
			var newEnvironment: EnvironmentValues = environment
            newEnvironment.inList = true
			newEnvironment.foregroundColor = newEnvironment.foregroundColor ?? newEnvironment.defaultForegroundColor
			let view = self.viewCreator
            tableView.environment = environment
            tableView.viewController = controller
			tableView.diff(buildingBlocks: view.expanded().toSections, controller: controller, environment: environment)
		}
	}
    
}

extension Array where Element == _BuildingBlock {
    var toSections: [SectionProtocol] {
        var sections: [SectionProtocol] = []
        var nonSectionedElements: [_BuildingBlock] = []
        for element in self {
            if let section = element as? SectionProtocol {
                if !nonSectionedElements.isEmpty {
                    sections.append(UngroupedSection(buildingBlocks: nonSectionedElements))
                    nonSectionedElements = []
                }
                sections.append(section)
            } else {
                nonSectionedElements.append(element)
            }
        }
        if !nonSectionedElements.isEmpty {
            sections.append(UngroupedSection(buildingBlocks: nonSectionedElements))
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
    var allChildren: [UIView] = []
    
    override var uiView: UIView? {
        didSet {
            allChildren = []
            if let view = uiView {
                allChildren = [view]
                var subviews = view.subviews
                while !subviews.isEmpty {
                    allChildren.append(contentsOf: subviews)
                    subviews = subviews.flatMap(\.subviews)
                }
            }
        }
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
    
    fileprivate var listNodes = [[ListDOMNode]]()
	    
    var environment = EnvironmentValues() {
        didSet {
            self.refreshControl = environment.refreshAction == nil ? nil : self.internalRefreshControl
        }
    }
    
    var actualEnvironment: EnvironmentValues {
        return environment.withUpdates({
            $0.inList = true
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
    func diff(buildingBlocks: [SectionProtocol], controller: UIViewController, environment: EnvironmentValues) {
        self.performBatchUpdates({
            if self.buildingBlocks.count < buildingBlocks.count {
                self.insertSections(IndexSet(self.buildingBlocks.count ..< buildingBlocks.count), with: .automatic)
                self.listNodes.append(contentsOf: (self.buildingBlocks.count ..< buildingBlocks.count).map {_ in [ListDOMNode]() })
            } else if self.buildingBlocks.count > buildingBlocks.count {
                self.deleteSections(IndexSet(buildingBlocks.count ..< self.buildingBlocks.count), with: .automatic)
                self.listNodes.removeLast(self.buildingBlocks.count - buildingBlocks.count)
            }
            zip(self.buildingBlocks.enumerated(), buildingBlocks).forEach { oldSectionInfo, newSection in
                let (index, oldSection) = oldSectionInfo
                let changes = oldSection.buildingBlocks.diff(other: newSection.buildingBlocks)
                self.deleteRows(at: changes.deletion.map { IndexPath(row: $0, section: index) }, with: .automatic)
                changes.deletion.sorted().reversed().forEach { value in
                    self.listNodes[index].remove(at: value)
                }
                self.insertRows(at: changes.additions.map { IndexPath(row: $0, section: index) }, with: .automatic)
                changes.additions.sorted().forEach { value in
                    let node = ListDOMNode(environment: environment, viewController: viewController, buildingBlock: self.buildingBlocks[index].buildingBlocks[value])
                    if value == self.listNodes[index].count {
                        self.listNodes[index].append(node)
                    } else {
                        self.listNodes[index].insert(node, at: value)
                    }
                }
                changes.moved.forEach { (old, new) in
                    guard old != new else { return }
                    self.moveRow(at: IndexPath(row: old, section: index), to: IndexPath(row: new, section: index))
                    self.listNodes[index].swapAt(old, new)
                }
            }
            self.buildingBlocks = buildingBlocks
        }) { _ in
            if let visibleRows = self.indexPathsForVisibleRows {
                for row in visibleRows {
                    if let cell = self.cellForRow(at: row) as? SwiftUITableViewCell, let view = cell.view {
                        var environment = self.actualEnvironment
                        environment.cell = cell
                        let node = self.listNodes[row.section][row.row]
                        environment.currentStateNode = node
                        self.buildingBlocks[row.section].buildingBlocks[row.row]._redraw(view: view, controller: controller, environment: environment)
                    }
                }
            }
        }
    }
	
    init(style: UITableView.Style, buildingBlocks: [SectionProtocol], environment: EnvironmentValues, controller: UIViewController) {
		self.buildingBlocks = buildingBlocks
		super.init(frame: .zero, style: style)
        self.listNodes = self.buildingBlocks.map { section in
            return section.buildingBlocks.map { view in
                ListDOMNode(environment: environment, viewController: controller, buildingBlock: view)
            }
        }
		self.translatesAutoresizingMaskIntoConstraints = false
		self.dataSource = self
		self.delegate = self
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
        return self.buildingBlocks[section].buildingBlocks.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SwiftUI") as? SwiftUITableViewCell else { return UITableViewCell() }
        var environment = self.actualEnvironment
        environment.cell = cell
        let domNode = self.listNodes[indexPath.section][indexPath.row]
        domNode.environment = environment
        environment.currentStateNode = domNode
        let view = self.buildingBlocks[indexPath.section].buildingBlocks[indexPath.row]._toUIView(enclosingController: usableController, environment: environment)
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

class SwiftUITableViewCell: UITableViewCell {
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
	}
    
    lazy var baseView: UIView = {
        let view = UIView(frame: self.contentView.frame)
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.contentView.addSubview(view)
        return view
    }()
    
    var onClick: (() -> ())? = nil
    
    var menuItems: [Any]? = nil
	
	var view: UIView? {
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
	
	override func prepareForReuse() {
		super.prepareForReuse()
		self.view?.removeFromSuperview()
		self.view = nil
        self.onClick = nil
        self.menuItems = nil
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
