require 'thor/error'

module Genio
  module Util
    module SchemaHelper

      # Decide on a parser from the passed in URI and
      # return the parser after loading the definition
      # from the URI
      def get_parser(options)
        if options[:wsdl]
          load_wsdl(options[:wsdl])
        elsif options[:wadl]
          load_wadl(options[:wadl])
        elsif options[:json_schema]
          load_json_schema(options[:json_schema])
        elsif options[:schema]
          get_parser_with_uri(options[:schema])
        else
          raise Thor::RequiredArgumentMissingError, "No value provided for required options '--json-schema' or '--wsdl' or '--wadl'"
        end
      end

      def get_parser_with_uri(uri)
        if (uri.end_with?('wadl'))
          load_wadl(uri)
        elsif (uri.end_with?('wsdl'))
          load_wsdl(uri)
        else
          load_json_schema(uri)
        end
      end

      def load_wsdl(path)
        schema = Parser::Format::Wsdl.new
        load_schema_uri(schema, path)
        schema
      end

      def load_wadl(path)
        schema = Parser::Format::Wadl.new
        load_schema_uri(schema, path)
        schema
      end

      def load_json_schema(path)
        schema = Parser::Format::JsonSchema.new
        load_schema_uri(schema, path)
        schema.fix_unknown_service
        schema
      end

      def load_schema_uri(parser, uri)
        uri.split(/,/).each do |path|
          parser.load(path)
        end
      end

      # Replaces '-' with '_' and CamelCase(s)
      def validate_file_name(name)
        name.gsub(/-/, "_").camelcase
      end
    end
  end
end
