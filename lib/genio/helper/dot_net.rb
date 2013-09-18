module Genio
  module Helper
    module DotNet

      include Base

      #Key/Reserved Words
      KeyWords = [
        "abstract",
        "as",
        "base",
        "bool",
        "break",
        "byte",
        "case",
        "catch",
        "char",
        "checked",
        "class",
        "const",
        "continue",
        "decimal",
        "default",
        "delegate",
        "do",
        "double",
        "else",
        "enum",
        "event",
        "explicit",
        "extern",
        "false",
        "finally",
        "fixed",
        "float",
        "for",
        "foreach",
        "goto",
        "if",
        "implicit",
        "in",
        "int",
        "interface",
        "internal",
        "is",
        "lock",
        "long",
        "namespace",
        "new",
        "null",
        "object",
        "operator",
        "out",
        "override",
        "params",
        "private",
        "protected",
        "public",
        "readonly",
        "ref",
        "return",
        "sbyte",
        "sealed",
        "short",
        "sizeof",
        "stackalloc",
        "static",
        "string",
        "struct",
        "switch",
        "this",
        "throw",
        "true",
        "try",
        "typeof",
        "uint",
        "ulong",
        "unchecked",
        "unsafe",
        "ushort",
        "using",
        "virtual",
        "void",
        "volatile",
        "while"
        ]

      # Keyword substitute hash
      KeywordsSubstitute = {
        "readonly" => "readOnly"
      }

      # Static resource imports
      # Resource class which have REST operation enabled
      # depend on these core classes
      ServiceImportREST = [
        "PayPal",
        "PayPal.Util",
        "System.Collections.Generic"
        ]

      # Static resource imports for WSDL
      # service class; they depend on these core classes
      ServiceImportWSDL = [
        "PayPal",
        "PayPal.Util",
        "System.Collections",
        "System.Collections.Generic",
        "System.Xml"
        ]

      # Static resource imports for WSDL
      # stub classes; they depend on these core classes
      StubImportWSDL = [
        "PayPal.Util",
        "System.Globalization",
        "System.Text",
        "System.Xml",
        ]

      # Spec Types to Dotnet Types conversion map
      BasicTypes = { "int" => "int", "integer" => "int", "positiveInteger" => "int", "nonNegativeInteger" => "int", "long" => "long", "double" => "double", "decimal" => "double", "float" => "float", "boolean" => "bool", "string" => "string", "dateTime" => "string", "date" => "string", "number" => "double", "object" => "object", "token" => "string", "duration" => "string", "anyURI" => "string", "date_time" => "string", "base64Binary" => "string", "time" => "string" }

      # Returns the type of a member
      # If the passed in parameter is one of Basic types
      # return the corresponding BasicType, else
      # the parameter is returned unmodified
      def find_basic_type(key)
        only_basic_type(key) || key
      end

      # Returns the corresponding basic
      # data type in Dotnet
      def only_basic_type(key)
        BasicTypes[key.camelcase(:lower)]
      end

      # Determines if a type of a property is nullable
      # Enum types are treated nullable
      def is_nullable_type(property)
        if ['int', 'long', 'double', 'float', 'bool'].include? find_basic_type(property.type)
          return true
        elsif schema.enum_types[property.type]
          return true
        else
          false
        end
      end

      # Returns the property type name to be used as the
      # type name in enclosing Class
      def get_property_class(property, classname = nil)
        type = find_basic_type(property.type)

        # If type is Self (as per Spec) treat is as HostType
        # classname is always in camelcase
        type = classname if type == "self"
        type = "List<#{type}>" if property.array
        type
      end

      # Returns the imports for the Class
      def imports(data_type, schema, package, classname, schema_format, operation_input = false)
        pkg = options[:namespace]
        pkg = capitalize_package(remove_tld_in_package(convert_ns_to_package(pkg))) if pkg.present?

        # mandatory references
        list = ["System"]

        if (schema_format == "rest")
          list.push("Newtonsoft.Json")
          list.push("Newtonsoft.Json.Serialization")
        end

        list.push("PayPal")
        data_type.properties.each do |name, property|
          type = schema.data_types[property.type] || schema.enum_types[property.type]
          if (type)
            if (pkg.present?)
              list.push(pkg)
            else
              # TODO fix this when definition namespace fixes
              defpkg = capitalize_package(remove_tld_in_package(convert_ns_to_package(type.package || package)))
              list.push(defpkg)
            end
          end
          list.push("System.Collections") if property.array
          list.push("System.Collections.Generic") if property.array
        end

        # Add references for members of parent datatype
        # flatten classes for wsdl
        if schema.instance_of? Genio::Parser::Format::Wsdl
          x_type = schema.data_types[data_type.extends]
          while x_type
            x_type.properties.each do |name, property|
              type = schema.data_types[property.type] || schema.enum_types[property.type]
              if (type)
                if (pkg.present?)
                  list.push(pkg)
                else
                  # TODO fix this when definition namespace fixes
                  defpkg = capitalize_package(remove_tld_in_package(convert_ns_to_package(type.package || package)))
                  list.push(defpkg)
                end
              end
              list.push("System.Collections") if property.array
              list.push("System.Collections.Generic") if property.array
            end
            x_type = schema.data_types[x_type.extends]
          end
        end

        # Add reference for request and response type
        # of operations: Applies to REST services
        service = schema.services[classname]
        if service
          service.operations.each do |name, operation|
            if operation.response
              if (pkg.present?)
                list.push(pkg)
              else
                list.push(capitalize_package(remove_tld_in_package(convert_ns_to_package(schema.data_types[operation.response].try(:package) || package))))
              end
            end
            if operation.request
              if (pkg.present?)
                list.push(pkg)
              else
                list.push(capitalize_package(remove_tld_in_package(convert_ns_to_package(schema.data_types[operation.request].try(:package) || package))))
              end
            end
          end
        end

        list += ServiceImportREST if schema.services[classname]
        list += StubImportWSDL if (schema_format == "soap")
        #TODO fix for XMLSerialization
        list += [] if (operation_input && (schema_format == "soap"))
        list.uniq.sort
      end

      # Generate imports for WSDL Service class
      def service_imports(schema, service, package)
        pkg = options[:namespace]
        pkg = capitalize_package(remove_tld_in_package(convert_ns_to_package(pkg))) if pkg.present?

        # mandatory references
        list = ["System"]

        # import request and response of operations
        service.operations.each do |name, definition|
          if (definition.request_property)
            if (pkg.present?)
              list.push(pkg)
            else
              list.push(capitalize_package(remove_tld_in_package(convert_ns_to_package(schema.data_types[validate_class_name(definition.request_property.type)].package || package))))
            end
          end
          if (definition.response_property)
            if (pkg.present?)
              list.push(pkg)
            else
              list.push(capitalize_package(remove_tld_in_package(convert_ns_to_package(schema.data_types[validate_class_name(definition.response_property.type)].package || package))))
            end
          end
          if (definition.fault_property)
            if (pkg.present?)
              list.push(pkg)
            else
              list.push(capitalize_package(remove_tld_in_package(convert_ns_to_package(schema.data_types[validate_class_name(definition.fault_property.type)].package || package))))
            end
          end
        end

        # mandatory imports
        list += ServiceImportWSDL
        list.uniq.sort
      end

      # Replaces any "-" present in the path URI to valid "_"
      # used while replacing placeholders with exact values
      def validate_path(path)
        path.gsub(/\{([^}]*)\}/){|match| "\{#{validate_property_name($1)}\}" }
      end

      # Replaces '-' with '_' and CamelCase(s) them [DotNet]
      def validate_class_name(name)
        only_basic_type(name) || name.gsub(/-/, "_").camelcase
      end

      # Replaces '-' with '_',
      # used for valid property names [DotNet]
      # replaces keywords with substitutes form KeywordsSubstitute
      def validate_property_name(name, camel = false)
        if camel
          valid_name = name.gsub(/-/, "_").camelcase
        else
          valid_name = name.gsub(/-/, "_")
        end
        if KeyWords.include? valid_name
          valid_name = KeywordsSubstitute[valid_name]
        end
        valid_name
      end

      # Replaces '-' and spaces with '_'
      # used for valid enum names [DotNet]
      def validate_enum_name(name)
        name.gsub(/[-\s]/, "_").sub(/^\d/, '_\0')
      end

      # Replaces '-' with '_' and camelCase(s) them
      # used for valid property names as method/constructor
      # arguments [DotNet]
      def validate_property_as_argument(name)
        name.gsub(/-/, "_").camelcase(:lower)
      end

      # Prepends do to method names that are keywords
      def validate_method_name(name)
        KeyWords.include?(name.camelcase(:lower)) ? "Do#{name.gsub(/-/, '_').camelcase}" : name.gsub(/-/, '_').camelcase
      end

      # Generate method formal parameters for REST API calls
      def form_rest_api_args(classname, property, name)
        arguments = {}
        property.path.scan(/{([^}]*)}/).each do |name, etc|
        if is_static_method(property) or validate_class_name(name) !~ /^#{classname}/i
          arguments[validate_property_as_argument(name)] = "string"
          end
        end
        if property.request and property.request != classname
          arguments[validate_property_as_argument(property.request)] = property.request
        end
        if property.type == 'GET' or property.type == 'HEAD' or property.type == 'DELETE'
          arguments["queryParameters"] = "Dictionary<string, string>"
        end
        arguments
      end

      # Generates a map of parameters for placeholders used
      # to process path URI
      def generate_format_hash(classname, property, resourcePath)
        map = {}
        resourcePath.scan(/\{([^}]*)\}/) { |name, etc|
          if (name.gsub(/-/, "").gsub(/_/, "").match(/^#{classname}.*/i) and !is_static_method(property))
           map[name] = 'this.id'
          else
           map[name] = validate_property_as_argument(name)
          end
        }
        map
      end

      # Returns the expression to set for payLoad in the API call
      def get_payload(classname, property)
        payLoad = '""';
        if !is_static_method(property)
          if property.request == classname
            payLoad = "this.ConvertToJson()"
          elsif property.request
            payLoad = validate_property_as_argument(property.request) + ".ConvertToJson()"
          end
        end
        payLoad
      end

      # Returns the name used during serialization for types
      # that extend Serializer interface
      def get_rootname_serialization(data_type, schema)
        schema.services.each do |service_name, servicedef|
          servicedef.operations.each do |operation_name, oper_definition|
            if (data_type.name == oper_definition.request)
              return (oper_definition.request_property.package + ":" + oper_definition.request_property.name)
            elsif (data_type.name == oper_definition.header)
              return (oper_definition.header_property.package + ":" + oper_definition.header_property.name)
            end
          end
        end
      end

      # Returns a hash of arguments for wsdl operations
      # including the request type and name
      # hash is in the format of [name] = [type]
      def get_wsdl_operation_arguments(operation_definition)
        argument_hash = {}
          argument_hash[validate_property_as_argument(operation_definition.request_property.name)] = operation_definition.request
        argument_hash
      end

    end
  end
end
