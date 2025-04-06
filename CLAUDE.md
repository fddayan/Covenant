# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands
- Build/Test: `bundle exec rake` (runs tests and linting)
- Run tests: `bundle exec rspec`
- Run single test: `bundle exec rspec path/to/spec_file.rb:line_number`
- Lint: `bundle exec rubocop -a` (auto-corrects when possible)
- Run examples: `task examples` (runs all Ruby examples)

## Code Style Guidelines
- Ruby 3.0+ with frozen_string_literal comments
- Line length: 80 characters max
- Indentation: 2 spaces
- Quotes: Single quotes preferred
- Method length: Max 15 lines
- Class length: Max 100 lines
- Parameter count: Max 4 parameters
- Use Zeitwerk for autoloading
- Error handling: Use guard clauses and appropriate error classes
- Testing: Use RSpec expect syntax (not should)
- Naming: Follow Ruby conventions (snake_case for methods/variables)
- Documentation: Not strictly required but encouraged for public API