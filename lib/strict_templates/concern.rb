require 'active_support/concern'

module StrictTemplates
  class SQLPerformedWithinTemplateError < StandardError; end

  module Concern
    extend ActiveSupport::Concern

    included do
      def render(*args, &block)
        if !should_raise_on_queries?
          return super
        end

        callback = lambda do |name, start, finish, id, payload|
          if !should_ignore_sql_statement?(payload[:name])
            if has_custom_error_handler?
              config.strict_templates.error_handler.call(payload)
            else
              raise SQLPerformedWithinTemplateError.new("A SQL request was issued within the template: \n  #{payload[:sql]}")
            end
          end
        end

        ActiveSupport::Notifications.subscribed(callback, 'sql.active_record') do
          super
        end
      end

      private

      def should_ignore_sql_statement?(name)
        name == 'SCHEMA' || name == 'ActiveRecord::SchemaMigration Load'
      end

      def config
        Rails.configuration if defined?(Rails)
      end

      def should_raise_on_queries?
        config&.strict_templates&.raise_on_queries != false
      end

      def has_custom_error_handler?
        config&.strict_templates&.error_handler
      end
    end
  end
end