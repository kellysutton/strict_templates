require 'active_support/concern'

module StrictTemplates
  class SQLPerformedWithinTemplateError < StandardError; end

  module Concern
    extend ActiveSupport::Concern

    included do
      def render(*args, &block)
        callback = lambda do |name, start, finish, id, payload|
          if !should_ignore_sql_statement?(payload[:name])
            raise SQLPerformedWithinTemplateError.new("A SQL request was issued within the template: \n  #{payload[:sql]}")
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
    end
  end
end