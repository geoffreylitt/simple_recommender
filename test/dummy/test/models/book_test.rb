require 'test_helper'

class BookTest < ActiveSupport::TestCase
  describe BookTest do

    describe "#similar_by" do
      let(:book) { Book.first }

      it "returns a result for a has_many through association" do
        assert book.similar_by(:users)
      end

      it "returns a result for a has_and_belongs_to_many association" do
        assert book.similar_by(:tags)
      end

      it "raises an ArgumentError for an invalid association type" do
        assert_raises ArgumentError do
          book.similar_by(:author)
        end
      end
    end

    describe "convenience methods" do
      it "defines a convenience method for a has_and_belongs_to_many association" do
        assert_equal true, Book.first.respond_to?(:similar_by_tags)
      end

      it "defines a convenience method for a has_many through association" do
        assert_equal true, Book.first.respond_to?(:similar_by_users)
      end

      it "does not define a convenience method for an invalid association type" do
        assert_equal false, Book.first.respond_to?(:similar_by_authors)
      end
    end

    let(:python_book) { Book.find_by(name: "Learning Python") }
    let(:ruby_book) { Book.find_by(name: "Learning Ruby") }
    let(:cpp_book) { Book.find_by(name: "Learning C++") }
    let(:violin_book) { Book.find_by(name: "Playing Violin") }

    describe "#similar_by_tags" do
      let(:n_results) { 3 }
      subject { python_book.similar_by_tags(n_results: n_results) }

      it "returns similar books" do
        assert_equal [ruby_book, cpp_book, violin_book], subject
      end

      it "returns similarity scores" do
        expected_similarities = [1.0, (2.0/3), (1.0/4)]

        expected_similarities.zip(subject.map(&:similarity)).each do |expected, actual|
          assert_in_delta expected, actual, 0.01
        end
      end
    end

    describe "#similar_by_users" do
      let(:n_results) { 3 }
      subject { python_book.similar_by_users(n_results: n_results) }

      it "returns similar books" do
        assert_equal [ruby_book, cpp_book, violin_book], subject
      end

      it "returns similarity scores" do
        expected_similarities = [1.0, (1.0/3), (1.0/3)]

        expected_similarities.zip(subject.map(&:similarity)).each do |expected, actual|
          assert_in_delta expected, actual, 0.01
        end
      end
    end
  end
end
