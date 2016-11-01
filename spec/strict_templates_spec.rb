require 'spec_helper'
require 'ostruct'

describe StrictTemplates do
  let(:test_class) { Struct.new(:name) { include StrictTemplates::Concern } }
  let(:test_instance) { test_class.new }

  it 'has a version number' do
    expect(StrictTemplates::VERSION).not_to be nil
  end

  it 'responds to #render' do
    expect(test_instance).to respond_to(:render).with_unlimited_arguments
  end

  it 'raises SQLPerformedWithinTemplateError' do
    allow(ActiveSupport::Notifications).to receive(:subscribed) do |callback, namespace|
      callback.call(namespace, Time.now - 1, Time.now, SecureRandom.hex(10), { name: 'Post Load' })
    end

    expect{
      test_instance.render
    }.to raise_error(StrictTemplates::SQLPerformedWithinTemplateError)
  end

  it 'does not raise an error when config.strict_templates.raise_on_queries == false' do
    strict_templates_config = OpenStruct.new(raise_on_queries: false)
    rails_config = double('Rails::Application::Configuration', strict_templates: strict_templates_config)
    allow(test_instance).to receive(:config).and_return(rails_config)
    expect(test_instance).to receive(:render)

    allow(ActiveSupport::Notifications).to receive(:subscribed) do |callback, namespace|
      callback.call(namespace, Time.now - 1, Time.now, SecureRandom.hex(10), { name: 'Post Load' })
    end

    expect{
      test_instance.render
    }.not_to raise_error
  end

  it 'raises an error when config.strict_templates.raise_on_queries is falsy but not explicitly false' do
    strict_templates_config = OpenStruct.new(raise_on_queries: nil)
    rails_config = double('Rails::Application::Configuration', strict_templates: strict_templates_config)
    allow(test_instance).to receive(:config).and_return(rails_config)

    allow(ActiveSupport::Notifications).to receive(:subscribed) do |callback, namespace|
      callback.call(namespace, Time.now - 1, Time.now, SecureRandom.hex(10), { name: 'Post Load' })
    end

    expect{
      test_instance.render
    }.to raise_error(StrictTemplates::SQLPerformedWithinTemplateError)
  end

  it 'does not raise an error but instead calls a custom callback' do
    custom_callback = double
    expect(custom_callback).to receive(:call).with(an_instance_of(Hash))

    strict_templates_config = OpenStruct.new(error_handler: custom_callback)
    rails_config = double('Rails::Application::Configuration', strict_templates: strict_templates_config)
    allow(test_instance).to receive(:config).and_return(rails_config)

    allow(ActiveSupport::Notifications).to receive(:subscribed) do |callback, namespace|
      callback.call(namespace, Time.now - 1, Time.now, SecureRandom.hex(10), { name: 'Post Load' })
    end

    expect{
      test_instance.render
    }.not_to raise_error
  end
end
