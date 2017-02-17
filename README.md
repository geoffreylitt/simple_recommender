# simple_recommender

A quick and easy way to get "Users who liked X also liked Y" recommendations
in your Rails/Postgres application.

```ruby
book = Book.find_by(name: "Harry Potter")

# Find the books most similar to Harry Potter, based on who liked them
book.similar_items
# => [#<Book id: 1840, name: "Twilight">,
      #<Book id: 1231, name: "Redwall">,
      #<Book id: 1455, name: "Lord of the Rings">...]
```

**What makes this gem unique?**

Unlike similar gems like [predictor](https://github.com/Pathgather/predictor) and [recommendable](https://github.com/davidcelis/recommendable) that require you to track relationships between entities in Redis, simple_recommender uses the associations you already have in your Postgres database, making it easier to get started.

It's also very simple ([under 100 LOC](https://github.com/geoffreylitt/simple_recommender/blob/master/lib/simple_recommender/recommendable.rb)) so you can easily understand what's going on.

**Is it performant?**

This gem uses fast integer array operations built into Postgres, so the performance is adequate for apps with a small amount of data. For larger amounts of data, YMMV.

In the future I may add an offline pre-computation step to support larger datasets.

**Can I use it in production?**

This gem is currently in early development and not intended for production use. Use at your own risk.

## Getting started

### Prerequisites

This gem requires:

* Rails 4.x
* PostgreSQL ([setup guide](https://www.digitalocean.com/community/tutorials/how-to-setup-ruby-on-rails-with-postgres))

### Installation

##### Install the gem

* Add the gem to your Gemfile: `gem 'simple_recommender'`

* Run `bundle install`

##### Enable `intarray`

Next you'll need to enable the `intarray` extension in your Postgres database, which is used to compute recommendations.

* Run `rails g migration EnableIntArrayExtension`

* Replace the contents of the newly created migration file with the code below

```
class EnableIntArrayExtension < ActiveRecord::Migration
  def change
    enable_extension "intarray"
  end
end
```

* Run `rake db:migrate`

Now you should have everything you need to get started!

## Usage

You can add `include SimpleRecommender::Recommendable` to any ActiveRecord model,
and then define an association to use for similarity matching.

For example, let's say you have Books in your app. Books are associated with Users through Likes. We want to say that two books are similar if they are liked by many of the same users.

It's as easy as adding two lines to your model:

```ruby
class Book < ActiveRecord::Base
  has_many :likes
  has_many :users, through: :likes

  include SimpleRecommender::Recommendable
  similar_by :users
end

```

Now you can call `similar_items` to find similar books based on who liked them!

```ruby
book.similar_items(n_results: 3)
# => [#<Book id: 1840, name: "Twilight">,
      #<Book id: 1231, name: "Redwall">,
      #<Book id: 1455, name: "Lord of the Rings">]
```

The items are returned in descending order of similarity. Each item also has
a `similarity` method you can call to find out how similar the items were.
1.0 means the two items share exactly the same associations, and 0.0 means that
there is no overlap at all.

```ruby
book.similar_items(n_results: 3).map(&:similarity)
# => [0.5, 0.421, 0.334]
```

You can also decide how many results to return with the `n_results` parameter.

## Roadmap

This gem is still in early development. Some changes I'm considering:

* similarity based on multiple associations combined
* "user-item" recommendation: recommend things to a user based on all their items
* recommendations based on numerical ratings rather than like/dislike
* recommendations based on a weighted mix of various associations
* offline precomputation of recommendations for higher-volume datasets
* MySQL support
* Better Rails 5 support

