# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/) and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Added
- Fold constant for exponentiation if exponent is 0 and value is an integer.
- Replace `.reverse.each` usage with `.reverse_each`.
- Replace `foo ... in` loops with `.each do` loops.
- Replace `.gsub('...', '...')` with `.tr('...', '...')` if the arguments are strings and they are of length 1.
- Replace `def foo; @foo; end` with `attr_reader :foo`.
- Replace `.shuffle.first` with `.sample`.
- Replace `.map { ... }.flatten(1)` with `.flat_map { ... }`.

## [0.2.0] - 2019-04-18
### Added
- Hook into the `bootsnap` gem if it's loaded.

## [0.1.0] - 2019-03-08
### Added
- Initial release. 🎉

[Unreleased]: https://github.com/kddeisz/preval/compare/v0.2.0...HEAD
[0.2.0]: https://github.com/kddeisz/preval/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/kddeisz/preval/compare/49c899...v0.1.0
