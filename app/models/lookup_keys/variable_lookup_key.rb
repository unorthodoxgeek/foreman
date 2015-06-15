class VariableLookupKey < LookupKey
  belongs_to :puppetclass, :inverse_of => :lookup_keys, :counter_cache => :variable_lookup_keys_count

  validates :puppetclass, :presence => true

  def audit_class
    puppetclass
  end

  def param_class
  end

  scope :global_parameters_for_class, lambda {|puppetclass_ids|
                                        where(:puppetclass_id => puppetclass_ids)
                                      }

  scope :smart_variables, lambda { where('lookup_keys.puppetclass_id > 0').readonly(false) }
end
