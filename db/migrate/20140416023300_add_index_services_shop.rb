class AddIndexServicesShop < ActiveRecord::Migration
  def self.up
    add_index :fulfillment_services, :shop_id
  end

  def self.down
    remove_index :fulfillment_services, :shop_id
  end
end
