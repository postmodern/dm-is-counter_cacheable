module DataMapper
  module Is
    module CounterCacheable
      #
      # Fired when your plugin gets included into a Resource.
      #
      def is_counter_cacheable
        extend DataMapper::Is::CounterCacheable::ClassMethods
        include DataMapper::Is::CounterCacheable::InstanceMethods
      end

      module ClassMethods
        attr_reader :counter_cache

        #
        # Adds a counter cache property to a related model.
        #
        # @param [Symbol] relationship_name
        #   The name of the related model.
        #
        # @param [Hash] options
        #   Additional options.
        #
        # @option options [Symbol] :counter_property
        #   The optional property name to store the counter cache in.
        #
        # @option options [Boolean] :counter_index
        #   Specifies to store the current count in newly created resources.
        #
        # @return [DataMapper::Property]
        #   The newly added counter cache property.
        #
        def counter_cacheable(relationship_name,options={})
          @counter_cache ||= []

          unless self.relationships.named?(relationship_name)
            raise(RuntimeError,"unknown relationship #{relationship_name} in #{self}",caller)
          end

          model_name = DataMapper::NamingConventions::Resource::UnderscoredAndPluralized.call(self.name.split('::').last)
          counter_property = if options.has_key?(:counter_property)
                               options[:counter_property]
                             else
                               :"#{model_name}_counter"
                             end

          relationship = self.relationships[relationship_name]
          parent_model = case relationship
                         when DataMapper::Associations::ManyToOne::Relationship,
                              DataMapper::Associations::OneToOne::Relationship
                           relationship.parent_model
                         end

          parent_model.property counter_property, Integer, :default => 0, :min => 0

          if options[:counter_index]
            counter_index = :"#{relationship_name}_#{model_name}_index"

            self.property counter_index, Integer, :min => 1
          else
            counter_index = nil
          end

          @counter_cache << {
            :relationship => relationship_name,
            :counter_property => counter_property,
            :counter_index => counter_index
          }
        end
      end

      module InstanceMethods
        private

        #
        # Creates a resource and increments the cache counters of the model.
        #
        # @return [DataMapper::Resource]
        #   The new resource.
        #
        def _save(*arguments)
          if (self.new? && self.class.counter_cache)
            self.class.counter_cache.each do |options|
              parent_resource = self.send(options[:relationship])

              count = parent_resource.attribute_get(options[:counter_property])
              count += 1

              parent_resource.attribute_set(options[:counter_property],count)

              if options[:counter_index]
                self.attribute_set(options[:counter_index],count)
              end
            end
          end

          super(*arguments)
        end

        #
        # Destroys a resource and decrements the cache counters of the model.
        #
        # @return [Boolean]
        #   Specifies whether the resource was successfully destroyed.
        #
        def _destroy(*arguments)
          if self.class.counter_cache
            self.class.counter_cache.each do |options|
              parent_resource = self.send(options[:relationship])

              count = parent_resource.attribute_get(options[:counter_property])
              parent_resource.attribute_set(options[:counter_property],count - 1)
            end
          end

          super(*arguments)
        end
      end
    end
  end
end
