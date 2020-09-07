//
//  List.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 9/1/20.
//

import Foundation

public struct List<Content: View>: View {
	let viewCreator: () -> Content
	
	@State var tableView: UITableView? = nil
	
	public var body: Self {
		return self
	}
	
	public init(@ViewBuilder _ viewCreator: @escaping () -> Content) {
		self.viewCreator = viewCreator
	}
	
	public func toUIView(enclosingController: UIViewController, environment: EnvironmentValues) -> UIView {
		var newEnvironment: EnvironmentValues = EnvironmentValues(environment)
		newEnvironment.foregroundColor = newEnvironment.foregroundColor ?? newEnvironment.defaultForegroundColor
		let view = self.viewCreator().toUIView(enclosingController: enclosingController, environment: newEnvironment)
		(view as? InternalLazyCollatedView)?.expand()
		let tableView = SwiftUITableView(lazyView: view as? InternalLazyCollatedView ?? InternalLazyCollatedView(arrayValues: [view], viewCreator: { $0 }))
		return tableView
	}
	
	public func redraw(view: UIView, controller: UIViewController, environment: EnvironmentValues) {
		if let tableView = view as? SwiftUITableView {
			var newEnvironment: EnvironmentValues = EnvironmentValues(environment)
			newEnvironment.foregroundColor = newEnvironment.foregroundColor ?? newEnvironment.defaultForegroundColor
			let view = self.viewCreator().toUIView(enclosingController: controller, environment: newEnvironment)
			(view as? InternalLazyCollatedView)?.expand()
			tableView.lazyView = view as? InternalLazyCollatedView ?? InternalLazyCollatedView(arrayValues: [view], viewCreator: { $0 })
			tableView.reloadData()
		}
	}
}

class SwiftUITableView: UITableView {
	var lazyView: InternalLazyCollatedView
	
	var tableViewClickedResponses: [IndexPath: () -> ()] = [:]
	
	init(lazyView: InternalLazyCollatedView) {
		self.lazyView = lazyView
		super.init(frame: .zero, style: .plain)
		self.translatesAutoresizingMaskIntoConstraints = false
		self.dataSource = self
		self.delegate = self
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

struct UIViewWrapper: View {
	let view: UIView
	
	var body: Self {
		return self
	}
	
	func toUIView(enclosingController: UIViewController, environment: EnvironmentValues) -> UIView {
		return self.view
	}
}

extension SwiftUITableView: UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return lazyView.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let view = self.lazyView[indexPath.row]
		if let onClick = view.insideList() {
			self.tableViewClickedResponses[indexPath] = onClick
			return SwiftUITableViewCell(view: view)
		}
		return SwiftUITableViewCell(view: HStack {
			UIViewWrapper(view: view)
			Spacer()
			}.toUIView(enclosingController: UIViewController(), environment: EnvironmentValues())
		)
	}
}

extension SwiftUITableView: UITableViewDelegate {
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		self.tableViewClickedResponses[indexPath]?()
		tableView.deselectRow(at: indexPath, animated: true)
	}
}

class SwiftUITableViewCell: UITableViewCell {
	init(view: UIView) {
		super.init(style: .default, reuseIdentifier: nil)
		let tableViewCell = self
		tableViewCell.addSubview(view)
		NSLayoutConstraint.activate([
			view.leadingAnchor.constraint(equalTo: tableViewCell.leadingAnchor),
			view.trailingAnchor.constraint(equalTo: tableViewCell.trailingAnchor),
			view.topAnchor.constraint(equalTo: tableViewCell.topAnchor),
			view.bottomAnchor.constraint(equalTo: tableViewCell.bottomAnchor)
		])
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
