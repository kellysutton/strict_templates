require 'active_support/subscriber'

module StrictTemplates
  class SqlExecutedWithTemplateError < StandardError; end

  class Subscriber < ActiveSupport::Subscriber
    def sql(event)
      # noop but required for #start and #finish to receive events
    end

    def instantiation(event)
      # noop but required for #start and #finish to receive events
    end

    def render_template(event)
      StateCollector.fetch(event.transaction_id).end_template(event.payload[:identifier])
    end

    def start(name, id, payload)
      StateCollector.create(id)

      if name == 'render_template.action_view'
        StateCollector.fetch(id).begin_template(payload[:identifier])
      elsif name == 'sql.active_record'
        if StateCollector.fetch(id)&.rendering_template? && !ignore_sql_payload?(payload)
          raise SqlExecutedWithTemplateError.new("A SQL statement was executed within #{StateCollector.fetch(event.transaction_id).current_template}")
        end
      end

      super
    end

    def process_action(event)
      # noop but required for #start and #finish to receive events
    end

    def finish(name, id, payload)
      if name == 'process_action.action_controller'
        StateCollector.destroy(id)
      end

      super
    end

    private

    def ignore_sql_payload?(payload)
      payload[:name] == 'SCHEMA' ||
        payload[:name] == 'ActiveRecord::SchemaMigration Load'
    end
  end
end

StrictTemplates::Subscriber.attach_to :active_record
StrictTemplates::Subscriber.attach_to :action_view
StrictTemplates::Subscriber.attach_to :action_controller