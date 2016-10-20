## [0.6.1]

### Fixed
- Correctly handle NaiveDateTimes with ms precision (thanks to [@radar](https://github.com/radar))

## [0.6.0]

### Changed
- Requires Elixir 1.3 or higher

### Fixed
- Removed timex dependency and using Elixir's built in datetime functions (thanks to [@radar](https://github.com/radar))

## [0.5.1]

### Fixed
- Use Timex.DateTime.now, rather than Timex.DateTime.today (thanks to [@radar](https://github.com/radar))

## [0.5.0]

### Fixed
- `x-amz-date` using Date instead of DateTime  (thanks to [@radar](https://github.com/radar))

### Changed
- Dependency updates (thanks to [@radar](https://github.com/radar))

## [0.4.0]

### Fixed
- Signing works for more than just S3 from @kenta-aktsk

### Changed
- headers params for `sign_url` and `sign_authorization_header` now expects a map instead of a Dict
