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