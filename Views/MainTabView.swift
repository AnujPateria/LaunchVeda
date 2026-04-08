import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0

    init() {
#if canImport(UIKit)
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = UIColor.black
        appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
#endif
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Image(systemName: selectedTab == 0 ? "house.fill" : "house")
                    Text("Home")
                }
                .tag(0)

            PostsView()
                .tabItem {
                    Image(systemName: selectedTab == 1 ? "newspaper.fill" : "newspaper")
                    Text("Updates")
                }
                .tag(1)


        }
        .tint(SpaceTheme.electricBlue)
        .preferredColorScheme(.dark)
    }
}
