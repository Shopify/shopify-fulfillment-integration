class AddIndexToShops < ActiveRecord::Migration
  def self.up
    add_index :shops, :shop
  end

  def self.down
    remove_index :shops, :shop
  end
end
