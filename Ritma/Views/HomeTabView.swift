import SwiftUI

struct HomeTabView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "house.fill")
                }

            JournalView()
                .tabItem {
                    Label("Journal", systemImage: "list.bullet.rectangle.fill")
                }

            ResourcesView()
                .tabItem {
                    Label("Ressources", systemImage: "play.rectangle.fill")
                }

            BlockerView()
                .tabItem {
                    Label("Blocker", systemImage: "lock.shield.fill")
                }

            EmergencyView()
                .tabItem {
                    Label("Emergency", systemImage: "exclamationmark.triangle.fill")
                }
        }
        .tint(Color.appAccent)
        .toolbarBackground(Color.appSurface, for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
        .toolbarColorScheme(.dark, for: .tabBar)
        .navigationBarHidden(true)
    }
}

#Preview {
    HomeTabView()
}
