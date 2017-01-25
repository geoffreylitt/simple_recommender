class AddAuthorToBooks < ActiveRecord::Migration
  def change
    add_reference :books, :author, index: true
  end
end
