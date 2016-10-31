require 'spec_helper'

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
end
