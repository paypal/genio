require 'spec_helper'

describe 'PHPHelper' do

  before :all do
    @php_helper = Class.new do
      include Genio::Util::NamespaceHelper
      include Genio::Helper::PHP
    end.new
  end

  it "get basic types" do
    @php_helper.find_basic_type("int").should eq "integer"
    @php_helper.find_basic_type("integer").should eq "integer"
    @php_helper.find_basic_type("positiveInteger").should eq "integer"
    @php_helper.find_basic_type("nonNegativeInteger").should eq "integer"
    @php_helper.find_basic_type("long").should eq "long"
    @php_helper.find_basic_type("double").should eq "double"
    @php_helper.find_basic_type("decimal").should eq "double"
    @php_helper.find_basic_type("float").should eq "float"
    @php_helper.find_basic_type("boolean").should eq "boolean"
    @php_helper.find_basic_type("string").should eq "string"
    @php_helper.find_basic_type("dateTime").should eq "string"
    @php_helper.find_basic_type("date").should eq "string"
    @php_helper.find_basic_type("number").should eq "number"
    @php_helper.find_basic_type("object").should eq "object"
    @php_helper.find_basic_type("token").should eq "string"
    @php_helper.find_basic_type("duration").should eq "string"
    @php_helper.find_basic_type("anyURI").should eq "string"
    @php_helper.find_basic_type("date_time").should eq "string"
    @php_helper.find_basic_type("base64Binary").should eq "string"
    @php_helper.find_basic_type("time").should eq "string"
    @php_helper.find_basic_type("customType").should eq "CustomType"
    @php_helper.find_basic_type("CustomType").should eq "CustomType"
  end

  it "get property type" do
    property = Genio::Parser::Types::Property.new( :type => 'self' )
    schema = Genio::Parser::Format::JsonSchema.new()
    schema.enum_types["Test"] = { }
    @php_helper.get_php_type(property, schema, 'HostClass').should eq "HostClass"
    property = Genio::Parser::Types::Property.new( :type => 'Test' )
    @php_helper.get_php_type(property, schema, 'HostClass').should eq "string"
    property = Genio::Parser::Types::Property.new( :type => 'integer' )
    @php_helper.get_php_type(property, schema, 'HostClass').should eq "integer"
    property = Genio::Parser::Types::Property.new( :type => 'date_time' )
    @php_helper.get_php_type(property, schema, 'HostClass').should eq "string"
  end

  it "test process path with placeholders" do
    @php_helper.process_path_with_placeholders('Payment', 'Payment', '/v1/payments/{payment-id}', true, nil, nil).should eq '"/v1/payments/{$this->getId()}"'
    argument_hash = {}
    argument_hash['payment_id'] = 'string'
    query_params = {}
    @php_helper.process_path_with_placeholders('Payment', 'Payment', '/v1/payments/{payment-id}', false, argument_hash, nil).should eq '"/v1/payments/$payment_id"'
    @php_helper.process_path_with_placeholders('Payment', 'Payment', '/v1/payments/{payment-id}', false, argument_hash, query_params).should eq '"/v1/payments/$payment_id?" . http_build_query($queryParameters)'
    @php_helper.process_path_with_placeholders('Payment', 'Payment', '/v1/payments/{payment-id}', true, argument_hash, query_params).should eq '"/v1/payments/{$this->getId()}?" . http_build_query($queryParameters)'
  end

  it "validate class name" do
    @php_helper.valid_class_name('class-name').should eq "ClassName"
    @php_helper.valid_class_name('Class-Name').should eq "ClassName"
    @php_helper.valid_class_name('class-Name').should eq "ClassName"
    @php_helper.valid_class_name('Class-name').should eq "ClassName"
    @php_helper.valid_class_name('class_name').should eq "ClassName"
    @php_helper.valid_class_name('Class_Name').should eq "ClassName"
    @php_helper.valid_class_name('class_Name').should eq "ClassName"
    @php_helper.valid_class_name('Class_name').should eq "ClassName"
    @php_helper.valid_class_name('classname').should eq "Classname"
  end

  it "validate property name" do
    @php_helper.valid_property_name('property-name').should eq 'propertyName'
    @php_helper.valid_property_name('Property-name').should eq 'propertyName'
    @php_helper.valid_property_name('Property-Name').should eq 'propertyName'
    @php_helper.valid_property_name('property-Name').should eq 'propertyName'
    @php_helper.valid_property_name('propertyname').should eq 'propertyname'
  end

  it "get deprecated function name" do
    @php_helper.deprecated_function_name('function-name').should eq 'Function_name'
    @php_helper.deprecated_function_name('function_name').should eq 'Function_name'
    @php_helper.deprecated_function_name('functionname').should eq 'Functionname'
  end

  it "validate method name" do
    @php_helper.validate_method_name('function-name').should eq 'functionName'
    @php_helper.validate_method_name('function_name').should eq 'functionName'
    @php_helper.validate_method_name('functionname').should eq 'functionname'
    @php_helper.validate_method_name('abstract').should eq 'doAbstract'
  end

  it "validate package name" do
    @php_helper.validated_package('com.paypal.api').should eq 'Paypal\\Api'
  end

  it "test to underscore" do
    @php_helper.to_underscore('underscore-me').should eq 'underscore_me'
    @php_helper.to_underscore('Underscore-Me').should eq 'Underscore_Me'
    @php_helper.to_underscore('UnderscoreMe').should eq 'UnderscoreMe'
  end

end
