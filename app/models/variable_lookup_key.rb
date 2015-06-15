class VariableLookupKey < LookupKey

  belongs_to :puppetclass, :inverse_of => :lookup_keys, :counter_cache => true

  validates :puppetclass, :presence => true

  def audit_class
    puppetclass
  end

  scope :global_parameters_for_class, lambda {|puppetclass_ids|
                                      where(:puppetclass_id => puppetclass_ids)
                                    }

  scope :smart_variables, lambda { where('lookup_keys.puppetclass_id > 0').readonly(false) }

  # def is_smart_variable?
  #   puppetclass_id.to_i > 0
  # end
end
