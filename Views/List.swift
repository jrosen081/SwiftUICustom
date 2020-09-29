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
		let view = self.viewCreator.__toUIView(enclosingController: enclosingController, environment: newEnvironment)
		(view as? InternalLazyCollatedView)?.expand()
		let tableView = SwiftUITableView(lazyView: view as? InternalLazyCollatedView ?? InternalLazyCollatedView(arrayValues: [view], viewCreator: { $0 }))
		return tableView
	}
	
	public func _redraw(view: UIView, controller: UIViewController, environment: EnvironmentValues) {
		if let tableView = view as? SwiftUITableView {
			var newEnvironment: EnvironmentValues = EnvironmentValues(environment)
			newEnvironment.foregroundColor = newEnvironment.foregroundColor ?? newEnvironment.defaultForegroundColor
			let view = self.viewCreator.__toUIView(enclosingController: controller, environment: newEnvironment)
			(view as? InternalLazyCollatedView)?.expand()
			tableView.lazyView = view as? InternalLazyCollatedView ?? InternalLazyCollatedView(arrayValues: [view], viewCreator: { $0 })
			tableView.reloadData()
		}
	}
}

class SwiftUITableView: UITableView {
	
	override var intrinsicContentSize: CGSize {
		return UIView.layoutFittingExpandedSize
	}
	
	override func willExpand(in context: ExpandingContext) -> Bool {
		return true
	}
	var lazyView: InternalLazyCollatedView
	
	var tableViewClickedResponses: [IndexPath: () -> ()] = [:]
	
	init(lazyView: InternalLazyCollatedView) {
		self.lazyView = lazyView
		super.init(frame: .zero, style: .plain)
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

extension SwiftUITableView: UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return lazyView.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let view = self.lazyView[indexPath.row]
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
		let height = self.lazyView[indexPath.row].intrinsicContentSize.height
		return height
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
