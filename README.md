# Stored Session

[![Gem Version](https://badge.fury.io/rb/stored_session.svg)](https://badge.fury.io/rb/stored_session) [![Required Ruby Version](https://img.shields.io/badge/ruby-%3E%3D%203.2-ruby.svg)](https://www.ruby-lang.org/en/downloads/) [![Required Rails Version](https://img.shields.io/badge/rails-%3E%3D%208.0.0-brightgreen.svg)](https://edgeguides.rubyonrails.org/) [![CI](https://github.com/tbhb/stored_session/actions/workflows/ci.yml/badge.svg)](https://github.com/tbhb/stored_session/actions/workflows/ci.yml) [![Maintainability](https://api.codeclimate.com/v1/badges/39f9e3a36cd4d761c00e/maintainability)](https://codeclimate.com/github/tbhb/stored_session/maintainability) [![codecov](https://codecov.io/gh/tbhb/stored_session/graph/badge.svg?token=VEX3DN2RNF)](https://codecov.io/gh/tbhb/stored_session) [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Encrypted, database-backed [session store](https://guides.rubyonrails.org/security.html#session-storage) for [Rails](https://rubyonrails.org). It is a modernization of the [activerecord-session_store](https://github.com/rails/activerecord-session_store) gem that was previously extracted from Rails. Stored Session is encrypted by default and is tested with MySQL, PostgreSQL, and SQLite against Rails 8+.

## Features

- Compact serialization with [MessagePack](https://msgpack.org/) and encrypted storage with [Active Record encryption](https://guides.rubyonrails.org/active_record_encryption.html) (inspired by [Solid Cache](https://github.com/rails/solid_cache))
- Built-in job for expiring inactive sessions
- Tested with MySQL, PostgreSQL, and SQLite
- Instrumentation with [ActiveSupport::Notifications](https://guides.rubyonrails.org/active_support_instrumentation.html)

## Should I use this?

**Probably not.**

The original `active_record_store` was [extracted from Rails 4 in 2012](https://github.com/rails/rails/commit/0ffe19056c8e8b2f9ae9d487b896cad2ce9387ad) and moved to its own gem.

Rails 4 also began encrypting and signing cookies by default, including the session cookie. Prior to Rails 4, `active_record_store` was recommended when sensitive data needed to be stored in the session. Today, the secure defaults in Rails remove the need to store the session server-side for that reason.

Additionally, database-backed sessions put an increasing amount of strain on the database as traffic grows due to the sessions table being constantly operated against.

I built Stored Session primarily as an exercise in creating an "omakase" Rails engine to learn the framework's common patterns for things like engine configuration, instrumentation, and testing against multiple databases. Before using this gem in production, please make sure you really have a need for database-backed session storage!

### When might you actually need this?

You might consider using database-backed sessions if you:

- Have regulatory requirements mandating server-side session storage
- Need to store session data larger than the 4KB cookie limit
- Require detailed analytics or audit trails for every session

If none of these apply to your application, you're likely better off using Rails' default cookie-based session store.

## Prerequisites

- Ruby >= 3.2.0
- Rails >= 8.0.0

## Installation

Add Stored Session to your application by following these steps:

1. `bundle add stored_session`
2. `bin/rails stored_session:install:migrations`
3. `bin/rails db:migrate`

[ActiveRecord encryption](https://guides.rubyonrails.org/active_record_encryption.html) must be enabled in order to use Stored Session. Follow the instructions in [the guide](https://guides.rubyonrails.org/active_record_encryption.html#setup) to configure.

Then, set your session store in `config/initializers/session_store.rb`:

```ruby
Rails.application.config.session_store :stored_session_store, key: '_my_app_session`
```

When [Solid Queue](https://github.com/rails/solid_queue) is used as your ActiveJob queue adapter, add `StoredSession::ExpireSessionsJob` to `config/recurring.yml`:

```ruby
production:
  expire_sessions:
    class: "StoredSession::ExpireSessionsJob"
    schedule: every day
```

## Instrumentation

Stored Session instruments session store operations with `ActiveSupport::Notifications`:

### `session_read.stored_session`

| Key    | Value                 |
| ------ | --------------------- |
| `:sid` | The hashed session ID |

```ruby
{
  sid: '2::350cabf53a661de4fcf3d0ba6c6c65fd560b41e9697cf000168a9f420fb5366a'
}
```

### `session_write.stored_session`

| Key    | Value                 |
| ------ | --------------------- |
| `:sid` | The hashed session ID |

```ruby
{
  sid: '2::350cabf53a661de4fcf3d0ba6c6c65fd560b41e9697cf000168a9f420fb5366a'
}
```

### `session_delete.stored_session`

| Key    | Value                 |
| ------ | --------------------- |
| `:sid` | The hashed session ID |

```ruby
{
  sid: '2::350cabf53a661de4fcf3d0ba6c6c65fd560b41e9697cf000168a9f420fb5366a'
}
```

## Acknowledgements

This gem builds upon the excellent work of many contributors in the Ruby on Rails ecosystem. Special thanks to:

- The Rails core team and contributors, whose test suites and session store implementations in Rails itself core provided a robust foundation.
- The maintainers and contributors of the original [activerecord-session_store](https://github.com/rails/activerecord-session_store) gem, whose longstanding work influenced this implementation.
- The [Solid Cache](https://github.com/rails/solid_cache) and [Solid Queue](https://github.com/rails/solid_queue) maintainers and contributors, particularly for their modern database interaction patterns.

Portions of the gem boilerplate, implementation, and test suite and gem infrastructure were adapted from these projects, each of which are also distributed under the MIT License.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
