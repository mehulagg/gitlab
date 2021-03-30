# frozen_string_literal: true

require 'spec_helper'

describe Mail::SMTPPool do
  let(:mail) do
    Mail.new do
      from    'mikel@test.lindsaar.net'
      to      'you@test.lindsaar.net'
      subject 'This is a test email'
      body    'Test body'
    end
  end

  it 'sets the default pool settings' do
    smtp_pool = described_class.new({})

    expect(ConnectionPool).to receive(:new).with(hash_including(size: 5, timeout: 5)).once.and_call_original

    smtp_pool.deliver!(mail)
    smtp_pool.finish
  end

  it 'allows overriding pool size and timeout' do
    smtp_pool = described_class.new(pool_size: 3, pool_timeout: 2)

    expect(ConnectionPool).to receive(:new).with(hash_including(size: 3, timeout: 2)).once.and_call_original

    smtp_pool.deliver!(mail)
    smtp_pool.finish
  end

  it 'reuses the same pool when instantiated with the same settings' do
    smtp_pool = described_class.new({})
    smtp_pool_2 = described_class.new({})

    expect(ConnectionPool).to receive(:new).once.and_call_original

    smtp_pool.deliver!(mail)
    smtp_pool_2.deliver!(mail)

    smtp_pool.finish
  end

  it 'creates another pool when the settings are different' do
    smtp_pool = described_class.new({})
    smtp_pool_2 = described_class.new(address: 'smtp.example.com')

    expect(ConnectionPool).to receive(:new).twice.and_call_original

    smtp_pool.deliver!(mail)
    smtp_pool_2.deliver!(mail)

    smtp_pool.finish
    smtp_pool_2.finish
  end

  it 'creates an SMTP connection with the correct settings' do
    settings = { address: 'smtp.example.com', port: '465' }
    smtp_pool = described_class.new(settings)

    expect(Mail::SMTPPool::Connection).to receive(:new).with(settings).once.and_call_original

    smtp_pool.deliver!(mail)
    smtp_pool.finish
  end
end
