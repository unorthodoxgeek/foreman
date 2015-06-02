class AddHiddenFlagToLookupValues < ActiveRecord::Migration
  def change
    add_column :lookup_values, :hidden, :boolean, :default => false
  end
end
