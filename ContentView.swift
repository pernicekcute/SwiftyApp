import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)
            
            ExploreView()
                .tabItem {
                    Label("Explore", systemImage: "magnifyingglass")
                }
                .tag(1)
            
            NotificationsView()
                .tabItem {
                    Label("Alerts", systemImage: "bell.fill")
                }
                .badge(3) // Optional badge count
                .tag(2)
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle.fill")
                }
                .tag(3)
        }
        .tint(.blue) // Sets active tab color
    }
}

// MARK: - Sample Page Views

struct HomeView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 12) {
                    Image(systemName: "house.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(.blue)
                    
                    Text("Home Page")
                        .font(.title)
                        .fontWeight(.bold)
                }
            }
            .navigationTitle("Home")
        }
    }
}

struct ExploreView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 60))
                        .foregroundStyle(.blue)
                    
                    Text("Explore Page")
                        .font(.title)
                        .fontWeight(.bold)
                }
            }
            .navigationTitle("Explore")
        }
    }
}

struct NotificationsView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 12) {
                    Image(systemName: "bell.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(.blue)
                    
                    Text("Notifications Page")
                        .font(.title)
                        .fontWeight(.bold)
                }
            }
            .navigationTitle("Notifications")
        }
    }
}

struct ProfileView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 12) {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(.blue)
                    
                    Text("Profile Page")
                        .font(.title)
                        .fontWeight(.bold)
                }
            }
            .navigationTitle("Profile")
        }
    }
}

#Preview {
    ContentView()
}
