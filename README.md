# simple_recommender

A quick and easy way to get "Users who liked X also liked Y" recommendations
in your Rails/Postgres application.

```ruby
# Find the top 3 similar books, based on users who liked Harry Potter

book = Book.find_by(name: "Harry Potter")
# => #<Book id: 1115, name: "Harry Potter">

book.similar_by_users(n_results: 3)
# => [#<Book id: 1840, name: "Twilight">,
      #<Book id: 1231, name: "Redwall">,
      #<Book id: 1455, name: "Lord of the Rings">]
```

Unlike similar gems like [predictor](https://github.com/Pathgather/predictor) and [recommendable](https://github.com/davidcelis/recommendable) that require you to track relationships between entities in Redis, simple_recommender uses the associations you already have in your database, making it easier to get started.

There is currently no offline pre-computation of recommendations, and everything happens in real time. The performance is adequate for early-stage apps with a small amount of data that just want to have basic recommendations. For larger amounts of data, YMMV.

**This gem is currently in early development and not anywhere near ready for production use.**

## Getting started

### Prerequisites

This gem currently works with Rails 4, and requires you to be using Postgres
as your database (because it uses Postgres-specific functionality to efficiently
compute similarity).

### Installation

This gem isn't published on RubyGems yet, so add a git reference to your Gemfile:

`gem 'simple_recommender', github: 'geoffreylitt/simple_recommender'`

## Usage

You can now add `include SimpleRecommender::Recommendable` to any ActiveRecord model with a `has_and_belongs_to_many` association.

For example, let's say you have Books that are associated with Users:

```ruby
class Book < ActiveRecord::Base
  has_and_belongs_to_many :users

  include SimpleRecommender::Recommendable
end
```

Then you can call `similar_by_users` on any instance of a `Book`:

```ruby
book = Book.find_by(name: "Harry Potter")
# => #<Book id: 1115, name: "Harry Potter">

# Find the top 3 similar books, based on users who liked Harry Potter
similar_books = book.similar_by_users(n_results: 3)
# => [#<Book id: 1840, name: "Twilight">,
      #<Book id: 1231, name: "Redwall">,
      #<Book id: 1455, name: "Lord of the Rings">]
```

The items are sorted in descending order of similarity. Each item also has
a `similarity` value you can use to find out how similar the items were.
1.0 means the exact same users are associated with the items, and 0.0 means that
there is no overlap in associated users.

```ruby
similar_books.map(&:similarity)
# => [0.5, 0.421, 0.334]
```

## Roadmap

This gem is still very young. Some changes I'm considering:

* Rails 5 support
* "user-item" recommendation: recommend things to a user based on all their items
* recommendations based on numerical ratings rather than like/dislike
* recommendations based on a weighted mix of various associations
* offline precomputation of recommendations for higher-volume datasets
* MySQL support

