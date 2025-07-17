import SwiftUI

struct DashedLine: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        return path
    }
}

#Preview {
    VStack {
        Text("Dashed Line Examples")
            .font(.title)
            .padding()
        
        HStack(spacing: 20) {
            // Vertical dashed line
            DashedLine()
                .stroke(Color.black, style: StrokeStyle(lineWidth: 2, dash: [5]))
                .frame(width: 2, height: 100)
            
            // Another vertical dashed line
            DashedLine()
                .stroke(Color.red, style: StrokeStyle(lineWidth: 3, dash: [8, 3]))
                .frame(width: 3, height: 100)
            
            // Thicker dashed line
            DashedLine()
                .stroke(Color.blue, style: StrokeStyle(lineWidth: 4, dash: [10, 5]))
                .frame(width: 4, height: 100)
        }
        .background(Color.gray.opacity(0.2))
        .padding()
    }
}
