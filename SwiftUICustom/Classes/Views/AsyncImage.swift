//
//  AsyncImage.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 6/30/21.
//

import Foundation

public enum AsyncImagePhase {
    case loading
    case success(Image)
    case error(Error)
}

public struct AsyncImage<Content>: View where Content : View {
    @State private var state: AsyncImagePhase
    @State private var urlTask: URLSessionTask? = nil
    let mapper: (AsyncImagePhase) -> Content
    let url: URL?
    
    enum LoadingError: Error {
        case noURL
        case noData
        case notImage
    }
    
    public init(url: URL?) where Content == ConditionalContent<Image, Spacer> {
        self = AsyncImage(url: url, content: { $0 }, placeholder: { Spacer() })
    }
    
    public init<I, P>(url: URL?, @ViewBuilder content: @escaping (Image) -> I, @ViewBuilder placeholder: @escaping () -> P) where Content == ConditionalContent<I, P>, I : View, P : View {
        self = AsyncImage(url: url) { phase in
            switch phase {
            case .success(let image):
                content(image)
            default:
                placeholder()
            }
        }
    }
    
    public init(url: URL?, @ViewBuilder content: @escaping (AsyncImagePhase) -> Content) {
        self.url = url
        self._state = State(wrappedValue: .loading)
        self.mapper = content
    }
    
    public var body: OnAppearView<OnChangeView<URL?, Content>> {
        mapper(state)
            .onChange(of: url) { url in
                self.state = .loading
                makeRequest()
            }.onAppear(makeRequest)
    }
    
    private func makeRequest() {
        urlTask?.cancel()
        guard let url = url else { self.state = .error(LoadingError.noURL); return }
        let dataTask = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                self.state = .error(error)
                return
            }
            guard let data = data else { self.state = .error(LoadingError.noData); return }
            guard let image = UIImage(data: data) else { self.state = .error(LoadingError.notImage); return }
            self.state = .success(Image(uiImage: image))
        }
        dataTask.resume()
        self.urlTask = dataTask
    }
    
    public func _makeSequence(currentNode: DOMNode) -> _ViewSequence {
        return _ViewSequence(count: 1, viewGetter: {_, node in (_BuildingBlockRepresentable(buildingBlock: self), node)})
    }

}
