import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct CurrencyConverterView: View {
    @StateObject private var viewModel = CurrencyConverterViewModel()
    @State private var showFromCurrencyPicker = false
    @State private var showToCurrencyPicker = false
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
                .frame(height: 44)
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 12) {
                    Spacer()
                        .frame(width: 6, height: 0) // Match flag width
                    
                    Text("Sending from")
                        .font(.system(size: 12))
                        .foregroundColor(Color(white: 0.6))
                    
                    Spacer()
                }
                
                HStack(spacing: 12) {
                    // Flag
                    Image(viewModel.fromCurrency.flagName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 32, height: 32)
                    
                    // Currency selection button
                    Button(action: {
                        withAnimation(.easeOut(duration: 0.3)) {
                            showFromCurrencyPicker = true
                        }
                    }) {
                        HStack(spacing: 8) {
                            Text(viewModel.fromCurrency.code)
                                .font(.custom("Inter-Bold", size: 14))
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                            Image(systemName: "chevron.down")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.black)
                        }
                        .frame(width: 92, height: 32)
                        .background(Color(hex: "#EDF0F4"))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(hex: "#EDF0F4"), lineWidth: 1)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Spacer()
                    
                    TextField("0.00", text: $viewModel.fromAmount)
                        .keyboardType(.decimalPad)
                        .font(.largeTitle)
                        .multilineTextAlignment(.trailing)
                        .fixedSize(horizontal: true, vertical: false)
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(radius: 2)
            .padding(.horizontal)
            .animation(.easeOut(duration: 0.3), value: viewModel.fromAmount)
            
            HStack(spacing: 16) {
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
                .buttonStyle(PlainButtonStyle())
                if viewModel.exchangeRate > 0 {
                    Text("1 \(viewModel.fromCurrency.code) = \(viewModel.exchangeRate, specifier: "%.4f") \(viewModel.toCurrency.code)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            .padding(.vertical, 8)
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 12) {
                    Spacer()
                        .frame(width: 6, height: 0) // Match flag width
                    
                    Text("Receiver gets")
                        .font(.system(size: 12))
                        .foregroundColor(Color(white: 0.6))
                    
                    Spacer()
                }
                
                HStack(spacing: 12) {
                    // Flag
                    Image(viewModel.toCurrency.flagName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 32, height: 32)
                    
                    // Currency selection button
                    Button(action: {
                        withAnimation(.easeOut(duration: 0.3)) {
                            showToCurrencyPicker = true
                        }
                    }) {
                        HStack(spacing: 8) {
                            Text(viewModel.toCurrency.code)
                                .font(.custom("Inter-Bold", size: 14))
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                            Image(systemName: "chevron.down")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.black)
                        }
                        .frame(width: 92, height: 32)
                        .background(Color(hex: "#EDF0F4"))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(hex: "#EDF0F4"), lineWidth: 1)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Spacer()
                    
                    Text(viewModel.toAmount.isEmpty ? "0.00" : viewModel.toAmount)
                        .font(.largeTitle)
                        .foregroundColor(viewModel.toAmount.isEmpty ? .gray : .primary)
                        .multilineTextAlignment(.trailing)
                        .fixedSize(horizontal: true, vertical: false)
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(radius: 2)
            .padding(.horizontal)
            .animation(.easeOut(duration: 0.3), value: viewModel.toAmount)
            
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
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK", role: .cancel) {
                viewModel.errorMessage = nil
            }
        } message: {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
            }
        }
    }
}
