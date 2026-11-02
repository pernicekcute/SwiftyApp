import SwiftUI

struct PagedContentView: View {
    var body: some View {
        TabView {
            PageOne()
            PageTwo()
            PageThree()
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .indexViewStyle(.page(backgroundDisplayMode: .always))
        .ignoresSafeArea()
    }
}

struct PageOne: View {
    var body: some View {
        ZStack {
            Color.blue.ignoresSafeArea()
            Text("Page 1")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
    }
}

struct PageTwo: View {
    var body: some View {
        ZStack {
            Color.purple.ignoresSafeArea()
            Text("Page 2")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
    }
}

struct PageThree: View {
    var body: some View {
        ZStack {
            Color.orange.ignoresSafeArea()
            Text("Page 3")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
    }
}

#Preview {
    PagedContentView()
}
