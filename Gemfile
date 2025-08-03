# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

gemspec

group :development, :test do
  gem 'awesome_print'
  gem 'lefthook', require: false
  gem 'rake'
  gem 'rspec'
  gem 'rubocop'
  gem 'rubocop-performance'
  gem 'rubocop-rake'
  gem 'rubocop-rspec'
end

group :development do
  gem 'rbs' # Ruby's built-in signature support
  gem 'ruby-lsp'
  gem 'steep' # for static type checking
  gem 'typeprof'
end
