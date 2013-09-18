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
