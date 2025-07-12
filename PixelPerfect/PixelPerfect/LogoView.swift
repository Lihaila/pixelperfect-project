import SwiftUI

struct LogoView: View {
    let size: CGFloat

    init(size: CGFloat = 32) {
        self.size = size
    }

    var body: some View {
        Image("Logo")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: size, height: size)
            .clipShape(RoundedRectangle(cornerRadius: size * 0.25))
    }
}

#Preview {
    HStack(spacing: 20) {
        LogoView(size: 24)
        LogoView(size: 32)
        LogoView(size: 48)
        LogoView(size: 64)
    }
    .padding()
    .background(Color.black)
}
