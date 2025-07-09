# Changelog

All notable changes to this project will be documented in this file.

## [0.7.0] - 2025-07-07
### Added
- Support for polymorphic scoped descriptions with `polymorphic_scoped: true` option
- Class-filtered getter methods (e.g. `Contact.job_positions_for(Person)`)
- `class_name` column to descriptions table for polymorphic filtering
- Automatic description type namespacing for polymorphic scopes

### Changed
- Simplified has_one setter definition in Customized concern

### Internal
- Added comprehensive test suite with 12 tests covering polymorphic scoped functionality
- Rails 8 compatibility
- First tracked version in changelog

