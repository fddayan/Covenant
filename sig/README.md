# RBS Type Signatures for Covenant

This directory contains Ruby signature files (RBS) for the Covenant library, providing static type checking support.

## Usage

### Type Checking with Steep

Run type checking across the entire codebase:

```bash
# Check the lib directory
bundle exec steep check

# Check only lib target
bundle exec steep check --target lib

# Check only test target  
bundle exec steep check --target test

# Watch mode for continuous checking
bundle exec steep watch --target lib
```

### Validating RBS Files

Validate the syntax of RBS files:

```bash
# Validate all RBS files
bundle exec rbs validate

# Validate specific files
bundle exec rbs validate sig/covenant/contracts.rbs
```

### RBS Analysis

Analyze and inspect type definitions:

```bash
# Show all types
bundle exec rbs list

# Show specific class/module
bundle exec rbs show Covenant::Contracts::Contract

# Show ancestors
bundle exec rbs ancestors Covenant::Contracts::Contract
```

## File Structure

- `covenant.rbs` - Main module and top-level definitions
- `covenant/contracts.rbs` - Contract classes and interfaces
- `covenant/handlers.rbs` - Handler composition utilities
- `covenant/types.rbs` - Type system (Scalar, Schema, Props)
- `covenant/compositions.rbs` - Composition classes (Map, Tee, etc.)
- `covenant/runtime.rbs` - Runtime execution classes
- `covenant/validator.rbs` - Validation system
- `covenant/container.rbs` - Dependency injection container
- `covenant/comparable.rbs` - Comparison utilities
- `covenant/ast.rbs` - Abstract syntax tree classes
- `covenant/diff.rbs` - Diff utilities
- `covenant/formatter.rbs` - Output formatting

## Configuration

The type checking behavior is configured in the root `Steepfile`:

- **lib target**: Lenient checking for gradual typing adoption
- **test target**: Silent checking for test files
- Ignores certain strict diagnostics to reduce noise during development

## Development Workflow

1. **Add type annotations gradually** - Start by adding signatures to public APIs
2. **Run Steep regularly** - Use `steep watch` during development
3. **Fix high-priority issues first** - Focus on type errors over warnings
4. **Update RBS files** - Keep signatures in sync with code changes

## Type Checking Tips

- Use `untyped` for complex types that are hard to express
- Add `?` suffix for optional parameters/return types
- Use union types with `|` for multiple possible types
- Leverage generic types with `[T]` where appropriate

## Example Usage

```ruby
# This code will be type-checked against the RBS signatures
contract = Covenant::Contracts::Contract.new(:fetch_user, user_id_type, user_type)
result = runtime.call(contract, { id: 42 })

if result.success?
  user = result.unwrap
  puts user[:name]
end
```

The RBS files provide static guarantees about method signatures, return types, and class structures without runtime overhead.