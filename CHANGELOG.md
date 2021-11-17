# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/) and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.6.1] - 2021-11-17

### Changed

- Require MFA for releasing.

## [0.6.0] - 2019-12-31

### Added

- Support for `nokw_param`, `args_forward`, and `in` nodes.

## [0.5.0] - 2019-06-13

### Added

- Replace `.sort.first` with `.min`.
- Replace `.sort.last` with `.max`.

## [0.4.1] - 2019-04-20

### Changed

- Support `attr_writer` transformations even if there is a void statement at the beginning of the method.

## [0.4.0] - 2019-04-19

### Added

- Replace `def foo=(value); @foo = value; end` with `attr_writer :foo`
- Replace `while false ... end` loops with nothing
- Replace `until false ... end` loops with `loop do ... end` loops
- Replace `until true ... end` loops with nothing

### Changed

- Extracted out the `Preval::Visitors::AttrAccessor` visitor.
- Renamed the `Preval::Visitors::Micro` visitor to `Preval::Visitors::Fasterer`.

## [0.3.0] - 2019-04-19

### Added

- Fold constant for exponentiation if exponent is 0 and value is an integer.
- Replace `.reverse.each` usage with `.reverse_each`.
- Replace `foo ... in` loops with `.each do` loops.
- Replace `.gsub('...', '...')` with `.tr('...', '...')` if the arguments are strings and they are of length 1.
- Replace `def foo; @foo; end` with `attr_reader :foo`.
- Replace `.shuffle.first` with `.sample`.
- Replace `.map { ... }.flatten(1)` with `.flat_map { ... }`.
- Replace `def foo=(value); @foo = value; end` with `attr_writer :foo`.

## [0.2.0] - 2019-04-18

### Added

- Hook into the `bootsnap` gem if it's loaded.

## [0.1.0] - 2019-03-08

### Added

- Initial release. 🎉

[unreleased]: https://github.com/kddnewton/preval/compare/v0.6.1...HEAD
[0.6.1]: https://github.com/kddnewton/preval/compare/v0.6.0...v0.6.1
[0.6.0]: https://github.com/kddnewton/preval/compare/v0.5.0...v0.6.0
[0.5.0]: https://github.com/kddnewton/preval/compare/v0.4.1...v0.5.0
[0.4.1]: https://github.com/kddnewton/preval/compare/v0.4.0...v0.4.1
[0.4.0]: https://github.com/kddnewton/preval/compare/v0.3.0...v0.4.0
[0.3.0]: https://github.com/kddnewton/preval/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/kddnewton/preval/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/kddnewton/preval/compare/49c899...v0.1.0
