# StrictTemplates

A gem for ensuring that database queries do not execute while rendering templates in a Rails application.

With great power comes great responsibility. ERB is an extremely flexible templating language, but can also . Gems like [`bullet`](https://github.com/flyerhzm/bullet) are great for detecting N+1 queries within an application. But for those of us that want to go the extra mile and **prevent any database access from within a template**, this gem is for you.

Doing this helps keep all database access centralized to your controller layer.

Pull Requests welcome to enable other methods of generating responses (RABL, etc.)

## Installation

Add this line to your application's Gemfile:

```ruby
group :development, :test do
  gem 'strict_templates'
end
```

And then do your normal:

    $ bundle
    
Next, include `StrictTemplates::Concern` in all controllers you wish to prevent database queries while rendering. If it's a new app, you should include it in your `ApplicationController`, e.g.

```ruby
class ApplicationController < ActionController::Base
  include StrictTemplates::Concern
end
```

## Usage

Errors will be raised whenever a request issues a SQL statement from within a template.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kellysutton/strict_templates. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

