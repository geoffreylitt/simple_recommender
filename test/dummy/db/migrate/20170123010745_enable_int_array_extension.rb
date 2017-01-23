class EnableIntArrayExtension < ActiveRecord::Migration
  def change
    enable_extension "intarray"
  end
end
