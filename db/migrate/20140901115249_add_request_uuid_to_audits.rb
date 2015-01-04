class AddRequestUuidToAudits < ActiveRecord::Migration
  def up
    add_column :audits, :request_uuid, :string
    add_index :audits, :request_uuid
  end

  def down
    remove_column :audits, :request_uuid
  end
end
