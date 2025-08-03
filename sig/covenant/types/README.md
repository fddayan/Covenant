# Covenant Types - Detailed RBS Definitions

This directory contains detailed RBS type signatures for the Covenant type system under `lib/covenant/types/`.

## Type Hierarchy

```
BaseType (abstract)
├── BaseProp (adds struct conversion)
│   ├── Scalar (single typed values)
│   └── PropArray (arrays of typed values)
└── Props (collections of properties)
    └── Schema (structured data with validation)
```

## Core Classes

### `Tag` 
Base class for all tagged entities with `tag`, `parent`, and `child` attributes.

### `BaseType < Tag`
Abstract base class providing:
- `call(values)` - validation method (abstract)
- `empty?()` - emptiness check (abstract) 
- `compare(other)` - comparison method (abstract)
- `same?(other)` - equality check

### `BaseProp < BaseType`
Extends BaseType with property-specific methods:
- `struct()` - converts to Schema
- `to_props()` - converts to Props collection
- `name()` - alias for tag

### `Scalar < BaseProp`
Represents single typed values:
- **Validation**: Uses `Validator::Validator` for type checking
- **Composition**: Can be combined with `+` operator
- **Arrays**: Can create arrays with `.array()`
- **Optionals**: Can make optional with `.optional()`  
- **Branding**: Can be branded to structs with `.brand_to()`

### `Props < BaseType`
Represents collections of properties:
- **Storage**: Internally uses `Set[Scalar | Schema]`
- **Operations**: Supports `+`, `-`, `pick`, `omit`
- **Validation**: Validates hash inputs against all properties
- **Iteration**: Supports `each`, `map`, enumerable operations

### `Schema < BaseType`
Represents structured data with validation:
- **Composition**: Built from Props or Hash definitions
- **Validation**: Full struct validation with detailed error reporting
- **Operations**: Supports all Props operations plus schema-specific ones
- **Comparison**: Deep comparison with other schemas via `compare()`

### `PropArray < BaseProp`
Represents arrays of typed elements:
- **Element Type**: Contains a `Scalar` for element validation
- **Validation**: Validates each array element
- **Transformation**: Handles both primitive and struct elements

## Built-in Constants

The following constants are defined (though currently commented out in source):

- `Any: Schema` - Accepts any value without validation
- `Void: Schema` - Represents no meaningful return value  
- `Bool: Schema` - Represents boolean true/false values

## Usage Examples

```ruby
# Creating scalar types
user_id = Covenant.Scalar(:id, Covenant.Validate.coerce(:integer))
email = Covenant.Scalar(:email, Covenant.Validate.coerce(:string))

# Creating schemas  
user_schema = Covenant.Schema(:user, id: user_id, email: email)

# Type operations
optional_email = email.optional
user_array = user_schema.array
combined_props = user_id + email
```

## Type Safety Features

1. **Validation**: All types validate inputs and return `ValidationResult`
2. **Composition**: Type-safe combination of types with `+`/`-` operators
3. **Transformation**: Safe conversion between related types
4. **Comparison**: Deep structural comparison for schema compatibility
5. **Error Handling**: Detailed error reporting with location information

## RBS Signature Notes

- Uses `untyped` for complex inter-type relationships
- Generic methods marked with `[T]` for type parameters
- Union types used where multiple types are accepted
- Optional parameters marked with `?`
- Private methods included for complete API coverage

The RBS definitions provide static type checking for the entire Covenant type system, ensuring type safety during development while maintaining runtime flexibility.