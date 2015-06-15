class PuppetclassLookupKey < LookupKey

  has_many :environment_classes, :dependent => :destroy
  has_many :environments, :through => :environment_classes, :uniq => true
  has_many :param_classes, :through => :environment_classes, :source => :puppetclass
  def param_class
    param_classes.first
  end

  def audit_class
    param_class
  end

  scoped_search :in => :param_classes, :on => :name, :rename => :puppetclass, :complete_value => true

  scope :smart_class_parameters_for_class, lambda {|puppetclass_ids, environment_id|
                                           joins(:environment_classes).where(:environment_classes => {:puppetclass_id => puppetclass_ids, :environment_id => environment_id})
                                         }

  scope :parameters_for_class, lambda {|puppetclass_ids, environment_id|
                               override.smart_class_parameters_for_class(puppetclass_ids,environment_id)
                             }

  scope :smart_class_parameters, lambda { where(:is_param => true).joins(:environment_classes).readonly(false) }

  # def is_smart_class_parameter?
  #   is_param? && environment_classes.any?
  # end

  def validate_and_cast_default_value
    super unless use_puppet_default
    true
  end
end
