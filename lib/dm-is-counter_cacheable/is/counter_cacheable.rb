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
        # @return [DataMapper::Property]
        #   The newly added counter cache property.
        #
        def counter_cacheable(relationship_name,options={})
          @counter_cache ||= {}

          unless self.relationships.has_key?(relationship_name)
            raise(RuntimeError,"unknown relationship #{relationship_name} in #{self}",caller)
          end

          if options.has_key?(:counter_property)
            counter_property = options[:counter_property]
          else
            model_name = self.name.split('::').last
            counter_property = (DataMapper::NamingConventions::Resource::UnderscoredAndPluralized.call(model_name) + '_counter').to_sym
          end

          relationship = self.relationships[relationship_name]
          parent_model = case relationship
                         when DataMapper::Associations::ManyToOne::Relationship,
                              DataMapper::Associations::OneToOne::Relationship
                           relationship.parent_model
                         end

          parent_model.property counter_property, Integer, :default => 0, :min => 0

          @counter_cache[relationship_name] = counter_property
        end

        #
        # Creates a resource and increments the cache counters of the model.
        #
        # @return [DataMapper::Resource]
        #   The new resource.
        #
        def create(*arguments)
          resource = super(*arguments)

          if self.counter_cache
            self.counter_cache.each do |relationship,property|
              parent_resource = resource.send(relationship)

              count = parent_resource.attribute_get(property)
              parent_resource.attribute_set(property,count + 1)
              parent_resource.save
            end
          end

          resource
        end
      end

      module InstanceMethods
        #
        # Destroys a resource and decrements the cache counters of the model.
        #
        # @return [Boolean]
        #   Specifies whether the resource was successfully destroyed.
        #
        def destroy(*arguments)
          if self.class.counter_cache
            self.class.counter_cache.each do |relationship,property|
              parent_resource = self.send(relationship)

              count = parent_resource.attribute_get(property)
              parent_resource.attribute_set(property,count - 1)
              parent_resource.save
            end
          end

          super(*arguments)
        end
      end
    end
  end
end
