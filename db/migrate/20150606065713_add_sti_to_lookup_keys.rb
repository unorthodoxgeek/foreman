class AddStiToLookupKeys < ActiveRecord::Migration
  def self.up
    add_column :lookup_keys, :type, :string
    LookupKey.scoped.each do |key|
      if key.is_param
        key.type = 'PuppetclassLookupKey'
      else
        key.type = 'VariableLookupKey'
      end
      key.save!
    end
    add_index :lookup_keys, :type

    remove_foreign_key :environment_classes, :lookup_keys if foreign_key_exists?(:environment_classes, :lookup_keys)
    rename_column :environment_classes, :lookup_key_id, :puppetclass_lookup_key_id
    add_foreign_key :environment_classes, :lookup_keys, :column => :puppetclass_lookup_key_id
    remove_column :lookup_keys, :is_param
  end

  def self.down
    remove_column :lookup_keys, :type
  end
end