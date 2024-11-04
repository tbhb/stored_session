# Solid Session

Database-backed [session store](https://guides.rubyonrails.org/security.html#session-storage) for [Rails](https://rubyonrails.org).

## Prerequisites

- Ruby >= 3.2.0
- Rails >= 8.0.0.rc2

## Installation

Add Solid Session to your application by following these steps:

1. `bundle add solid_session`
2. `bin/rails solid_session:install:migrations`
3. `bin/rails db:migrate`

Then, set your session store in `config/initializers/session_store.rb`:

```ruby
Rails.application.config.session_store :solid_session_store, key: '_my_app_session`
```

When [Solid Queue](https://github.com/rails/solid_queue) is used as your ActiveJob queue adapter, add `SolidSession::TrimSessionsJob` to `config/recurring.yml`:

```ruby
production:
  trim_sessions:
    class: "SolidSession::TrimSessionsJob"
    schedule: every day
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
