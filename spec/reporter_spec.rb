require 'capture_stdout'
require 'stringio'
require 'logger'

describe Travis::Exceptions::Reporter do
  let(:error)    { StandardError.new('Error message') }
  let(:io)       { StringIO.new }
  let(:logger)   { Logger.new(io).tap { |logger| logger.level = Logger::INFO } }
  let(:log)      { io.string }
  let(:env)      { 'production' }
  let(:config)   { {} }
  let(:reporter) { described_class.new(config, env, logger) }

  def handle_error
    reporter.handle(error)
    reporter.send(:process)
  end

  describe 'without a sentry dsn' do
    before { handle_error }
    it { expect(log).to include('Error message') }
  end

  describe 'with a sentry dsn' do
    let(:config) { { sentry: { dsn: 'dsn' } } }
    before { Raven.expects(:capture_exception).with(error, extra: {}, tags: {}) }
    it { handle_error }
  end

  describe 'an error raised during exception handling' do
    let(:log) { capture_stdout { handle_error } }
    before { reporter.queue.expects(:pop).raises(Exception.new('broken')) }
    it { expect { log }.to_not raise_error }
    it { expect(log).to include('Error while handling exception: broken') }
  end
end

