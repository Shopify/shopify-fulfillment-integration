class EncryptTokens < ActiveRecord::Migration
  def self.up
    rename_column :shops, :token, :token_encrypted
  end

  def self.down
    rename_column :shops, :token_encrypted, :token
  end
end
