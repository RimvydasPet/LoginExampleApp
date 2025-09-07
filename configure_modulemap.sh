#!/bin/bash

# This script configures the module map for the CurrencyConverter module

# Set the project directory
PROJECT_DIR="$SRCROOT/LoginExampleApp"
MODULE_MAP_DIR="$PROJECT_DIR/CurrencyConverter"

# Create the module map file
cat > "$MODULE_MAP_DIR/module.modulemap" << 'EOL'
framework module CurrencyConverter {
    umbrella header "CurrencyConverter.h"
    
    export *
    module * { export * }
    
    // Explicitly list all the headers to be exposed
    header "Models/Currency.swift"
    header "Services/APIService.swift"
    header "ViewModels/CurrencyConverterViewModel.swift"
    header "Views/CurrencyConverterView.swift"
    header "Views/CurrencySelectionView.swift"
}
EOL

echo "Module map configured at $MODULE_MAP_DIR/module.modulemap"
