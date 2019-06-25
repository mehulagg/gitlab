# frozen_string_literal: true

require 'sys/proctable'

class HealthController < ActionController::Base
  protect_from_forgery with: :exception, prepend: true
  include RequiresWhitelistedMonitoringClient

  CHECKS = [
    Gitlab::HealthChecks::DbCheck,
    Gitlab::HealthChecks::Redis::RedisCheck,
    Gitlab::HealthChecks::Redis::CacheCheck,
    Gitlab::HealthChecks::Redis::QueuesCheck,
    Gitlab::HealthChecks::Redis::SharedStateCheck,
    Gitlab::HealthChecks::GitalyCheck
  ].freeze

  def readiness
    results = CHECKS.map { |check| [check.name, check.readiness] }

    render_check_results(results)
  end

  def liveness
    results = CHECKS.map { |check| [check.name, check.liveness] }

    render_check_results(results)
  end

  def reload
    signals = []

    workers.map do |worker|
      signals << send_signal(worker, 'SIGTERM')
    end

    render json: {
      ppid: Process.ppid,
      signals: signals
    }
  end

  private

  def send_signal(pid, signal)
    { pid: pid, signal: signal, kill: Process.kill(signal, pid) }
  end

  def workers
    ppid = Process.ppid

    Sys::ProcTable.ps.select do |process|
      process.ppid == ppid
    end.map(&:pid)
  end

  def worker_count_param
    params[:workers].to_i
  end

  def render_check_results(results)
    flattened = results.flat_map do |name, result|
      if result.is_a?(Gitlab::HealthChecks::Result)
        [[name, result]]
      else
        result.map { |r| [name, r] }
      end
    end
    success = flattened.all? { |name, r| r.success }

    response = flattened.map do |name, r|
      info = { status: r.success ? 'ok' : 'failed' }
      info['message'] = r.message if r.message
      info[:labels] = r.labels if r.labels
      [name, info]
    end
    render json: response.to_h, status: success ? :ok : :service_unavailable
  end
end
