require 'tilt'
require "thor"

module Genio
  module Template
    include Thor::Shell
    include Thor::Actions

    def render_values
      @render_values ||= [{}]
    end

    def render(template, values = {})
      values = { :create_file => nil }.merge(values)
      values = render_values.last.merge(values)
      values[:scope] ||= generate_scope(values)
      render_values.push(values)
      content = parse_erb(template, values)
      render_values.pop
      create_file(values[:create_file], content) if values[:create_file]
      content
    end

    def generate_scope(values)
      Class.new do
        include values[:helper] if values[:helper]

        def initialize(klass)
          @klass = klass
        end

        def method_missing(name, *args)
          @klass.send(name, *args)
        end
      end.new(self)
    end

    def parse_erb(template, values)
      filename = File.absolute_path(template, template_path)
      template = Tilt::ErubisTemplate.new(Dir["#{filename}*"].first || template)
      template.render(values[:scope] || self, values)
    end

    def template_path
      @template_path ||= File.expand_path("../../../", __FILE__)
    end

  end
end
