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
    module Java

      include Base

      # Key/Reserved Words
      KeyWords = [
        "abstract",
        "continue",
        "for",
        "new",
        "switch",
        "assert",
        "default",
        "goto",
        "package",
        "synchronized",
        "boolean",
        "do",
        "if",
        "private",
        "this",
        "break",
        "double",
        "implements",
        "protected",
        "throw",
        "byte",
        "else",
        "import",
        "public",
        "throws",
        "case",
        "enum",
        "instanceof",
        "return",
        "transient",
        "catch",
        "extends",
        "int",
        "short",
        "try",
        "char",
        "final",
        "interface",
        "static",
        "void",
        "class",
        "finally",
        "long",
        "strictfp**",
        "volatile",
        "const",
        "float",
        "native",
        "super",
        "while"
        ]

      # Keyword substitute hash
      KeywordsSubstitute = {

      }

      # Static resource imports
      # Resource class which have REST operation enabled
      # depend on these core classes
      ServiceImportREST = [
        "com.paypal.core.rest.PayPalRESTException",
        "com.paypal.core.rest.PayPalResource",
        "com.paypal.core.rest.HttpMethod",
        "com.paypal.core.rest.PayPalRESTException",
        "com.paypal.core.rest.RESTUtil",
        "com.paypal.core.rest.JSONFormatter",
        "com.paypal.core.rest.APIContext",
        "com.paypal.core.Constants",
        "com.paypal.core.SDKVersion",
        "com.paypal.sdk.info.SDKVersionImpl",
        "java.io.File",
        "java.io.InputStream",
        "java.util.Properties",
        "java.util.Map",
        "java.util.HashMap"
        ]

      # Static resource imports for WSDL
      # service class; they depend on these core classes
      ServiceImportWSDL = [
        "java.io.*",
        "java.util.Map",
        "java.util.HashMap",
        "java.util.Properties",
        "com.paypal.core.BaseService",
        "com.paypal.exception.*",
        "com.paypal.sdk.exceptions.*",
        "com.paypal.core.APICallPreHandler",
        "com.paypal.core.DefaultSOAPAPICallHandler",
        "com.paypal.core.DefaultSOAPAPICallHandler.XmlNamespaceProvider",
        "org.w3c.dom.Node",
        "org.xml.sax.SAXException",
        "org.xml.sax.InputSource",
        "javax.xml.parsers.ParserConfigurationException",
        "javax.xml.parsers.DocumentBuilderFactory",
        "javax.xml.xpath.XPathConstants",
        "javax.xml.xpath.XPathExpressionException",
        "javax.xml.xpath.XPathFactory",
        "com.paypal.core.DefaultSOAPAPICallHandler",
        "com.paypal.core.BaseAPIContext"
        ]

      # Static resource imports for WSDL
      # stub classes; they depend on these core classes
      StubImportWSDL = [
        "javax.xml.xpath.XPath",
        "javax.xml.xpath.XPathConstants",
        "javax.xml.xpath.XPathExpressionException",
        "javax.xml.xpath.XPathFactory",
        "org.w3c.dom.Node",
        "org.w3c.dom.NodeList",
        "com.paypal.core.SDKUtil"
        ]

      # Spec Types to Java Types conversion map
      BasicTypes = { "int" => "Integer", "integer" => "Integer", "positiveInteger" => "Integer", "nonNegativeInteger" => "Integer", "long" => "Long", "double" => "Double", "decimal" => "Double", "float" => "Float", "boolean" => "Boolean", "string" => "String", "dateTime" => "String", "date" => "String", "number" => "Number", "object" => "Object", "token" => "String", "duration" => "String", "anyURI" => "String", "date_time" => "String", "base64Binary" => "String", "time" => "String" }

      # Returns the type of a member
      # If the passed in parameter is one of Basic types
      # return the corresponding BasicType, else
      # the parameter is returned unmodified
      def find_basic_type(key)
        only_basic_type(key) || key
      end

      # Returns the corresponding basic
      # data type in Java
      def only_basic_type(key)
        BasicTypes[key.camelcase(:lower)]
      end

      # Returns the imports for the Class
      def imports(data_type, schema, package, classname, schema_format, operation_input = false)
        list = []

        # custom package provided during generation
        pkg = options[:namespace]
        pkg += "." if pkg.present?

        # mandatory imports
        list += ["com.paypal.core.rest.JSONFormatter"] if (schema_format == "rest")
        data_type.properties.each do |name, property|
          type = schema.data_types[property.type] || schema.enum_types[property.type]
          if (type)
            if (pkg.present?)
              list.push(pkg + property.type)
            else
              # TODO fix this when definition namespace fixes
              defpkg = convert_ns_to_package(type.package || package)
              list.push(defpkg + "." + property.type)
            end
          end
          list.push("java.util.List") if property.array
          list.push("java.util.ArrayList") if property.array
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
                  list.push(pkg + property.type)
                else
                  # TODO fix this when definition namespace fixes
                  defpkg = convert_ns_to_package(type.package || package)
                  list.push(defpkg + "." + property.type)
                end
              end
              list.push("java.util.List") if property.array
              list.push("java.util.ArrayList") if property.array
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
                list.push(pkg + validate_class_name(operation.response))
              else
                list.push(convert_ns_to_package(schema.data_types[operation.response].try(:package) || package) + "." + validate_class_name(operation.response))
              end
            end
          if operation.request
            if (pkg.present?)
              list.push(pkg + validate_class_name(operation.request))
            else
              list.push(convert_ns_to_package(schema.data_types[operation.request].try(:package) || package) + "." + validate_class_name(operation.request))
            end
          end
          end
        end

        list += ServiceImportREST if (schema.services[classname] && (schema_format == "rest"))
        list += StubImportWSDL if (schema_format == "soap")
        list += ["com.paypal.core.message.XMLMessageSerializer"] if (operation_input && (schema_format == "soap"))
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
              list.push(pkg + validate_class_name(definition.request_property.type))
            else
              list.push(convert_ns_to_package(schema.data_types[validate_class_name(definition.request_property.type)].package || package) + "." + validate_class_name(definition.request_property.type))
            end
          end
          if (definition.response_property)
            if (pkg.present?)
              list.push(pkg + validate_class_name(definition.response_property.type))
            else
              list.push(convert_ns_to_package(schema.data_types[validate_class_name(definition.response_property.type)].package || package) + "." + validate_class_name(definition.response_property.type))
            end
          end
          if (definition.fault_property)
            if (pkg.present?)
              list.push(pkg + validate_class_name(definition.fault_property.type))
            else
              list.push(convert_ns_to_package(schema.data_types[validate_class_name(definition.fault_property.type)].package || package) + "." + validate_class_name(definition.fault_property.type))
            end
          end
        end

        # mandatory imports
        list += ServiceImportWSDL
        list.uniq.sort
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

      # Replaces any "-" present in the path URI to valid "_"
      # used while replacing placeholders with exact values
      def validate_path(path)
        path.gsub(/\{([^}]*)\}/){|match| "\{#{validate_property_name($1)}\}" }
      end

      # Replaces '-' with '_' and CamelCase(s) them [Java]
      def validate_class_name(name)
      only_basic_type(name) || name.gsub(/-/, "_").camelcase
      end

      # Replaces '-' with '_' and camelCase(s) them
      # used for valid property names [Java]
      # replaces keywords with substitutes form KeywordsSubstitute
      def validate_property_name(name)
        valid_name = name.gsub(/-/, "_").camelcase(:lower)
        if KeyWords.include? valid_name
          valid_name = KeywordsSubstitute[valid_name]
        end
        valid_name
      end

      # Replaces '-' and spaces with '_'
      # used for valid enum names [Java]
      def validate_enum_name(name)
        name.gsub(/[-\s]/, "_").sub(/^\d/, '_\0')
      end

      # Prepends do to method names that are keywords
      def validate_method_name(name)
        KeyWords.include?(name) ? "do#{name.gsub(/-/, "_").camelcase}" : validate_property_name(name)
      end

      # Generate method formal parameters for REST API calls
      def form_rest_api_args(classname, property, name)
        arguments = {}
        property.path.scan(/{([^}]*)}/).each do |name, etc|
          if is_static_method(property) or validate_class_name(name) !~ /^#{classname}/i
            arguments[validate_property_name(name)] = "String"
          end
        end
        if property.request and property.request != classname
          arguments[validate_property_name(property.request)] = property.request
        end
        if property.type == 'GET' or property.type == 'HEAD' or property.type == 'DELETE'
          arguments["queryParameters"] = "Map<String, String>"
        end
        arguments
      end

      # Generate method formal parameters for CXF interface
      # The argument type is appended with annotations
      def form_cxf_args(classname, property, name)
        arguments = {}
        arguments["context"] = "@Context final MessageContext"
        property.parameters.each do |name, parameter|
          arguments[validate_property_name(name)] = "@#{parameter.location.capitalize}Param(\"#{name}\") String"
        end if property.parameters
        if property.request
          arguments[property.request.camelcase(:lower)] = property.request
        end
        arguments
      end

      # Generates a map of parameters for placeholders used
      # to process path URI
      def generate_format_hash(classname, property, resourcePath)
        map = {}
        resourcePath.scan(/\{([^}]*)\}/) { |name, etc|
          if (name.match(/^#{classname}.*/i) and !is_static_method(property))
            map[name] = 'this.getId()'
          else
            map[name] = validate_property_name(name)
          end
        }
        map
      end

      # Returns the expression to set for payLoad in the API call
      def get_payload(classname, property)
        payLoad = '""';
        if !is_static_method(property)
          if property.request == classname
            payLoad = "this.toJSON()"
          elsif property.request
            payLoad = validate_property_name(property.request) + ".toJSON()"
          end
        end
        payLoad
      end

      # Returns true if data_type is in services operations
      # request or header, else returns false
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
          argument_hash[validate_property_name(operation_definition.request_property.name)] = operation_definition.request
        argument_hash
      end

      private
      include Genio::Util::NamespaceHelper
    end
  end
end
