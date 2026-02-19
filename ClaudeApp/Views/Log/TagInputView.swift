import SwiftUI

struct TagInputView: View {
    let currentTags: [String]
    let suggestions: [String]
    let onAdd: (String) -> Void
    let onRemove: (String) -> Void

    @State private var inputText = ""
    @FocusState private var isFocused: Bool

    private var filteredSuggestions: [String] {
        guard !inputText.isEmpty else { return [] }
        let query = inputText.lowercased()
        return suggestions
            .filter { $0.contains(query) && !currentTags.contains($0) }
            .prefix(5)
            .map { $0 }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            // Current tags as removable chips
            if !currentTags.isEmpty {
                FlowLayout(spacing: AppTheme.Spacing.xs) {
                    ForEach(currentTags, id: \.self) { tag in
                        TagChip(tag: tag) {
                            withAnimation(AppTheme.gentleAnimation) {
                                onRemove(tag)
                            }
                        }
                    }
                }
            }

            // Input row
            HStack(spacing: AppTheme.Spacing.sm) {
                TextField("Add a tag...", text: $inputText)
                    .font(.system(.body, design: .rounded))
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .focused($isFocused)
                    .onSubmit {
                        commitTag()
                    }

                Button {
                    commitTag()
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .foregroundStyle(inputText.trimmingCharacters(in: .whitespaces).isEmpty ? Color.appSoftBrown.opacity(0.3) : Color.appTerracotta)
                }
                .disabled(inputText.trimmingCharacters(in: .whitespaces).isEmpty)
            }

            // Autocomplete suggestions
            if !filteredSuggestions.isEmpty {
                FlowLayout(spacing: AppTheme.Spacing.xs) {
                    ForEach(filteredSuggestions, id: \.self) { suggestion in
                        Button {
                            withAnimation(AppTheme.gentleAnimation) {
                                onAdd(suggestion)
                                inputText = ""
                            }
                        } label: {
                            Text(suggestion.capitalized)
                                .font(.system(.caption, design: .rounded))
                                .foregroundStyle(Color.appTerracotta)
                                .padding(.horizontal, AppTheme.Spacing.sm)
                                .padding(.vertical, AppTheme.Spacing.xs)
                                .background(Color.appTerracotta.opacity(0.08))
                                .clipShape(Capsule())
                        }
                    }
                }
            }
        }
    }

    private func commitTag() {
        let trimmed = inputText.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        withAnimation(AppTheme.gentleAnimation) {
            onAdd(trimmed)
        }
        inputText = ""
    }
}

struct TagChip: View {
    let tag: String
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 4) {
            Text(tag.capitalized)
                .font(.system(.caption, design: .rounded))

            Button {
                onRemove()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption2)
            }
        }
        .foregroundStyle(Color.appTerracotta)
        .padding(.horizontal, AppTheme.Spacing.sm)
        .padding(.vertical, AppTheme.Spacing.xs)
        .background(Color.appTerracotta.opacity(0.12))
        .clipShape(Capsule())
    }
}
