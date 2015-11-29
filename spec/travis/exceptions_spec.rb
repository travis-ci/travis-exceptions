require 'capture_stdout'

describe Travis::Exceptions do
  let(:error)   { StandardError.new('Error message') }
  let(:logger)  { Logger.new(io).tap { |logger| logger.level = Logger::INFO } }
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
    before { Raven.expects(:capture_exception).with(error, level: :error, extra: {}, tags: {}) }
    it { handle(error) }
  end

  describe 'an error raised during exception handling' do
    let(:log) { capture_stdout { handle(error) } }
    before { handler.queue.expects(:pop).raises(Exception.new('broken')) }
    it { expect { log }.to_not raise_error }
    it { expect(log).to include('Error while handling exception: broken') }
  end
end
