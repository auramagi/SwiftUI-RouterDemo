//
//  Router.swift
//  SwiftUI-RouterDemo
//
//  Created by 史 翔新 on 2021/05/17.
//

import SwiftUI

final class Router: ObservableObject {
    @Published var viewARoute: ViewARoute?
    
    @Published var viewBRoute: ViewBRoute?
}

struct RouterView {
    @StateObject var router: Router = .init()
    
    private func makeViewA() -> some View {
        makeRoutedView(
            id: "A",
            content: ViewA(router: router)
        )
    }
    
    private func makeViewB() -> some View {
        makeRoutedView(
            id: "B",
            content: ViewB(router: router)
        )
    }
    
    private func makeViewC() -> some View {
        makeRoutedView(
            id: "C",
            content: ViewC(router: router)
        )
    }
    
    private func makeViewD(int: Int) -> some View {
        ViewD(router: router, int: int)
    }
    
    private func makeViewZ() -> some View {
        makeRoutedView(
            id: "Z",
            content: ViewZ(router: router)
        )
    }
    
    private func makeRoutedView<Content: View>(id: String, content: Content) -> some View {
        content
            .injectRouter(
                navigationBinding: navigationBinding(for: id),
                presentationBinding: presentationBinding(for: id),
                navigationDestinationBuilder: { AnyView(nextNavigationView(for: id)) },
                presentationDestinationBuilder: { AnyView(nextPresentationView(for: id)) }
            )
    }
    
}

extension RouterView: View {
    
    var body: some View {
        NavigationView {
            makeViewA()
        }
    }
    
}

extension RouterView {
    
    @ViewBuilder
    private func nextViewAfterA() -> some View {
        
        if let route = router.viewARoute {
            switch route {
            case .b:
                makeViewB()
                
            case .c:
                makeViewC()
                
            case .z:
                makeViewZ()
            }
            
        } else {
            EmptyView()
        }
        
    }
    
    @ViewBuilder
    private func nextViewAfterB() -> some View {
        
        if let route = router.viewBRoute {
            switch route {
            case .d(let int):
                makeViewD(int: int)
            }
            
        } else {
            EmptyView()
        }
        
    }
    
}

extension RouterView {
    
    func navigationBinding(for viewID: String) -> Binding<Bool> {
        switch viewID {
        case "A":
            return .init(get: { return router.viewARoute == .b || router.viewARoute == .c },
                         set: { assert($0 == false); router.viewARoute = nil })
            
        case "B":
            return .init(get: { return router.viewBRoute != nil },
                         set: { assert($0 == false); router.viewBRoute = nil })
            
        default:
            return .constant(false)
        }
    }
    
    @ViewBuilder
    func nextNavigationView(for viewID: String) -> some View {
        switch viewID {
        case "A":
            nextViewAfterA()

        case "B":
            nextViewAfterB()

        default:
            EmptyView()
        }
    }
    
    func presentationBinding(for viewID: String) -> Binding<Bool> {
        switch viewID {
        case "A":
            return .init(get: { return router.viewARoute == .z },
                         set: { assert($0 == false); router.viewARoute = nil })
            
        default:
            return .constant(false)
        }
    }
    
    @ViewBuilder
    func nextPresentationView(for viewID: String) -> some View {
        switch viewID {
        case "A":
            nextViewAfterA()

        default:
            EmptyView()
        }
    }
    
}

extension Router: ViewARouterDelegate {
    
    func viewNeedsRoute(to route: ViewARoute) {
        viewARoute = route
    }
    
}

extension Router: ViewBRouterDelegate {
    
    func viewNeedsRoute(to route: ViewBRoute) {
        viewBRoute = route
    }
    
}

extension Router: ViewCRouterDelegate {
    
    func viewNeedsRoute(to route: ViewCRoute) {
        switch route {
        case .back:
            assert(viewARoute == .c)
            viewARoute = nil
        }
    }
    
}

extension Router: ViewDRouterDelegate {
    
    func viewNeedsRoute(to route: ViewDRoute) {
        switch route {
        case .root:
            assert(viewARoute == .b)
            assert(viewBRoute?.isD ?? false)
            viewARoute = nil
            viewBRoute = nil
        }
    }
    
}

extension Router: ViewZRouterDelegate {
    
    func viewNeedsRoute(to route: ViewZRoute) {
        switch route {
        case .done:
            assert(viewARoute == .z)
            viewARoute = nil
        }
    }
    
}

private extension ViewBRoute {
    var isD: Bool {
        switch self {
        case .d:
            return true
        }
    }
}
