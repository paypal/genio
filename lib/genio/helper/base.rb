require 'active_support/all'

module Genio
  module Helper
    module Base

      # Checks for static modifier, currently all Get methods
      # are considered static
      def is_static_method(property)
        property.type == "GET"
      end

      # Returns true if this.getId() should be include in the
      # API calls - Applies to non-static methods which have a
      # path variable which is the host class
      # e.g /v1/users/{user} or /v1/users/{user-id}
      def check_host_id(classname, property)
        !is_static_method(property) && property.path.gsub(/-/, "").gsub(/_/, "") =~ /\{(#{classname}[^\}]*)\}/i
      end

      # Returns true if data_type is a input type used in
      # a service operation or header, false otherwise
      def is_operation_input(data_type, schema)
        schema.services.each do |service_name, servicedef|
          servicedef.operations.each do |operation_name, oper_definition|
            if (data_type.name == oper_definition.request || data_type.name == oper_definition.header)
              return true
            end
          end
        end
        return false
      end

      # Determine if type_name is a complex type
      # returns true if its complex, false otherwise
      def is_complex_type(type_name, schema)
        return true if schema.data_types[type_name]
        return false
      end

      # Determine if type_name is a enum type
      # returns true if its an enum, false otherwise
      def is_enum_type(type_name, schema)
        return true if schema.enum_types[type_name]
        return false
      end

      # Retruns true if the data_type has a attribute member
      def contains_attribute(data_type)
        data_type.properties.each do |name, definition|
          return true if definition.attribute
        end
        return false
      end

      # Determines if XML elements should be qualified
      # using prefix; reading elementformdefault attributes
      # from schemas
      def should_qualify_name(package, schema)
        return true if package.blank?
        namespace = schema.namespaces.find{|ns, prefix| prefix == package}
        namespace and schema.element_form_defaults[namespace.first] == "qualified"
      end

      # Word wraps comment
      def comment_wrap(text, line_width, prefix='')
        return prefix if ( (!text.kind_of? String) || (text.strip.length == 0) )
      text.gsub(/(.{1,#{line_width}})(\s+|$)/, prefix + "\\1\n").gsub(/\n$/, "")
      end

      # Returns list of all top-level input types
      # defined in this service
      def request_types(schema)
        @request_types || schema.services.values.map{|service| service.operations.values.map{|opt| opt.request } }.flatten
      end

      # Returns list of all header types
      # defined in this service
      def header_types(schema)
        @request_types || schema.services.values.map{|service| service.operations.values.map{|opt| opt.header } }.flatten
      end

    end
  end
end
