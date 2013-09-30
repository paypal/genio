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
require "genio"
require "thor"
require "json"
require "uri"
require "genio/parser"
require "pp"

module Genio
  class Tasks < Thor
    include Thor::Actions
    include Template

    class_option :force,  :type => :boolean, :default => false,   :desc => "Overwrite files that already exist"
    class_option :skip,   :type => :boolean, :default => false,   :desc => "Skip files that already exist"

    # Schema path
    class_option :json_schema,  :type => :string, :desc => "JSON Schema path"
    class_option :wsdl,         :type => :string, :desc => "WSDL path"
    class_option :wadl,         :type => :string, :desc => "WADL path"
    class_option :schema,       :type => :string, :desc => "Any schema path"

    class_option :output_path,  :type => :string, :default => "output/stubs/"
    class_option :namespace,    :type => :string,                     :desc => "Dot separated package name"
    class_option :gen_deprecated_methods, :type => :boolean, :default => false, :desc => "Generate deprecated version of methods using AccessToken parameter"


    desc "java", "Generate rest java stubs"
    method_option :mandate_oauth,  :type => :boolean, :default => true,
      :desc => "Force APIContext object to include oauth token"
    def java
      if schema.is_a? Parser::Format::Wsdl
        java_with_wsdl
      else
        java_with_json_schema
      end
    end

    desc "php", "Generate rest php stubs"
    def php
      if schema.is_a? Parser::Format::Wsdl
        php_with_wsdl
      else
        php_with_json_schema
      end
    end

    desc "dotnet", "Generate rest dotnet stubs"
    method_option :mandate_oauth,  :type => :boolean, :default => true,
      :desc => "Force APIContext object to include oauth token"
    def dotnet
      if schema.is_a? Parser::Format::Wsdl
        dotnet_with_wsdl
      else
        dotnet_with_json_schema
      end
    end

    desc "iodocs", "Generate iodocs"
    method_option :output_file, :type => :string, :default => "iodocs.json"
    def iodocs
      file = File.join(options[:output_path], options[:output_file])
      create_file(file, JSON.pretty_generate(schema.to_iodocs))
    end

    private

    def java_with_json_schema
      folder = options[:output_path]
      schema.data_types.each do|name, data_type|
        package = options[:namespace] || convert_ns_to_package(data_type.package || schema.endpoint);
        render("templates/sdk.rest_java.erb",
            :data_type => data_type,
            :classname => name,
            :schema => schema,
            :package => package,
            :helper => Helper::Java,
            :gen_deprecated_methods => options[:gen_deprecated_methods],
            :create_file => File.join(folder, "#{get_package_folder(package)}/#{validate_file_name(name)}.java"))
      end
      render("templates/sdk.rest_version_java.erb",
          :create_file => File.join(folder, "com/paypal/sdk/info/SDKVersionImpl.java"))
    end

    def java_with_wsdl
      folder = options[:output_path]

      # emit datatypes
      schema.data_types.each do|name, data_type|
        package = options[:namespace] || convert_ns_to_package(data_type.package)
        render("templates/sdk.wsdl_java.erb",
            :package => package,
            :classname => name,
            :schema => schema,
            :data_type => data_type,
            :helper => Helper::Java,
            :create_file => File.join(folder, "#{get_package_folder(package)}/#{validate_file_name(name)}.java"))
      end

      # emit enumtypes
      schema.enum_types.each do|name, definition|
        package = options[:namespace] || convert_ns_to_package(definition.package)
        render("templates/sdk.wsdlenum_java.erb",
            :package => package,
            :classname => name,
            :definition => definition,
            :helper => Helper::Java,
            :create_file => File.join(folder, "#{get_package_folder(package)}/#{validate_file_name(name)}.java"))
      end

      # emit service
      schema.services.each do|name, service|
        package = options[:namespace] || convert_ns_to_package(service.package)
        render("templates/sdk.wsdlservice_java.erb",
            :package => package,
            :classname => name,
            :schema => schema,
            :service => service,
            :helper => Helper::Java,
            :create_file => File.join(folder, "#{get_package_folder(package)}/#{validate_file_name(name)}.java"))
      end
    end

    def php_with_json_schema
      folder = options[:output_path]
      schema.data_types.each do|name, data_type|
        package = get_slashed_package_name(capitalize_package(remove_tld_in_package(convert_ns_to_package(options[:namespace] || data_type.package || schema.endpoint))))
        render("templates/sdk.rest_php.erb",
            :data_type => data_type,
            :classname => name,
            :schema => schema,
            :package => package,
            :helper => Helper::PHP,
            :gen_deprecated_methods => options[:gen_deprecated_methods],
            :create_file => File.join(folder, "#{get_package_folder(package)}/#{name}.php"))
      end
    end

    def php_with_wsdl
      folder = options[:output_path]
      schema.data_types.each do|name, data_type|
        package = get_slashed_package_name(capitalize_package(remove_tld_in_package(convert_ns_to_package(options[:namespace] || data_type.package || schema.endpoint))))
        render("templates/sdk.wsdl_php.erb",
            :data_type => data_type,
            :classname => name,
            :schema => schema,
            :package => package,
            :helper => Helper::PHP,
            :gen_deprecated_methods => options[:gen_deprecated_methods],
            :create_file => File.join(folder, "#{get_package_folder(package)}/#{name}.php"))
    end

    # emit service
    schema.services.each do|name, service|
        package = get_slashed_package_name(capitalize_package(remove_tld_in_package(convert_ns_to_package(options[:namespace] || service.package || schema.endpoint))))
        render("templates/sdk.wsdlservice_php.erb",
            :package => package,
            :classname => name,
            :schema => schema,
            :service => service,
            :helper => Helper::PHP,
            :gen_deprecated_methods => options[:gen_deprecated_methods],
            :create_file => File.join(folder, "#{get_package_folder(package)}/#{name}.php"))
      end
    end

    def dotnet_with_json_schema
      folder = options[:output_path]
      schema.data_types.each do|name, data_type|
        package = capitalize_package(remove_tld_in_package(convert_ns_to_package(options[:namespace] || data_type.package || schema.endpoint)))
        render("templates/sdk.rest_dotnet.erb",
          :data_type => data_type,
          :classname => name,
          :schema => schema,
          :package => package,
          :helper => Helper::DotNet,
          :gen_deprecated_methods => options[:gen_deprecated_methods],
          :create_file => File.join(folder, "#{get_package_folder(package, true)}/#{validate_file_name(name)}.cs"))
      end
      render("templates/sdk.rest_version_dotnet.erb",
          :create_file => File.join(folder, "PayPal/Sdk/Info/SDKVersionImpl.cs"))
    end

    def dotnet_with_wsdl
      folder = options[:output_path]

      # emit datatypes
      schema.data_types.each do|name, data_type|
        package = capitalize_package(remove_tld_in_package(convert_ns_to_package(options[:namespace] || data_type.package)))
        render("templates/sdk.wsdl_dotnet.erb",
            :package => package,
            :classname => name,
            :schema => schema,
            :data_type => data_type,
            :helper => Helper::DotNet,
            :create_file => File.join(folder, "#{get_package_folder(package)}/#{validate_file_name(name)}.cs"))
      end

      # emit enumtypes
      schema.enum_types.each do|name, definition|
        package = capitalize_package(remove_tld_in_package(convert_ns_to_package(options[:namespace] || definition.package)))
        render("templates/sdk.wsdlenum_dotnet.erb",
            :package => package,
            :classname => name,
            :definition => definition,
            :helper => Helper::DotNet,
            :create_file => File.join(folder, "#{get_package_folder(package)}/#{validate_file_name(name)}.cs"))
      end

      # emit service
      schema.services.each do|name, service|
        package = capitalize_package(remove_tld_in_package(convert_ns_to_package(options[:namespace] || service.package)))
        render("templates/sdk.wsdlservice_dotnet.erb",
            :package => package,
            :classname => name,
            :schema => schema,
            :service => service,
            :helper => Helper::DotNet,
            :create_file => File.join(folder, "#{get_package_folder(package)}/#{validate_file_name(name)}.cs"))
      end
    end

    # load the schema by choosing an appropriate parser
    def schema
      @schema ||= get_parser(options)
    end

    include Util::NamespaceHelper
    include Util::SchemaHelper
  end
end
