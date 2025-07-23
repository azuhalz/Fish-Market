import SwiftUI

struct CustomerView: View {
    let customerMessage: String
    let currentCustomerIndex: Int
    let customerState: CustomerState
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
                    .frame(width: 250, height: 100)
                    .offset(y: 5)
                
                Text(customerMessage)
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(.black)
            }
            .offset(y: 70)
            
            Image("person_\(currentCustomerIndex)\(customerState.imageSuffix)")
                .resizable()
                .scaledToFit()
                .frame(width: 225, height: 225)
                .offset(x: customerOffset, y: 45)
                .opacity(customerOpacity)
                .animation(.easeInOut(duration: 0.3), value: customerState)
                .onAppear {
                    if !hasShownFirstCustomer {
                        onFirstCustomerShown()
                    }
                }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        // Preview asking state
        CustomerView(
            customerMessage: "Please cut into 3",
            currentCustomerIndex: 1,
            customerState: .asking,
            customerOffset: 0,
            customerOpacity: 1.0,
            hasShownFirstCustomer: true,
            fishOffsetX: .constant(0),
            onFirstCustomerShown: {}
        )
        
        // Preview satisfied state
        CustomerView(
            customerMessage: "Thank you!",
            currentCustomerIndex: 1,
            customerState: .satisfied,
            customerOffset: 0,
            customerOpacity: 1.0,
            hasShownFirstCustomer: true,
            fishOffsetX: .constant(0),
            onFirstCustomerShown: {}
        )
        
        // Preview unsatisfied state
        CustomerView(
            customerMessage: "It's so bad",
            currentCustomerIndex: 1,
            customerState: .unsatisfied,
            customerOffset: 0,
            customerOpacity: 1.0,
            hasShownFirstCustomer: true,
            fishOffsetX: .constant(0),
            onFirstCustomerShown: {}
        )
    }
    .background(Color.yellow.opacity(0.3))
}
