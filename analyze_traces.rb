require 'json'
require 'net/http'

PIPELINE_ID = 
MARKER = '-+-' * 20
OCCURANCES = Hash.new { |hash, key| hash[key] = 0 }

def analyze_trace(id)
  uri = URI("https://gitlab.com/gitlab-org/gitlab-ee/-/jobs/#{id}/raw")
  trace = Net::HTTP.get(uri)

  left_index = trace.index(MARKER)
  right_index = trace.rindex(MARKER)

  # Filter out jobs we dont need
  return unless left_index && right_index

  trace = trace[left_index..right_index]

  lines = trace.lines.select { |l| l.start_with?('/builds/gitlab-org/gitlab-ee') }

  # Call stack had 3 lines
  lines.each_slice(3) { |slice| OCCURANCES[slice] += 1 }

  puts id
  puts
end

def job_ids
end

JOB_IDS.map { |id| analyze_trace(id) }

OCCURANCES.sort_by { |_, v| v }.each do |trace, count|
  puts trace
  puts "Occured #{count} times"
  puts
end
