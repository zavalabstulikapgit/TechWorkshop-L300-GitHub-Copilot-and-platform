#!/bin/bash
# Bicep Validation Script
# This script validates all Bicep templates for syntax and best practices

set -e

echo "🔍 Validating Bicep Templates..."
echo ""

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    echo "❌ Azure CLI is not installed. Please install it first."
    exit 1
fi

# Check if Bicep CLI is available
if ! az bicep version &> /dev/null; then
    echo "❌ Bicep CLI is not available. Please upgrade Azure CLI."
    exit 1
fi

echo "✅ Azure CLI and Bicep CLI are installed"
echo ""

# Validate main template
echo "📝 Validating main.bicep..."
if az bicep build --file infra/main.bicep --stdout > /dev/null 2>&1; then
    echo "  ✅ main.bicep syntax is valid"
else
    echo "  ❌ main.bicep has syntax errors"
    az bicep build --file infra/main.bicep
    exit 1
fi

# Validate all module templates
echo ""
echo "📝 Validating module templates..."
for module in infra/modules/*.bicep; do
    module_name=$(basename "$module")
    if az bicep build --file "$module" --stdout > /dev/null 2>&1; then
        echo "  ✅ $module_name is valid"
    else
        echo "  ❌ $module_name has syntax errors"
        az bicep build --file "$module"
        exit 1
    fi
done

echo ""
echo "🎉 All Bicep templates are valid!"
echo ""
echo "Next steps:"
echo "  1. Review the templates in infra/ directory"
echo "  2. Deploy using: azd up"
echo "  3. Or deploy manually: az deployment sub create --template-file infra/main.bicep --parameters infra/main.bicepparam"
