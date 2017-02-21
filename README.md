# simple_recommender

🔍 A quick and easy way to get "Users who liked X also liked Y" recommendations
for related items in your Rails/Postgres application.

```ruby
book = Book.find_by(name: "Harry Potter")

# Find the books most similar to Harry Potter, based on users' likes
book.similar_items
# => [#<Book id: 1840, name: "Twilight">,
      #<Book id: 1231, name: "Redwall">,
      #<Book id: 1455, name: "Lord of the Rings">...]
```

**Why should I used this gem?**

Unlike similar gems like [predictor](https://github.com/Pathgather/predictor) and [recommendable](https://github.com/davidcelis/recommendable) that require you to track relationships between entities in Redis, simple_recommender uses the associations you already have in your Postgres database.

This means you don't have to maintain a separate copy of your data, and also don't incur the operational complexity of needing to use Redis. Hooray for simplicity!

**But is it fast enough?**

simple_recommender uses fast integer array operations built into Postgres,
so it's fast enough to return realtime recommendations for many applications.

As a rough guideline based on benchmarking with a Heroku Standard 0 database:
if you have under 100,000 records in your join table (e.g., less than 100,000
Likes in the above example), then simple_recommender can return queries within
a couple hundred milliseconds.

If you're not sure if this is fast enough for your use case, I would recommend
trying it out on your data; it's just a couple lines of code to get started.

If you know that you have way more data than that, I would recommend looking into
one of the Redis-based gems that allow for offline precomputation. I'm also
considering adding offline precomputation to this gem to allow for higher scale.

## Getting started

### Prerequisites

This gem requires:

* Rails 4+
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

* offline precomputation of recommendations for higher-volume datasets
* similarity based on multiple associations combined with weights
* "user-item" recommendation: recommend things to a user based on all of their items
* recommendations based on numerical ratings rather than like/dislike
* recommendations based on a weighted mix of various associations
* MySQL support

