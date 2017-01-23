require 'test_helper'

class BookTest < ActiveSupport::TestCase
  describe BookTest do

    it "loads book fixtures" do
      assert_equal 9, Book.count
    end

    it "defines similar_by method" do
      assert_equal true, Book.first.respond_to?(:similar_by)
    end

    it "defines a similar_by_ method for each association" do
      assert_equal true, Book.first.respond_to?(:similar_by_users)
    end

    let(:python_book) { Book.find_by(name: "Learning Python") }
    let(:ruby_book) { Book.find_by(name: "Learning Ruby") }
    let(:cpp_book) { Book.find_by(name: "Learning C++") }

    describe "#similar_by" do
      let(:n_results) { 2 }
      subject { python_book.similar_by_users(n_results: n_results) }

      it "returns similar books" do
        assert_equal [ruby_book, cpp_book], subject
      end

      it "returns similarity scores" do
        expected_similarities = [1.0, (1.0/3)]

        expected_similarities.zip(subject.map(&:similarity)).each do |expected, actual|
          assert_in_delta expected, actual, 0.01
        end
      end

      describe "when there are zero-similarity elements" do
        let(:n_results) { 4 }

        it "returns similarity scores" do
          expected_similarities = [1.0, (1.0/3), 0, 0]

          expected_similarities.zip(subject.map(&:similarity)).each do |expected, actual|
            assert_in_delta expected, actual, 0.01
          end
        end
      end
    end
  end
end
