#
#   Copyright 2013 PayPal Inc.
# 
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
# 
#       http://www.apache.org/licenses/LICENSE-2.0
# 
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
#
module Genio
  module Helper
    module PHP

      include Base
      # Key/Reserved Words
      KeyWords = [
      '__halt_compiler',
      'abstract',
      'and',
      'array',
      'as',
      'break',
      'callable',
      'case',
      'catch',
      'class',
      'clone',
      'const',
      'continue',
      'declare',
      'default',
      'die',
      'do',
      'echo',
      'else',
      'elseif',
      'empty',
      'enddeclare',
      'endfor',
      'endforeach',
      'endif',
      'endswitch',
      'endwhile',
      'eval',
      'exit',
      'extends',
      'final',
      'for',
      'foreach',
      'function',
      'global',
      'goto',
      'if',
      'implements',
      'include',
      'include_once',
      'instanceof',
      'insteadof',
      'interface',
      'isset',
      'list',
      'namespace',
      'new',
      'or',
      'print',
      'private',
      'protected',
      'public',
      'require',
      'require_once',
      'return',
      'static',
      'switch',
      'throw',
      'trait',
      'try',
      'unset',
      'use',
      'var',
      'while',
      'xor'
      ]

      # Class static imports/references for rest services
      RestServiceImport = [
        "PayPal\\Rest\\IResource",
        "PayPal\\Transport\\PPRestCall"
      ]
        
      # Class static imports/references for rest services
      WSDLServiceImport = [
        "PayPal\\Exception\\PPTransformerException",
        "PayPal\\Core\\PPBaseService",
        "PayPal\\Core\\PPUtils"
      ]
        
      # Class static imports/references for WSDL
      WSDLStubImport = [
      ]
      # Spec Types to PHP Types conversion map
        BasicTypes = { "int" => "integer", "integer" => "integer", "positiveInteger" => "integer", "nonNegativeInteger" => "integer", "long" => "long", "double" => "double", "decimal" => "double", "float" => "float", "boolean" => "boolean", "string" => "string", "dateTime" => "string", "date" => "string", "date_time" => "string", "number" => "number", "object" => "object", "token" => "string", "duration" => "string", "anyURI" => "string", "base64Binary" => "string", "time" => "string" }

      # Returns the type of a member
      def find_basic_type(key)
        BasicTypes[key] ? BasicTypes[key] : valid_class_name(key)
      end
      
      def get_php_type(property, schema, classname = nil)
        type = find_basic_type(property.type)
        
        # for enums, return type as string
        type = "string" if schema.enum_types[property.type]
        
        # If type is Self (as per Spec) treat is as HostType
          # classname is always in camelcase
          type = classname if type.downcase == "self"
        type
      end

      def imports(data_type, schema, package, classname, schema_format)
        
        # mandatory references
        list = [] 
        if (data_type.extends)
          defpkg = get_namespace(schema.data_types[valid_class_name(data_type.extends)].package || package)
            list.push(defpkg + '\\' + valid_class_name(data_type.extends))
        end
        
        service = schema.services[classname]
            
        # Add use statements for function return types
        if service
          service.operations.each do |name, operation|
            type = schema.data_types[operation.response]
            if(type)
              defpkg = get_namespace(schema.data_types[valid_class_name(operation.response)].package || package)
              list.push(defpkg + '\\' + valid_class_name(operation.response)) if (operation.response && operation.response != classname)
            end 
          end
        end

        if (schema_format == "rest")
          list.push( "PayPal\\Common\\PPModel") if !data_type.extends
          list += RestServiceImport if service
        elsif (schema_format == "soap")
          list += WSDLStubImport
          if data_type.fault
            list.push('PayPal\\Core\\PPXmlFaultMessage')
          else
            list.push('PayPal\\Core\\PPXmlMessage')
          end
        end
        list.uniq.sort
      end
      
      # Generate imports for WSDL Service class
      def service_imports(schema, service, package)
        list = []
          
        # custom package provided during generation
        pkg = options[:namespace]
        pkg += "." if pkg.present?
        
        # import request and response of operations
        service.operations.each do |name, definition|
          if (definition.request_property)
            if (pkg.present?)
              list.push(pkg + valid_class_name(definition.request_property.type))
            else
              list.push(get_slashed_package_name(get_namespace(schema.data_types[valid_class_name(definition.request_property.type)].package || package) + "." + valid_class_name(definition.request_property.type)))
            end
          end
          if (definition.response)
            if (pkg.present?)
              list.push(pkg + valid_class_name(definition.response))
            else
              list.push(get_slashed_package_name(get_namespace(schema.data_types[valid_class_name(definition.response)].package || package) + "." + valid_class_name(definition.response)))
            end
          end
          if (definition.fault)
            if (pkg.present?)
              list.push(pkg + valid_class_name(definition.response))
            else
              list.push(get_slashed_package_name(get_namespace(schema.data_types[valid_class_name(definition.fault)].package || package) + "." + valid_class_name(definition.fault)))
            end
          end
        end
        # mandatory imports
        list += WSDLServiceImport
        list.uniq.sort
      end

      def process_path_with_placeholders(classname, name, path, hostId_check = false, argument_hash = nil, query_params)
        path = '/' + path if !path.start_with?('/')
        returnPath = ""
        if hostId_check
          returnPath = path.sub(/\{[^}]*\}/, "{$this->getId()}")
        returnPath = '"' + returnPath
        else
          values = argument_hash.keys
          returnPath = path.gsub(/\{[^}]*\}/) do |match|
            "$#{values.shift}"
          end
        returnPath = '"' + returnPath
        end
        if query_params
          returnPath = returnPath +'?" . http_build_query($queryParameters)'
        else
          returnPath = returnPath + '"'
        end
        returnPath
      end

      def valid_class_name(name)
        name.gsub(/-/, "_").camelcase
      end

      def valid_property_name(name)
        name.gsub(/-/, "_").camelize(:lower)
      end

      def deprecated_function_name(name)
        name.gsub(/-/, "_").capitalize
      end

      def validate_function_name(name)
        returnName = name
        if name == 'list'
          returnName = 'all'
        end
        returnName
      end
      
      # Prepends do to method names that are keywords
      def validate_method_name(name)
        KeyWords.include?(name) ? "do#{valid_class_name(name)}" : valid_property_name(name)
      end
      
      def validated_package(package)
        get_slashed_package_name(capitalize_package(remove_tld_in_package(convert_ns_to_package(package))))
      end
      
      # to underscore
      def to_underscore(name)
        name.gsub(/-/, "_")
      end

      def form_arguments(classname, property, name)
        arguments = {}
        property.path.scan(/{([^}]*)}/).each do |name, etc|
         if is_static_method(property) or name !~ /^#{classname}/i
          arguments[valid_property_name(name)] = "string"
         end
        end
        if property.request and property.request != classname
          arguments[valid_property_name(property.request)] = property.request
        end
        if property.type == 'GET' or property.type == 'HEAD' or property.type == 'DELETE'
          arguments["queryParameters"] = "array"
        elsif (property.parameters && allowed_params(property.parameters).size > 0)
          arguments["queryParameters"] = "array"
        end
        arguments
      end

      def get_object_array(classname, name, property, argument_hash)
        arr = []
        if property.path
          arr.push("queryParameters")
        else
          argument_hash.each do |name, type|
            if name.include?("Id") and property.path =~ /\{([^}]*id)\}/
              arr.push(name)
            end
          end
          if !is_static_method(property) and name != "create"
            arr.push("this.id")
          end
        end
        arr
      end

      def get_payload(classname, property)
        payload = '""';
        if !is_static_method(property)
          if property.request == classname
            payload = "$this->toJSON()"
          elsif property.request
            payload = "$" + valid_property_name(property.request) + "->toJSON()"
          end
        end
        payload
      end

      def get_namespace(package)
        pkg = options[:namespace]
        return capitalize_package(remove_tld_in_package(convert_ns_to_package(pkg))) if pkg.present?
        return validated_package(package)
      end

      # Returns a hash of arguments for wsdl operations
      # including the request and header arguments
      # hash is in the format of [name] = [type]
      def get_wsdl_operation_arguments(operation_definition)
        argument_array = []
          argument_array.push('$' + operation_definition.request.camelcase(:lower))
          #argument_array.push('$' + operation_definition.header.camelcase(:lower))
        argument_array
      end
      
      def get_rootname_serialization(data_type, schema)
        schema.services.each do |service_name, servicedef|
          servicedef.operations.each do |operation_name, oper_definition|
            if (data_type.name == oper_definition.request)
              temp = oper_definition.request_property.package + ":"  + oper_definition.request_property.name
              return temp
            elsif (data_type.name == oper_definition.header)
              temp = oper_definition.header_property.package + ":" + oper_definition.header_property.name
              return temp
            end
          end
        end
      end

      # Returns set of alllowed query parameters
      # for a operation
      def allowed_params(parameters)
        parameters.select do |name, values|
          values.location != "path"
        end
      end

    end
  end
end
