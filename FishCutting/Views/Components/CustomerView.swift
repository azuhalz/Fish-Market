import SwiftUI

struct CustomerView: View {
    let customerMessage: String
    let currentCustomerIndex: Int
    let customerOffset: CGFloat
    let customerOpacity: Double
    let hasShownFirstCustomer: Bool
    
    @Binding var fishOffsetX: CGFloat
    let onFirstCustomerShown: () -> Void
    
    var body: some View {
        VStack {
            ZStack {
                Image("text_bubble")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 100)
                    .offset(y: 8)
                
                Text(customerMessage)
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(.black)
            }
            
            Image("person_\(currentCustomerIndex)")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
                .offset(x: customerOffset)
                .opacity(customerOpacity)
                .animation(.easeOut(duration: 0.5), value: customerOffset)
                .onAppear {
                    if !hasShownFirstCustomer {
                        onFirstCustomerShown()
                        showFirstCustomer()
                    }
                }
        }
    }
    
    private func showFirstCustomer() {
        var customerOffset: CGFloat = 300
        fishOffsetX = 400
        var customerOpacity: Double = 0
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeOut(duration: 0.5)) {
                customerOffset = 0
                fishOffsetX = 0
                customerOpacity = 1
            }
        }
    }
}

#Preview {
    CustomerView(
        customerMessage: "Please cut into 3 pieces",
        currentCustomerIndex: 1,
        customerOffset: 0,
        customerOpacity: 1.0,
        hasShownFirstCustomer: true,
        fishOffsetX: .constant(0),
        onFirstCustomerShown: {}
    )
    .background(Color.yellow.opacity(0.3))
}
