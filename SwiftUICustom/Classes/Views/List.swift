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
		var newEnvironment: EnvironmentValues = EnvironmentValues(environment)
        newEnvironment.inList = true
		newEnvironment.foregroundColor = newEnvironment.foregroundColor ?? newEnvironment.defaultForegroundColor
        let tableView = SwiftUITableView(buildingBlocks: self.viewCreator.expanded().toSections, style: environment.listStyle._tableViewStyle)
        tableView.viewController = enclosingController
        tableView.environment = newEnvironment
		return tableView
	}
	
	public func _redraw(view: UIView, controller: UIViewController, environment: EnvironmentValues) {
		if let tableView = view as? SwiftUITableView {
			var newEnvironment: EnvironmentValues = EnvironmentValues(environment)
            newEnvironment.inList = true
			newEnvironment.foregroundColor = newEnvironment.foregroundColor ?? newEnvironment.defaultForegroundColor
			let view = self.viewCreator
            tableView.environment = environment
            tableView.viewController = controller
			tableView.diff(buildingBlocks: view.expanded().toSections, controller: controller, environment: environment)
		}
	}
    
    public func _hash(into hasher: inout Hasher, environment: EnvironmentValues) {
        viewCreator._hash(into: &hasher, environment: environment)
    }
    
    public func _isEqual(toSameType other: List<Content>, environment: EnvironmentValues) -> Bool {
        self.viewCreator._isEqual(to: other.viewCreator, environment: environment)
    }
    
    public func _requestedSize(within size: CGSize, environment: EnvironmentValues) -> CGSize {
        size
    }
}

struct ReferenceList<Content: View>: View {
    let viewCreator: () -> Content
    
    init(@ViewBuilder _ creator: @escaping () -> Content) {
        self.viewCreator = creator
    }
    
    var body: List<Content> {
        return List{
            self.viewCreator()
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

class SwiftUITableView: UITableView {
	
	override var intrinsicContentSize: CGSize {
		return UIView.layoutFittingExpandedSize
	}
	
	override func willExpand(in context: ExpandingContext) -> Bool {
		return true
	}
	var buildingBlocks: [SectionProtocol]
	
	var tableViewClickedResponses: [IndexPath: () -> ()] = [:]
    
    var environment = EnvironmentValues()
    
    var actualEnvironment: EnvironmentValues {
        return environment.withUpdates({
            $0.inList = true
        })
    }
    
    weak var viewController: UIViewController?
    
    var usableController: UIViewController {
        return self.viewController ?? UIViewController()
    }
    
    func diff(buildingBlocks: [SectionProtocol], controller: UIViewController, environment: EnvironmentValues) {
//        self.performBatchUpdates({
//            if self.buildingBlocks.count < buildingBlocks.count {
//                self.insertSections(IndexSet(self.buildingBlocks.count ..< buildingBlocks.count), with: .automatic)
//            } else if self.buildingBlocks.count > buildingBlocks.count {
//                self.deleteSections(IndexSet(buildingBlocks.count ..< self.buildingBlocks.count), with: .automatic)
//            }
//            zip(self.buildingBlocks.enumerated(), buildingBlocks).forEach { oldSectionInfo, newSection in
//                let (index, oldSection) = oldSectionInfo
//                let changes = oldSection.buildingBlocks.diff(other: newSection.buildingBlocks, environment: environment)
//                self.deleteRows(at: changes.deletion.map { IndexPath(row: $0, section: index) }, with: .automatic)
//                self.insertRows(at: changes.additions.map { IndexPath(row: $0, section: index) }, with: .automatic)
//                changes.moved.forEach { (old, new) in
//                    guard old != new else { return }
//                    self.moveRow(at: IndexPath(row: old, section: index), to: IndexPath(row: new, section: index))
//                }
//            }
//        }) { _ in
//            self.buildingBlocks = buildingBlocks
//            if let visibleRows = self.indexPathsForVisibleRows {
//                visibleRows.forEach {
//                    guard let cell = self.cellForRow(at: $0) as? SwiftUITableViewCell, let view = cell.view else { return }
//                    buildingBlocks[$0.section].buildingBlocks[$0.row]._redraw(view: view, controller: controller, environment: environment)
//                }
//            } else {
//                self.reloadData()
//            }
//        }
        // This does diff correctly, but there are weird sizing things, so punting until I redo the layout system
        self.buildingBlocks = buildingBlocks
        self.reloadData()
    }
	
    init(buildingBlocks: [SectionProtocol], style: UITableView.Style) {
		self.buildingBlocks = buildingBlocks
		super.init(frame: .zero, style: style)
		self.translatesAutoresizingMaskIntoConstraints = false
		self.dataSource = self
		self.delegate = self
		self.estimatedRowHeight = 85.0
		self.rowHeight = UITableView.automaticDimension
		self.register(SwiftUITableViewCell.self, forCellReuseIdentifier: "SwiftUI")
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
        return (self.buildingBlocks[section].headerView?._toUIView(enclosingController: usableController, environment: actualEnvironment)).map({ underlyingView in
            let sectionHeader = HeaderFooterView(frame: .zero)
            sectionHeader.contentView.addSubview(underlyingView)
            sectionHeader.setupFullConstraints(sectionHeader.contentView, underlyingView)
            return sectionHeader
        })
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return (self.buildingBlocks[section].footerView?._toUIView(enclosingController: usableController, environment: actualEnvironment)).map({ underlyingView in
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
        let view = self.buildingBlocks[indexPath.section].buildingBlocks[indexPath.row]._toUIView(enclosingController: usableController, environment: self.actualEnvironment)
		guard let cell = tableView.dequeueReusableCell(withIdentifier: "SwiftUI") as? SwiftUITableViewCell else { return UITableViewCell() }
		if let onClick = view.insideList(width: self.frame.width) {
			self.tableViewClickedResponses[indexPath] = onClick
			cell.view = view
            view.isUserInteractionEnabled = false
			return cell
		}
//		if view.willExpand(in: .horizontal) {
			cell.view = view
//			return cell
//		}
//		cell.view = HStack {
//			UIViewWrapper(view: view)
//			Spacer()
//        }.__toUIView(enclosingController: UIViewController(), environment: self.actualEnvironment)
		return cell
	}
}

extension SwiftUITableView: UITableViewDelegate {
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		self.tableViewClickedResponses[indexPath]?()
		tableView.deselectRow(at: indexPath, animated: true)
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
	
	var view: UIView? {
		didSet {
			if let view = self.view {
                let tableViewCell = self.baseView
				tableViewCell.addSubview(view)
				NSLayoutConstraint.activate([
					view.leadingAnchor.constraint(equalTo: tableViewCell.leadingAnchor),
					view.trailingAnchor.constraint(equalTo: tableViewCell.trailingAnchor),
					view.topAnchor.constraint(equalTo: tableViewCell.topAnchor),
					view.bottomAnchor.constraint(equalTo: tableViewCell.bottomAnchor)
				])
			}
		}
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
		self.view?.removeFromSuperview()
		self.view = nil
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
