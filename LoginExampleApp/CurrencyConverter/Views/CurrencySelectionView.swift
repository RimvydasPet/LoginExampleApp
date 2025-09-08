import SwiftUI

struct CurrencySelectionView: View {
    @Binding var selectedCurrency: Currency
    let excludedCurrency: Currency?
    @State private var searchText = ""
    @Environment(\.dismiss) private var dismiss
    
    private var filteredCurrencies: [Currency] {
        if searchText.isEmpty {
            return Currency.supportedCurrencies.filter { $0.code != excludedCurrency?.code }
        } else {
            return Currency.supportedCurrencies.filter {
                ($0.code.localizedCaseInsensitiveContains(searchText) ||
                 $0.name.localizedCaseInsensitiveContains(searchText)) &&
                $0.code != excludedCurrency?.code
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Search Bar
                SearchBar(text: $searchText, placeholder: "Search currencies...")
                    .padding()
                
                // Currency List
                List(filteredCurrencies) { currency in
                    Button(action: {
                        selectedCurrency = currency
                        dismiss()
                    }) {
                        HStack {
                            Text(currency.flag)
                                .font(.title2)
                            
                            VStack(alignment: .leading) {
                                Text(currency.code)
                                    .font(.headline)
                                Text(currency.name)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            if currency.code == selectedCurrency.code {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("Sending to")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Search Bar Component
struct SearchBar: View {
    @Binding var text: String
    var placeholder: String
    
    var body: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField(placeholder, text: $text)
                    .textFieldStyle(PlainTextFieldStyle())
                
                if !text.isEmpty {
                    Button(action: {
                        text = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(8)
            .background(Color(.systemGray6))
            .cornerRadius(8)
        }
    }
}
