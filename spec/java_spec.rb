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
require 'spec_helper'

describe 'JavaHelper' do

  before :all do
    @java_helper = Class.new do
      include Genio::Helper::Java
    end.new
  end

  it "get basic types" do
    @java_helper.find_basic_type("int").should eq "Integer"
    @java_helper.find_basic_type("integer").should eq "Integer"
    @java_helper.find_basic_type("positiveInteger").should eq "Integer"
    @java_helper.find_basic_type("nonNegativeInteger").should eq "Integer"
    @java_helper.find_basic_type("long").should eq "Long"
    @java_helper.find_basic_type("double").should eq "Double"
    @java_helper.find_basic_type("decimal").should eq "Double"
    @java_helper.find_basic_type("float").should eq "Float"
    @java_helper.find_basic_type("boolean").should eq "Boolean"
    @java_helper.find_basic_type("string").should eq "String"
    @java_helper.find_basic_type("dateTime").should eq "String"
    @java_helper.find_basic_type("date").should eq "String"
    @java_helper.find_basic_type("number").should eq "Number"
    @java_helper.find_basic_type("object").should eq "Object"
    @java_helper.find_basic_type("token").should eq "String"
    @java_helper.find_basic_type("duration").should eq "String"
    @java_helper.find_basic_type("anyURI").should eq "String"
    @java_helper.find_basic_type("date_time").should eq "String"
    @java_helper.find_basic_type("base64Binary").should eq "String"
    @java_helper.find_basic_type("time").should eq "String"
    @java_helper.find_basic_type("Int").should eq "Integer"
    @java_helper.find_basic_type("Integer").should eq "Integer"
    @java_helper.find_basic_type("PositiveInteger").should eq "Integer"
    @java_helper.find_basic_type("NonNegativeInteger").should eq "Integer"
    @java_helper.find_basic_type("Long").should eq "Long"
    @java_helper.find_basic_type("Double").should eq "Double"
    @java_helper.find_basic_type("Decimal").should eq "Double"
    @java_helper.find_basic_type("Float").should eq "Float"
    @java_helper.find_basic_type("Boolean").should eq "Boolean"
    @java_helper.find_basic_type("String").should eq "String"
    @java_helper.find_basic_type("DateTime").should eq "String"
    @java_helper.find_basic_type("Date").should eq "String"
    @java_helper.find_basic_type("Number").should eq "Number"
    @java_helper.find_basic_type("Object").should eq "Object"
    @java_helper.find_basic_type("Token").should eq "String"
    @java_helper.find_basic_type("Duration").should eq "String"
    @java_helper.find_basic_type("AnyURI").should eq "String"
    @java_helper.find_basic_type("Date_time").should eq "String"
    @java_helper.find_basic_type("Base64Binary").should eq "String"
    @java_helper.find_basic_type("Time").should eq "String"
  end

  it "only basic type" do
    @java_helper.only_basic_type("String").should eq "String"
    @java_helper.only_basic_type("CustomClass").should eq nil
  end

  it "get property class" do
    property = Genio::Parser::Types::Property.new( :type => 'self' )
    @java_helper.get_property_class(property, 'HostClass').should eq "HostClass"
    property.type = 'SampleClass'
    @java_helper.get_property_class(property, 'SampleClass').should eq "SampleClass"
    property.type = 'String'
    @java_helper.get_property_class(property, 'String').should eq "String"
    property.type = 'String'
    @java_helper.get_property_class(property).should eq "String"
    property.type = 'string'
    @java_helper.get_property_class(property).should eq "String"
    property.array = true
    @java_helper.get_property_class(property).should eq "List<String>"
  end

  it "validate path" do
    path = '/v1/payments/{payment-id}'
    @java_helper.validate_path(path).should eq "/v1/payments/{paymentId}"
    path = '/v1/payments/{paymentId}'
    @java_helper.validate_path(path).should eq "/v1/payments/{paymentId}"
    path = '/v1/payments/{PaymentId}'
    @java_helper.validate_path(path).should eq "/v1/payments/{paymentId}"
    path = '/v1/payments/{Payment-Id}'
    @java_helper.validate_path(path).should eq "/v1/payments/{paymentId}"
    path = '/v1/payments/{Payment-Id-value}'
    @java_helper.validate_path(path).should eq "/v1/payments/{paymentIdValue}"
  end

  it "validate class name" do
    @java_helper.validate_class_name('string').should eq "String"
    @java_helper.validate_class_name('String').should eq "String"
    @java_helper.validate_class_name('custom_class').should eq "CustomClass"
    @java_helper.validate_class_name('custom-class').should eq "CustomClass"
  end

  it "validate property name" do
    @java_helper.validate_property_name("Line1").should eq "line1"
    @java_helper.validate_property_name("country-Name").should eq "countryName"
    @java_helper.validate_property_name("Country-Name").should eq "countryName"
    @java_helper.validate_property_name("country_Name").should eq "countryName"
    @java_helper.validate_property_name("Country_Name").should eq "countryName"
    @java_helper.validate_property_name("country-name").should eq "countryName"
    @java_helper.validate_property_name("Country-name").should eq "countryName"
  end

  it "validate method name" do
    @java_helper.validate_method_name("Call-Me").should eq "callMe"
    @java_helper.validate_method_name("Call_Me").should eq "callMe"
    @java_helper.validate_method_name("call-me").should eq "callMe"
    @java_helper.validate_method_name("call_me").should eq "callMe"
    @java_helper.validate_method_name("call-Me").should eq "callMe"
    @java_helper.validate_method_name("Call-me").should eq "callMe"
    @java_helper.validate_method_name("call_Me").should eq "callMe"
    @java_helper.validate_method_name("Call_me").should eq "callMe"
    @java_helper.validate_method_name("void").should eq "doVoid"
  end

  it "validate enum name" do
    @java_helper.validate_enum_name("Country-Name").should eq "Country_Name"
    @java_helper.validate_enum_name("Country Name").should eq "Country_Name"
    @java_helper.validate_enum_name("1Country-Name").should eq "_1Country_Name"
  end

end
