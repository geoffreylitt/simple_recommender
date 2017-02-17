require 'test_helper'

class BookTest < ActiveSupport::TestCase
  describe BookTest do

    let(:python_book) { Book.find_by(name: "Learning Python") }
    let(:ruby_book) { Book.find_by(name: "Learning Ruby") }
    let(:cpp_book) { Book.find_by(name: "Learning C++") }
    let(:violin_book) { Book.find_by(name: "Playing Violin") }

    describe "#similar_items" do
      let(:n_results) { 3 }
      subject { python_book.similar_items(n_results: n_results) }

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
