# simple-recommender

A quick and easy way to get "Users who liked X also liked Y" recommendations
in your Rails application.

```ruby
# Find the top 3 similar books, based on users who liked Harry Potter
book.similar_by_users(n_results: 3)
# => [#<Book id: 1840, name: "Twilight">,
      #<Book id: 1231, name: "Redwall">,
      #<Book id: 1455, name: "Lord of the Rings">]
```

Unlike [similar](https://github.com/Pathgather/predictor) [gems](https://github.com/davidcelis/recommendable) that require you tracking relationships between entities in Redis, simple-recommender uses the associations you already have in your Postgres database, making it easier to get started.

The performance is probably adequate for early-stage apps with a small amount
of data that just want to get started with basic recommendations, but YMMV.

**This gem is currently in early development and not ready for production use, or really any use at all.**

## Installation

Add to your `Gemfile`:

`gem 'simple-recommender'`

Run `bundle install` and restart any running servers.

## Usage

You can now add `include SimpleRecommender::Recommendable` to any ActiveRecord model with a `has_and_belongs_to_many` association.

```ruby
class Book < ActiveRecord::Base
  has_and_belongs_to_many :users

  include SimpleRecommender::Recommendable
end
```

Then you can call `similar_by_users` on any instance:

```ruby
book = Book.find_by(name: "Harry Potter")
# => #<Book id: 1115, name: "Harry Potter">

# Find the top 3 similar books, based on users who liked Harry Potter
book.similar_by_users(n_results: 3)
# => [#<Book id: 1840, name: "Twilight">,
      #<Book id: 1231, name: "Redwall">,
      #<Book id: 1455, name: "Lord of the Rings">]

```

## Roadmap

This gem is still very young. Some changes I'm considering:

* Rails 5 support
* "user-item" recommendation: recommend things to a user based on all their items
* recommendations based on numerical ratings rather than like/dislike
* recommendations based on a weighted mix of various associations
* offline precomputation of recommendations for higher-volume datasets
* MySQL support

