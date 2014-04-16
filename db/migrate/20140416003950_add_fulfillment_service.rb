class AddFulfillmentService < ActiveRecord::Migration
  def self.up
    create_table :fulfillment_services do |t|
      t.integer :shop_id
      t.string :username_encrypted
      t.string :password_encrypted
    end
  end

  def self.down
    drop_table :fulfillment_services
  end

end
