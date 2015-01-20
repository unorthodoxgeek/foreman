class ActiveRecord::Base
  extend Host::Hostmix
  include HasManyCommon
  include StripWhitespace
  include Parameterizable::ById
end

module ActiveRecord
  # = Active Record \Named \Scopes
  module Scoping
    module Named

      module ClassMethods
        def all(*args)
          if current_scope
            current_scope.clone
          else
            default_scoped
          end
        end
      end
    end
  end
end


#this fixes annoying issue with custom counter cache column names
module ActiveRecord::Associations::Builder
  class BelongsTo

    def add_counter_cache_callbacks(reflection)
      cache_column = reflection.counter_cache_column
      foreign_key = reflection.foreign_key
      klass = reflection.class_name.safe_constantize

      mixin.class_eval <<-CODE, __FILE__, __LINE__ + 1
        def belongs_to_counter_cache_after_create_for_#{name}
          if record = #{name}
            record.class.increment_counter(:#{cache_column}, record.id)
            @_after_create_counter_called = true
          end
        end
        def belongs_to_counter_cache_before_destroy_for_#{name}
          unless destroyed_by_association && destroyed_by_association.foreign_key.to_sym == #{foreign_key.to_sym.inspect}
            record = #{name}
            if record && !self.destroyed?
              record.class.decrement_counter(:#{cache_column}, record.id)
            end
          end
        end
        def belongs_to_counter_cache_after_update_for_#{name}
          if (@_after_create_counter_called ||= false)
            @_after_create_counter_called = false
          elsif self.#{foreign_key}_changed? && !new_record? && #{constructable?}
            model = #{klass}
            foreign_key_was = self.#{foreign_key}_was
            foreign_key = self.#{foreign_key}
            if foreign_key && model.respond_to?(:increment_counter)
              model.increment_counter(:#{cache_column}, foreign_key)
            end
            if foreign_key_was && model.respond_to?(:decrement_counter)
              model.decrement_counter(:#{cache_column}, foreign_key_was)
            end
          end
        end
      CODE

      model.after_create   "belongs_to_counter_cache_after_create_for_#{name}"
      model.before_destroy "belongs_to_counter_cache_before_destroy_for_#{name}"
      # TODO: disabled to work around issue #10865, have proposed a better solution to rails-core
      # model.after_update   "belongs_to_counter_cache_after_update_for_#{name}"
      klass.attr_readonly cache_column if klass && klass.respond_to?(:attr_readonly)
    end
  end
end