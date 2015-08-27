class MoveParamsToLookupValues < ActiveRecord::Migration
  def up
    Parameter.find_in_batches(:batch_size => 1000) do |batch|
      batch.each do |param|
        if params.is_a?(CommonParameter)
          migrate_common_parameter(param)
        else
          migrate_parameter(param)
        end
      end
    end
  end

  def down
  end

  def migrate_parameter(param)
    lookup_key = create_lookup_key(param, "")
    lookup_value = lookup_key.lookup_values.where(:match => param.lookup_value_matcher).first
    if lookup_value.present?
      if lookup_value.value != param.value
        #something's odd here, handle
      end
    else
      lookup_key.lookup_values.create(:match => param.lookup_value_matcher, :value => param.value)
    end
  end

  def migrate_common_parameter(param)
    create_lookup_key(param, param.default_value)
  end

  def create_lookup_key(param, default_value)
    lookup_key = LookupKey.where(:key => param.name).first
    if lookup_key.present?
      lookup_key.default_value = default_value
    else
      lookup_key = LookupKey.new(:key => param.name, :default_value => default_value)
    end
    lookup_key.save
    lookup_key
  end
end
