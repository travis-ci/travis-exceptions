# frozen_string_literal: true

require 'capture_stdout'
require 'travis/logger'
require 'travis/exceptions'

describe Travis::Exceptions do
  let(:error)   { StandardError.new('Error message') }
  let(:logger)  { Travis::Logger.new(io).tap { |logger| logger.level = Logger::INFO } }
  let(:io)      { StringIO.new }
  let(:log)     { io.string }
  let(:env)     { 'production' }
  let(:config)  { {} }
  let(:handler) { described_class.new(config, env, logger) }

  def handle(error)
    handler.handle(error)
    handler.send(:process)
  end

  describe 'without a sentry dsn' do
    before { handle(error) }

    it { expect(log).to include('Error message') }
  end

  describe 'with a sentry dsn' do
    let(:config) { { sentry: { dsn: 'dsn' } } }

    before { allow(Raven).to receive(:capture_exception).with(error, level: :error, extra: {}, tags: {}) }

    it { handle(error) }
  end

  describe 'an error raised during exception handling' do
    let(:log) { capture_stdout { handle(error) } }

    before { allow(handler.queue).to receive(:pop).and_raise(Exception.new('broken')) }

    it { expect { log }.not_to raise_error }
    it { expect(log).to include('Error while handling exception: broken') }
  end
end
