import SwiftUI

struct NutritionEditView: View {
    let title: String
    let unit: String
    @Binding var consumed: Double

    @Environment(\.dismiss) private var dismiss
    @State private var mode: Mode = .add
    @State private var input: String = ""
    @FocusState private var isFocused: Bool

    private enum Mode: String, CaseIterable {
        case add = "Add"
        case set = "Set Total"
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Picker("Mode", selection: $mode) {
                    ForEach(Mode.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                }
                .pickerStyle(.segmented)

                TextField(mode == .add ? "Amount" : "New Total", text: $input)
                    .keyboardType(.decimalPad)
                    .font(.system(size: 40, weight: .semibold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .focused($isFocused)

                Button(action: apply) {
                    Text(mode == .add ? "Add" : "Set")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 12))
                        .foregroundStyle(.white)
                }
                .disabled(Double(input) == nil)

                Spacer()
            }
            .padding()
            .padding(.top, 16)
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .onAppear { isFocused = true }
            .onChange(of: mode) { _, _ in input = "" }
        }
        .presentationDetents([.height(320)])
    }

    private func apply() {
        guard let value = Double(input) else { return }
        switch mode {
        case .add:
            consumed = max(0, consumed + value)
        case .set:
            consumed = max(0, value)
        }
        dismiss()
    }
}

#Preview {
    NutritionEditView(title: "Protein", unit: "g", consumed: .constant(126))
}
