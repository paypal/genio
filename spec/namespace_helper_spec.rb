require 'spec_helper'

describe 'Genio::Util::NamespaceHelper' do
  before :all do
    @helper = Class.new do 
      include Genio::Util::NamespaceHelper
    end.new
  end
  
  it "should validate namepsace is urn or uri" do
    @helper.is_urn_ns("https://api.paypal.com/payments").should be_false
    @helper.is_urn_ns("urn:ebay:apis:eBLBaseComponents").should be_true
  end
  
  it "should convert namespaces to packagename" do
    @helper.convert_ns_to_package("com.paypal.api").should eql "com.paypal.api"
  end
  
  
end