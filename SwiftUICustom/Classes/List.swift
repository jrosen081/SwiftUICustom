//
//  List.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 9/1/20.
//

import Foundation

public struct List<Content: View>: View {
	let viewCreator: () -> Content
	
	public var body: Self {
		return self
	}
	
	public init(@ViewBuilder _ viewCreator: @escaping () -> Content) {
		self.viewCreator = viewCreator
	}
	
	public func toUIView(enclosingController: UIViewController) -> UIView {
		let view = self.viewCreator().toUIView(enclosingController: enclosingController)
		(view as? InternalLazyCollatedView)?.expand()
		return SwiftUITableView(lazyView: view as? InternalLazyCollatedView ?? InternalLazyCollatedView(arrayValues: [view], viewCreator: { $0 }))
	}
}

class SwiftUITableView: UITableView {
	let lazyView: InternalLazyCollatedView
	
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
	
	func toUIView(enclosingController: UIViewController) -> UIView {
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
			view.tintColor = self.tintColor
			self.tableViewClickedResponses[indexPath] = onClick
			return SwiftUITableViewCell(view: view)
		}
		view.tintColor = self.tintColor
		return SwiftUITableViewCell(view: HStack {
			UIViewWrapper(view: view)
			Spacer()
			}.toUIView(enclosingController: UIViewController())
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
