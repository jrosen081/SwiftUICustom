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
	
	public func __toUIView(enclosingController: UIViewController, environment: EnvironmentValues) -> UIView {
		var newEnvironment: EnvironmentValues = EnvironmentValues(environment)
		newEnvironment.foregroundColor = newEnvironment.foregroundColor ?? newEnvironment.defaultForegroundColor
        let tableView = SwiftUITableView(buildingBlocks: self.viewCreator.expanded().toSections, style: environment.listStyle._tableViewStyle)
        tableView.viewController = enclosingController
        tableView.environment = newEnvironment
		return tableView
	}
	
	public func _redraw(view: UIView, controller: UIViewController, environment: EnvironmentValues) {
		if let tableView = view as? SwiftUITableView {
			var newEnvironment: EnvironmentValues = EnvironmentValues(environment)
			newEnvironment.foregroundColor = newEnvironment.foregroundColor ?? newEnvironment.defaultForegroundColor
			let view = self.viewCreator
            tableView.buildingBlocks = view.expanded().toSections
            tableView.environment = environment
            tableView.viewController = controller
			tableView.reloadData()
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
    
    var viewController: UIViewController = UIViewController()
	
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
        return (self.buildingBlocks[section].headerView?.__toUIView(enclosingController: viewController, environment: environment)).map({ underlyingView in
            let sectionHeader = HeaderFooterView(frame: .zero)
            sectionHeader.contentView.addSubview(underlyingView)
            sectionHeader.setupFullConstraints(sectionHeader.contentView, underlyingView)
            return sectionHeader
        })
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.tableView(tableView, viewForHeaderInSection: section)?.intrinsicContentSize.height ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return self.tableView(tableView, viewForFooterInSection: section)?.intrinsicContentSize.height ?? 0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return (self.buildingBlocks[section].footerView?.__toUIView(enclosingController: viewController, environment: environment)).map({ underlyingView in
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
        let view = self.buildingBlocks[indexPath.section].buildingBlocks[indexPath.row].__toUIView(enclosingController: viewController, environment: self.environment)
		guard let cell = tableView.dequeueReusableCell(withIdentifier: "SwiftUI") as? SwiftUITableViewCell else { return UITableViewCell() }
		if let onClick = view.insideList(width: self.frame.width) {
			self.tableViewClickedResponses[indexPath] = onClick
			cell.view = view
			return cell
		}
		if view.willExpand(in: .vertical) {
			cell.view = view
			return cell
		}
		cell.view = HStack {
			UIViewWrapper(view: view)
			Spacer()
			}.__toUIView(enclosingController: UIViewController(), environment: EnvironmentValues())
		return cell
	}
}

extension SwiftUITableView: UITableViewDelegate {
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		self.tableViewClickedResponses[indexPath]?()
		tableView.deselectRow(at: indexPath, animated: true)
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let height = self.buildingBlocks[indexPath.section].buildingBlocks[indexPath.row].__toUIView(enclosingController: UIViewController(), environment: self.environment)
        height.insideList(width: tableView.frame.width)
        return height.intrinsicContentSize.height
	}
}

class SwiftUITableViewCell: UITableViewCell {
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
	}
	
	var view: UIView? {
		didSet {
			if let view = self.view {
				let tableViewCell = self
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
