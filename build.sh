#!/bin/bash

# Build script for Datadog Menu Bar application

set -e

echo "🔨 Building Datadog Menu Bar..."

# Clean previous build
echo "🧹 Cleaning previous build..."
swift package clean

# Build the project
echo "📦 Building in release mode..."
swift build -c release

# Check if build was successful
if [ $? -eq 0 ]; then
    echo "✅ Build successful!"
    echo ""
    echo "🚀 To run the application:"
    echo "   .build/release/DatadogMenuBar"
    echo ""
    echo "🔧 To run with debug logging:"
    echo "   DATADOG_DEBUG=1 .build/release/DatadogMenuBar"
    echo ""
    echo "🔑 Don't forget to set your Datadog API credentials!"
    echo "   Either use the GUI settings or set environment variables:"
    echo "   export DATADOG_API_KEY='your-api-key'"
    echo "   export DATADOG_APP_KEY='your-app-key'"
    echo "   export DATADOG_REGION='EU1'  # Optional: US1, EU1, US3, US5, AP1, GOV"
else
    echo "❌ Build failed!"
    exit 1
fi 