# frozen_string_literal: true

source 'https://rubygems.org'

gemspec

group :test do
  gem 'capture_stdout'
  gem 'mocha'
  gem 'rspec'
  gem 'travis-logger', git: 'https://github.com/travis-ci/travis-logger'
end

group :development, :test do
  gem 'rubocop'
  gem 'rubocop-performance'
  gem 'rubocop-rspec'
  gem 'simplecov'
  gem 'simplecov-console'
end
