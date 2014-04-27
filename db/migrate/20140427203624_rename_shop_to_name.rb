class RenameShopToName < ActiveRecord::Migration
  def self.up
    rename_column :shops, :shop, :name
  end

  def self.down
    rename_column :shops, :name, :shop
  end
end
