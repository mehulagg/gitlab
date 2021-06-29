#! /usr/bin/env ruby
require "httparty"
require "json"
require "date"
require_relative "libdata"

class GemScore
  def initialize
    @weights = {
      tot_downloads: 0.5,
      revdep_count: 1,
      latest_vesion_age: -2,
      release_feq_1yer: 1,

    }
    @threashold = {
      tot_downloads: 100000,
      revdep_count: 100,
      latest_vesion_age: 24,
      release_feq_1yer: 12,
    }
    # @gem_data = LibData.new
    @from_gemfile = Hash.new
    $lio_access_token = ENV["lio_access_token"]
  end

  def make_request(url, headers = {})
    # print "Sending request to #{url}"
    response = HTTParty.get(url, headers)
    # puts " - Response: #{response.code}"
    return response
  end

  def get_gem_info(gem_name)
    baseinfo_query_res = make_request("https://rubygems.org/api/v1/gems/#{gem_name}.json")
    baseinfo_query_res.code == 404 ? (puts "Gem #{gem_name} not found at rubygems.org"; return nil) :
      baseinfo = JSON.parse(baseinfo_query_res.body)
    # p baseinfo
    revdep_query_res = make_request("https://rubygems.org/api/v1/gems/#{gem_name}/reverse_dependencies.json")
    revdep = JSON.parse(revdep_query_res.body)
    gem_query_res = make_request("https://libraries.io/api/Rubygems/#{gem_name}?api_key=#{$lio_access_token}")
    gem_query_res.code == 404 ? (puts "Gem #{gem_name} not found at Librarie.io"; return nil) :
      gem_info = JSON.parse(gem_query_res.body)
    # puts gem_info

    # latest_release_date = Date.parse(gem_info["latest_release_published_at"])
    latest_release_date = Date.parse(baseinfo["version_created_at"])
    latest_vesion_age = (Date.today - latest_release_date).to_i / 30 #Signal -> in months

    release_feq_1yer = 0 # Releases in last 365 days
    if (Date.today - latest_release_date).to_i <= 365
      ver_details = gem_info["versions"]
      ver_details.each do |ver_details|
        (Date.today - Date.parse(ver_details["published_at"])).to_i <= 365 ? release_feq_1yer += 1 : (next)
      end
    end

    repository_url = gem_info["repository_url"]

    # gem_info["repository_url"].nil? ? (puts "! repository_url not found") : (gh_owner_proj.slice! "https://github.com/")
    # proj_query_res = make_request("https://libraries.io/api/github/#{gh_owner_proj}?api_key=#{$lio_access_token}")
    # proj_query_res.code == 404? (puts "Project https://github.com/#{gh_owner_proj} not found"; exit(0)):
    # proj_info = JSON.parse(proj_query_res.body)

    tot_downloads = baseinfo["downloads"].to_i #singnal
    revdep_count = revdep.count #signal
    # print "# #{gem_name}: 
    #   |-Latest release age: #{latest_vesion_age} months
    #   |-Latest release date: #{latest_release_date}
    #   |-Recent releases: #{release_feq_1yer}
    #   |-repository_url: #{repository_url}
    #   |-tot_downloads:#{tot_downloads}
    #   |-revdep_count:#{revdep_count}\r"

    gem_metadata = {
      tot_downloads: tot_downloads,
      revdep_count: revdep_count,
      latest_vesion_age: latest_vesion_age,
      release_feq_1yer: release_feq_1yer,
    }
    return gem_metadata
  end

  def compute_score(signals)
    inside = 0.0
    outside = 0.0
    score = 0.0

    signals.each do |signal, value|
      # puts "Singal: #{signal} Value: #{value}"
      threashold = @threashold[signal]
      # puts threashold
      weight = @weights[signal]
      # puts weight
      inside += (Math.log(1 + value) / Math.log(1 + [value, threashold].max)) * weight
    end

    @weights.each do |weight, value|
      outside += value
    end

    score = (1 / outside) * inside
    final_score = ([[score, 1].min, 0].max).round(1)
    # puts "The score = #{final_score}"
    return final_score
  end

  def read_gemfile(file_path)

    #check if file exist -> switch to conditional operator
    if !File.exist?(file_path)
      puts "Gemfile #{file_path} do not exist."
      exit(0)
    end

    File.open(file_path, "r") do |f|
      f.each_line do |line|
        # gem 'concurrent-ruby', '~> 1.1'
        line = line.strip
        if (line =~ /^gem(.*)/) # =~ is Ruby's basic pattern-matching operator.
          line.tr!('"', "'") # some have " instead of '
          gem_name = line.scan(/'[a-zA-Z0-9\-_]+'/) # escape -, get gemname
          # gem_version = line.scan(/'~>\s*[0-9.]+'/) # get everything between singe quotes
          # gem_version = line.scan(/'~>\s*[0-9.]+'/)
          # if (line.includes("="))
          #   puts "Found ="
          # elsif (line.include(~))
          gem_version = "latest"

          # puts "Gem #{gem_name[0]} ver #{gem_version}"
          @from_gemfile[gem_name[0].tr("'", "")] = gem_version
        end
      end
    end

    return @from_gemfile
  end
end
