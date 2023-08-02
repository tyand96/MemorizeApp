//
//  Cardify.swift
//  Memorize
//
//  Created by Tyler Anderson on 8/1/23.
//

import SwiftUI


struct Cardify: Animatable, ViewModifier {
        
    var rotationDeg: Double // Angle in degrees.
    
    var animatableData: Double {
        get {rotationDeg}
        set {rotationDeg = newValue}
    }
    
    init(isFaceUp: Bool) {
        rotationDeg = isFaceUp ?  0 : 180
    }
    
    func body(content: Content) -> some View {
        ZStack {
            let shape = RoundedRectangle(cornerRadius: DrawingConstants.cornerRadius)
            if rotationDeg < 90 {
                shape.fill().foregroundColor(.white)
                
                shape.strokeBorder(lineWidth: DrawingConstants.lineWidth)
                
                //content
            } else {
                shape.fill()
            }
            
            content
                .opacity(rotationDeg < 90 ? 1 : 0)
        }
        .rotation3DEffect(Angle.degrees(rotationDeg), axis: (0,1,0))
    }
    
    private struct DrawingConstants {
        static let cornerRadius: CGFloat = 10
        static let lineWidth: CGFloat = 3
    }
}

extension View {
    func cardify(isFaceUp: Bool) -> some View {
        self.modifier(Cardify(isFaceUp: isFaceUp))
    }
}
