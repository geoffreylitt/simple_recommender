$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "simple_recommender/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "simple_recommender"
  s.version     = SimpleRecommender::VERSION
  s.authors     = ["Geoffrey Litt"]
  s.email       = ["gklitt@gmail.com"]
  s.homepage    = "https://github.com/geoffreylitt/simple_recommender"
  s.summary     = "A simple recommendation engine for Rails"
  s.description = "simple_recommender offers item-based similarity recommendations for a Rails app using Postgres, using your existing ActiveRecord associations"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", ">=4.0.0"
  s.add_dependency "pg"
end
