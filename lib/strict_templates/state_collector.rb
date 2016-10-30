# Each StateCollector instance should only exist for the duration of the request
# The class methods provide a thread-safe manner for instantiating and tracking
# the different in-flight requests.
module StrictTemplates
  class StateCollector
    @collectors = Concurrent::Hash.new

    def self.create(transaction_id)
      @collectors[transaction_id] ||= self.new(transaction_id)
    end

    def self.fetch(transaction_id)
      @collectors[transaction_id]
    end

    def self.destroy(transaction_id)
      @collectors.delete(transaction_id)
    end

    def initialize(transaction_id)
      @transaction_id = transaction_id
      @templates = {}
    end

    def begin_template(template_id)
      @templates[template_id] = true
    end

    def end_template(template_id)
      @templates.delete(template_id)
    end

    def rendering_template?
      @templates && @templates.keys.size > 0
    end

    def current_template
      @templates && @templates.keys.first
    end
  end
end