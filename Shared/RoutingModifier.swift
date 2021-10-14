//
//  RoutingModifier.swift
//  SwiftUI-RouterDemo
//
//  Created by 史 翔新 on 2021/05/17.
//

import SwiftUI

struct RoutingModifier: ViewModifier {
    @Binding var navigationBinding: Bool
    
    @Binding var presentationBinding: Bool
    
    var navigationDestinationBuilder: () -> AnyView
    
    var presentationDestinationBuilder: () -> AnyView
    
    func body(content: Content) -> some View {
        content
            .background(
                EmptyNavigationLink(
                    destination: navigationDestinationBuilder(),
                    isActive: $navigationBinding
                )
            )
            .fullScreenCover(
                isPresented: $presentationBinding,
                content: presentationDestinationBuilder
            )
    }
    
}

private struct EmptyNavigationLink<Destination: View>: View {
    
    var destination: Destination
    var isActive: Binding<Bool>
    
    var body: some View {
        NavigationLink(
            destination: destination, isActive: isActive, label: { EmptyView() })
    }
    
}

extension View {
    
    func injectRouter(
        navigationBinding: Binding<Bool>,
        presentationBinding: Binding<Bool>,
        @ViewBuilder navigationDestinationBuilder: @escaping () -> AnyView,
        @ViewBuilder presentationDestinationBuilder: @escaping () -> AnyView
    ) -> some View {
        modifier(RoutingModifier(navigationBinding: navigationBinding, presentationBinding: presentationBinding, navigationDestinationBuilder: navigationDestinationBuilder, presentationDestinationBuilder: presentationDestinationBuilder))
    }
    
}
