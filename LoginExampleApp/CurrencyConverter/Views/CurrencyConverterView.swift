import SwiftUI

struct CurrencyConverterView: View {
    @StateObject private var viewModel = CurrencyConverterViewModel()
    @State private var showFromCurrencyPicker = false
    @State private var showToCurrencyPicker = false
    
    var body: some View {
        VStack(spacing: 20) {
            // From Currency Section
            VStack(alignment: .leading, spacing: 8) {
                Text("Sending from")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                HStack {
                    // Currency Selection Button
                    Button(action: {
                        showFromCurrencyPicker = true
                    }) {
                        HStack {
                            Text(viewModel.fromCurrency.code)
                                .font(.title2)
                                .fontWeight(.semibold)
                            Image(systemName: "chevron.down")
                                .font(.caption)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Spacer()
                    
                    // Amount Input
                    TextField("0.00", text: $viewModel.fromAmount)
                        .keyboardType(.decimalPad)
                        .font(.largeTitle)
                        .multilineTextAlignment(.trailing)
                }
                
                Divider()
                
                // Currency Details
                HStack {
                    Text(viewModel.fromCurrency.name)
                        .font(.caption)
                        .foregroundColor(.gray)
                    Spacer()
                    Text("Max: \(viewModel.fromCurrency.maxAmount, specifier: "%.2f") \(viewModel.fromCurrency.code)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(radius: 2)
            .padding(.horizontal)
            
            // Swap Button
            Button(action: {
                viewModel.swapCurrencies()
            }) {
                Image(systemName: "arrow.up.arrow.down.circle.fill")
                    .font(.title)
                    .foregroundColor(.blue)
                    .padding(8)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(radius: 2)
            }
            .padding(.vertical, 8)
            
            // To Currency Section
            VStack(alignment: .leading, spacing: 8) {
                Text("Receiver gets")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                HStack {
                    // Currency Selection Button
                    Button(action: {
                        showToCurrencyPicker = true
                    }) {
                        HStack {
                            Text(viewModel.toCurrency.code)
                                .font(.title2)
                                .fontWeight(.semibold)
                            Image(systemName: "chevron.down")
                                .font(.caption)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(8)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Spacer()
                    
                    // Converted Amount
                    Text(viewModel.toAmount.isEmpty ? "0.00" : viewModel.toAmount)
                        .font(.largeTitle)
                        .foregroundColor(viewModel.toAmount.isEmpty ? .gray : .primary)
                        .multilineTextAlignment(.trailing)
                }
                
                Divider()
                
                // Exchange Rate
                if viewModel.exchangeRate > 0 {
                    HStack {
                        Text("1 \(viewModel.fromCurrency.code) = \(viewModel.exchangeRate, specifier: "%.4f") \(viewModel.toCurrency.code)")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Spacer()
                    }
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(radius: 2)
            .padding(.horizontal)
            
            Spacer()
    
            if viewModel.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding()
            }
        }
        .background(Color(.systemGroupedBackground).edgesIgnoringSafeArea(.all))
        .sheet(isPresented: $showFromCurrencyPicker) {
            CurrencySelectionView(selectedCurrency: $viewModel.fromCurrency, 
                              excludedCurrency: viewModel.toCurrency)
        }
        .sheet(isPresented: $showToCurrencyPicker) {
            CurrencySelectionView(selectedCurrency: $viewModel.toCurrency,
                              excludedCurrency: viewModel.fromCurrency)
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil), actions: {
            Button("OK", role: .cancel) {}
        }, message: {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
            }
        })
    }
}
