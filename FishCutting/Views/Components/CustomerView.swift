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
                    .frame(width: 350, height: 110)
                    .offset(y: 40)
                
                Text(customerMessage)
//                    .font(.custom("LilitaOne", size: 24))
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(Color(hex: "#1794AD"))
                    .offset(y: 30)
                
                Image("name_\(currentCustomerIndex)")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 25)
                    .offset(x: -110, y: 0-8)
            }
            .offset(x: customerOffset)
            .opacity(customerOpacity)
            .animation(.easeInOut(duration: 0.3), value: customerState)
            
            Image("person_\(currentCustomerIndex)\(customerState.imageSuffix)")
                .resizable()
                .scaledToFit()
                .frame(width: 225, height: 225)
                .offset(x: customerOffset, y: 20)
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
            customerMessage: "Please cut it perfectly!",
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
            customerMessage: "😊 Thank you! That looks amazing!",
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
