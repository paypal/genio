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
require "genio/version"

module Genio
  autoload :Template, "genio/template"
  autoload :Logging,  "genio/logging"
  autoload :Tasks,    "genio/tasks"

  module Helper
    autoload :Base,   "genio/helper/base"
    autoload :PHP,    "genio/helper/php"
    autoload :DotNet, "genio/helper/dot_net"
    autoload :Java,   "genio/helper/java"
  end

  module Util
    autoload :NamespaceHelper, "genio/util/namespace_helper"
    autoload :SchemaHelper, "genio/util/schema_helper"
  end
end
