module StrictTemplates
  class Railtie < Rails::Railtie
    initializer 'strict_templates.register_events' do
      collector = StrictTemplates::Collector.new

      event_keys = [
        'start_processing.action_controller',
        'process_action.action_controller',
        'render_template.action_view',
        'start.action_view',
        'render_partial.action_view',
        'sql.active_record',
        'instantiation.active_record'
      ]

      event_keys.each do |key|
        ActiveSupport::Notifications.subscribe(key) do |*args|
          event = ActiveSupport::Notifications::Event.new(*args)
          collector.log_event(event)
        end
      end
    end
  end
end
