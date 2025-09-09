# Currency Converter App

A modern iOS currency converter application that uses the TransferGo API to fetch real-time exchange rates. The app allows users to convert between different currencies with support for PLN, EUR, GBP, and UAH.

## Features

- Real-time currency conversion using TransferGo API
- Support for 4 major currencies: PLN, EUR, GBP, UAH
- Clean and intuitive user interface
- Bidirectional conversion (swap currencies)
- Input validation and error handling
- Search functionality for currency selection
- Unit tests for core functionality

## Requirements

- iOS 15.0+
- Xcode 13.0+
- Swift 5.5+

## Installation

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd LoginExampleApp
   ```

2. Open the project in Xcode:
   ```bash
   open LoginExampleApp.xcodeproj
   ```

3. Build and run the project using the Xcode simulator or a physical device.

## Project Structure

```
LoginExampleApp/
├── LoginExampleApp/
│   ├── CurrencyConverter/
│   │   ├── Models/
│   │   │   └── Currency.swift
│   │   ├── Services/
│   │   │   └── APIService.swift
│   │   ├── ViewModels/
│   │   │   └── CurrencyConverterViewModel.swift
│   │   └── Views/
│   │       ├── CurrencyConverterView.swift
│   │       └── CurrencySelectionView.swift
│   ├── LoginExampleApp.swift
│   └── ... (other app files)
├── LoginExampleAppTests/
│   └── CurrencyConverterTests/
│       └── CurrencyConverterViewModelTests.swift
└── README.md
```

## Architecture

The app follows the MVVM (Model-View-ViewModel) architecture pattern with Combine for reactive programming:

- **Models**: Define the data structures and business logic
- **ViewModels**: Handle the presentation logic and state management
- **Views**: Present the UI and handle user interactions
- **Services**: Handle network requests and data persistence

## Testing

The project includes unit tests for the ViewModel and API service. To run the tests:

1. Open the project in Xcode
2. Press `Cmd + U` or go to `Product > Test`

## Dependencies

- **SwiftUI**: For building the user interface
- **Combine**: For reactive programming and data binding
- **Swift Package Manager**: For dependency management (none currently used, but ready for future use)

## API Integration

The app uses the TransferGo API for fetching exchange rates:
- Endpoint: `https://my.transfergo.com/api/fx-rates`
- Parameters: `from`, `to`, `amount`

## Known Limitations

- Currently supports only 4 currencies (PLN, EUR, GBP, UAH)
- Requires an internet connection to fetch exchange rates
- No offline support for cached rates

## Future Improvements

- Add more currencies
- Implement offline mode with cached rates
- Add historical rate charts
- Support for favorite currency pairs
- Biometric authentication for security
- Dark mode support

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Author

Rimvydas P.

## Acknowledgments

- TransferGo for providing the FX rates API
- Apple for SwiftUI and Combine frameworks
