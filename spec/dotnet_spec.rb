require 'spec_helper'

describe 'DotNetHelper' do

  before :all do
    @dotnet_helper = Class.new do
      include Genio::Helper::DotNet
    end.new
  end

  it "get basic types" do
    @dotnet_helper.find_basic_type("int").should eq "int"
    @dotnet_helper.find_basic_type("integer").should eq "int"
    @dotnet_helper.find_basic_type("positiveInteger").should eq "int"
    @dotnet_helper.find_basic_type("nonNegativeInteger").should eq "int"
    @dotnet_helper.find_basic_type("long").should eq "long"
    @dotnet_helper.find_basic_type("double").should eq "double"
    @dotnet_helper.find_basic_type("decimal").should eq "double"
    @dotnet_helper.find_basic_type("float").should eq "float"
    @dotnet_helper.find_basic_type("boolean").should eq "bool"
    @dotnet_helper.find_basic_type("string").should eq "string"
    @dotnet_helper.find_basic_type("dateTime").should eq "string"
    @dotnet_helper.find_basic_type("date").should eq "string"
    @dotnet_helper.find_basic_type("number").should eq "double"
    @dotnet_helper.find_basic_type("object").should eq "object"
    @dotnet_helper.find_basic_type("token").should eq "string"
    @dotnet_helper.find_basic_type("duration").should eq "string"
    @dotnet_helper.find_basic_type("anyURI").should eq "string"
    @dotnet_helper.find_basic_type("date_time").should eq "string"
    @dotnet_helper.find_basic_type("base64Binary").should eq "string"
    @dotnet_helper.find_basic_type("time").should eq "string"
    @dotnet_helper.find_basic_type("Int").should eq "int"
    @dotnet_helper.find_basic_type("Integer").should eq "int"
    @dotnet_helper.find_basic_type("PositiveInteger").should eq "int"
    @dotnet_helper.find_basic_type("NonNegativeInteger").should eq "int"
    @dotnet_helper.find_basic_type("Long").should eq "long"
    @dotnet_helper.find_basic_type("Double").should eq "double"
    @dotnet_helper.find_basic_type("Decimal").should eq "double"
    @dotnet_helper.find_basic_type("Float").should eq "float"
    @dotnet_helper.find_basic_type("Boolean").should eq "bool"
    @dotnet_helper.find_basic_type("String").should eq "string"
    @dotnet_helper.find_basic_type("DateTime").should eq "string"
    @dotnet_helper.find_basic_type("Date").should eq "string"
    @dotnet_helper.find_basic_type("Number").should eq "double"
    @dotnet_helper.find_basic_type("Object").should eq "object"
    @dotnet_helper.find_basic_type("Token").should eq "string"
    @dotnet_helper.find_basic_type("Duration").should eq "string"
    @dotnet_helper.find_basic_type("AnyURI").should eq "string"
    @dotnet_helper.find_basic_type("Date_time").should eq "string"
    @dotnet_helper.find_basic_type("Base64Binary").should eq "string"
    @dotnet_helper.find_basic_type("Time").should eq "string"
  end

  it "only basic type" do
    @dotnet_helper.only_basic_type("String").should eq "string"
    @dotnet_helper.only_basic_type("CustomClass").should eq nil
  end

  it "get property class" do
    property = Genio::Parser::Types::Property.new( :type => 'self' )
    @dotnet_helper.get_property_class(property, 'HostClass').should eq "HostClass"
    property.type = 'SampleClass'
    @dotnet_helper.get_property_class(property, 'SampleClass').should eq "SampleClass"
    property.type = 'String'
    @dotnet_helper.get_property_class(property, 'String').should eq "string"
    property.type = 'String'
    @dotnet_helper.get_property_class(property).should eq "string"
    property.type = 'string'
    @dotnet_helper.get_property_class(property).should eq "string"
    property.array = true
    @dotnet_helper.get_property_class(property).should eq "List<string>"
  end

  it "validate path" do
    path = '/v1/payments/{payment-id}'
    @dotnet_helper.validate_path(path).should eq "/v1/payments/{payment_id}"
    path = '/v1/payments/{paymentId}'
    @dotnet_helper.validate_path(path).should eq "/v1/payments/{paymentId}"
    path = '/v1/payments/{PaymentId}'
    @dotnet_helper.validate_path(path).should eq "/v1/payments/{PaymentId}"
    path = '/v1/payments/{Payment-Id}'
    @dotnet_helper.validate_path(path).should eq "/v1/payments/{Payment_Id}"
    path = '/v1/payments/{Payment-Id-value}'
    @dotnet_helper.validate_path(path).should eq "/v1/payments/{Payment_Id_value}"
  end

  it "validate class name" do
    @dotnet_helper.validate_class_name('string').should eq "string"
    @dotnet_helper.validate_class_name('string').should eq "string"
    @dotnet_helper.validate_class_name('custom_class').should eq "CustomClass"
    @dotnet_helper.validate_class_name('custom-class').should eq "CustomClass"
  end

  it "validate property name" do
    @dotnet_helper.validate_property_name("Line1").should eq "Line1"
    @dotnet_helper.validate_property_name("country-Name").should eq "country_Name"
    @dotnet_helper.validate_property_name("country-Name", true).should eq "CountryName"
    @dotnet_helper.validate_property_name("Country-Name").should eq "Country_Name"
    @dotnet_helper.validate_property_name("Country-Name", true).should eq "CountryName"
    @dotnet_helper.validate_property_name("country_Name").should eq "country_Name"
    @dotnet_helper.validate_property_name("country_Name", true).should eq "CountryName"
    @dotnet_helper.validate_property_name("Country_Name").should eq "Country_Name"
    @dotnet_helper.validate_property_name("Country_Name", true).should eq "CountryName"
    @dotnet_helper.validate_property_name("country-name").should eq "country_name"
    @dotnet_helper.validate_property_name("country-name", true).should eq "CountryName"
    @dotnet_helper.validate_property_name("Country-name").should eq "Country_name"
    @dotnet_helper.validate_property_name("Country-name", true).should eq "CountryName"
  end

  it "validate method name" do
    @dotnet_helper.validate_method_name("Call-Me").should eq "CallMe"
    @dotnet_helper.validate_method_name("Call_Me").should eq "CallMe"
    @dotnet_helper.validate_method_name("call-me").should eq "CallMe"
    @dotnet_helper.validate_method_name("call_me").should eq "CallMe"
    @dotnet_helper.validate_method_name("call-Me").should eq "CallMe"
    @dotnet_helper.validate_method_name("Call-me").should eq "CallMe"
    @dotnet_helper.validate_method_name("call_Me").should eq "CallMe"
    @dotnet_helper.validate_method_name("Call_me").should eq "CallMe"
    @dotnet_helper.validate_method_name("void").should eq "DoVoid"
  end

  it "validate property name as argument" do
    @dotnet_helper.validate_property_as_argument("Line1").should eq "line1"
    @dotnet_helper.validate_property_as_argument("country-Name").should eq "countryName"
    @dotnet_helper.validate_property_as_argument("Country-Name").should eq "countryName"
    @dotnet_helper.validate_property_as_argument("country_Name").should eq "countryName"
    @dotnet_helper.validate_property_as_argument("Country_Name").should eq "countryName"
    @dotnet_helper.validate_property_as_argument("country-name").should eq "countryName"
    @dotnet_helper.validate_property_as_argument("Country-name").should eq "countryName"
  end

  it "validate enum name" do
    @dotnet_helper.validate_enum_name("Country-Name").should eq "Country_Name"
    @dotnet_helper.validate_enum_name("Country Name").should eq "Country_Name"
    @dotnet_helper.validate_enum_name("1Country-Name").should eq "_1Country_Name"
  end

end
