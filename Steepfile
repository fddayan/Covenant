D = Steep::Diagnostic

target :lib do
  signature 'sig'

  check 'lib'

  # Configure libraries
  library 'pathname'
  library 'logger'
  library 'mutex_m'
  library 'date'
  # library 'set'
  library 'timeout'

  # Configure type checking options
  configure_code_diagnostics(D::Ruby.strict) # Start with lenient for gradual typing
  # configure_code_diagnostics(D::Ruby.strict) # Start with lenient for gradual typing

  # Ignore certain diagnostics that are too strict for now
  configure_code_diagnostics do |hash|
    hash[D::Ruby::UnexpectedPositionalArgument] = nil
    hash[D::Ruby::UndeclaredMethodDefinition] = nil
    hash[D::Ruby::NoMethod] = nil
    hash[D::Ruby::FallbackAny] = nil
    hash[D::Ruby::UnknownConstant] = nil
    hash[D::Ruby::UnknownInstanceVariable] = nil
    hash[D::Ruby::UnannotatedEmptyCollection] = nil
    # hash[D::Ruby::UnresolvedOverloading] = nil
    # hash[D::Ruby::IncompatibleAssignment] = :information
    # hash[D::Ruby::ArgumentTypeMismatch] = :information
  end

  # repo_path '.rbs_collection'
end

target :test do
  signature 'sig'

  check 'spec'

  # Include the same libraries as lib
  library 'pathname'
  library 'logger'
  library 'mutex_m'
  library 'date'
  # library 'set'
  library 'timeout'

  # Skip RSpec library for now - complex type definitions
  # library 'rspec'

  # repo_path '.rbs_collection'
  repo_path 'vendor/sigs'
  configure_code_diagnostics(D::Ruby.lenient) # Very strict for tests
  # configure_code_diagnostics(D::Ruby.strict) # Very strict for tests
end

# target :examples do
#   signature 'sig'

#   check 'examples'

#   # Include the same libraries as lib
#   library 'pathname'
#   library 'logger'
#   library 'mutex_m'
#   library 'date'
#   # library 'set'
#   library 'timeout'

#   # Skip RSpec library for now - complex type definitions
#   # library 'rspec'

#   # repo_path '.rbs_collection'
#   repo_path 'vendor/sigs'
#   configure_code_diagnostics(D::Ruby.lenient) # Very strict for tests
#   # configure_code_diagnostics(D::Ruby.strict) # Very strict for tests
# end
