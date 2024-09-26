//
//  ServerRowView.swift
//  MC Status
//
//  Created by Tomer Shemesh on 9/25/24.
//

import SwiftUI

struct ServerRowView: View {
    var title: String
    var subtitle: String
    
    var body: some View {
        HStack {
                    VStack(alignment: .leading) {
                        Text(title)
                            .font(.headline)
                            .foregroundColor(.primary)
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                }
//                .background(Color(.systemBackground))
//                .cornerRadius(8)
//                .shadow(radius: 2)
    }
}

#Preview {
    ServerRowView(title: "test", subtitle: "subtitle")
}
