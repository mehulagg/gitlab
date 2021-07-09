require_relative "gemscore"
require_relative "scoregem"
require_relative "libdata"
require_relative "utils"
require_relative "rubytoolbox"
require "csv"
require "date"
require "optparse"
require "json"
require 'securerandom'


gem_hash = {}

def write_csv(csv_data)
  CSV.open("dep_scores.csv", "a+") do |csv|
    # p "Wriritng csv"
    # p csv_data
    csv << csv_data
  end
end

def dreport_csvprep()
  headers = ["Name", "Type", "tot_downloads", "reverse_dep_count", "latest_vesion_age(in Months)",
             "latest_release_on", "rel_freq_last_4quater", "score"]
  write_csv(headers)

  all_gems = LibData.all_instances
  all_gems.each do |gem|
    write_csv([gem.name, gem.signals[:lang], gem.signals[:tot_downloads], gem.signals[:reverse_dep_count],
               gem.signals[:latest_vesion_age], gem.signals[:latest_release_on], gem.signals[:rel_freq_last_4quater],
               gem.signals[:score]])
  end
end

def dreport_summary()
  report = {
 version:"14.0.0",
 vulnerabilities: []
  }
  summary = ""
  all_gems = LibData.all_instances
  all_gems.each do |gem|
    if gem.signals[:score].to_i == 0
       summary = summary + "From the following metadata, the thirdparty component "+gem.name \
        + " looks not well maintaned" \
        + ".Total download:" + (gem.signals[:tot_downloads]|| "").to_s \
        + ".Number of reverse dependency:"+  (gem.signals[:reverse_dep_count]|| "").to_s \
        + ".Latest version age:"+ (gem.signals[:latest_vesion_age] || "").to_s \
        + ".Latest release on:"+ (gem.signals[:latest_release_on] || "") \
        + ".Number of releases last year:"+ (gem.signals[:rel_freq_last_4quater]|| "").to_s \
        + ".Score: "+gem.signals[:score].to_s

        # puts summary

        vul_id = SecureRandom.uuid
        vul = {
          id: vul_id,
          category: "dependency_scanning",
          name: "Use of Unmaintained Third Party Components",
          message: "Use of Unmaintained Third Party Components",
          description: summary,
          cve: vul_id,
          severity: "Info",
          solution: "Find an alternate third party library.",
          scanner:{id: "depscore", name: "depscore"},
          location: {file:"Gemfile",dependency:{package:{name:gem.name},version:gem.signals[:version]}},
          identifiers: [{type:"cwe",name:"CWE-1104",value: "Use of Unmaintained Third Party Components",url: "https://cwe.mitre.org/data/definitions/1104.html" }],
          links: [{url: "https://cwe.mitre.org/data/definitions/1104.html"}]
        }
        puts vul.to_json
        report[:vulnerabilities].append(vul)
        summary = ""
    end #if score = 0
  end
  # summary_json = JSON(vul)
  File.open("gl-depscore-report.json", "w") do |f|
    f.write(report.to_json)
  end
end

def dreport_readgems(dependencies)
  puts "[*] Reading all gems"
  # puts dependencies
  count = 0
  dependencies.each do |lib|
    count += 1
    name = lib["package"]["name"]
    version = lib["version"]
    LibData.new(name, { version: version, lang: "ruby" })
  end
  puts "[*] Total gems = #{count}"
  # utils = Utils.new
  # utils.debug_libdata
end

def dreport_read(dreport_path)
  if (!File.exist?(dreport_path))
    puts "Gemfile #{dreport_path} do not exist."
    exit(0)
  end

  puts "[*] File #{dreport_path} found "

  #  # Read json file
  file = File.read(dreport_path)
  data_hash = JSON.parse(file)

  #  # Get all dependencies

  #  # Get gems
  data_hash["dependency_files"].each do |dep_file|
    puts dep_file["path"]
    if dep_file["path"] == "Gemfile.lock"
      dreport_readgems(dep_file["dependencies"])
      rubytoolbox = RubyToolbox.new
      rubytoolbox.fetch_metadata
      # utils = Utils.new
      # utils.debug_libdata
      dreport_csvprep()
      dreport_summary()
    end
  end
end

def gofor_gemfile
  gemscore = GemScore.new
  gems_from_gemfile = gemscore.read_gemfile("Gemfile")
  headers = ["Name", "Type", "tot_downloads", "revdep_count", "latest_vesion_age(in Months)", "Reecent releases", "score"]
  write_csv(headers)
  count = 0
  tot_gems = gems_from_gemfile.length
  start_time = Time.now
  gems_from_gemfile.each do |gem_name, version|
    # puts gem_name
    time_elapsed = (Time.now - start_time).to_i
    print "\r\e[32m [*] Gems evaluated #{count += 1}/#{tot_gems}. Time elapsed #{time_elapsed} seconds\e[0m"
    gem_metadata = gemscore.get_gem_info(gem_name)
    if gem_metadata.nil?
      puts "The score = Nil"
    else
      gem_metadata[:score] = gemscore.compute_score(gem_metadata)
      gem_metadata[:name] = gem_name
      gem_metadata[:type] = "ruby-gem"
      # puts gem_metadata
      write_csv([gem_metadata[:name], gem_metadata[:type], gem_metadata[:tot_downloads], gem_metadata[:revdep_count], gem_metadata[:latest_vesion_age], gem_metadata[:release_feq_1yer], gem_metadata[:score]])
    end
  end
  p "."
  p "Scores written to csv file"
end

def gofor_gem
  gemscore = GemScore.new
  ARGV.count == 2 ? gem_name = ARGV[1] : (p "Gemname is not supplied"; exit(0))
  # puts gem_name
  gem_metadata = gemscore.get_gem_info(gem_name)
  if gem_metadata.nil?
    puts "The score = Nil"
  else
    gemscore.compute_score(gem_metadata)
  end
end

# This will hold the options we parse
options = {}

OptionParser.new do |parser|
  parser.banner = "Usage: hello.rb [options]"

  parser.on("-h", "--help", "Show this help message") do
    puts parser
  end

  parser.on("-g=s", "--gemfile", "Gemfile path") do |v|
    options[:gemfile] = v
  end

  parser.on("-d=s", "--dreport", "Dependency scan report path") do |v|
    options[:dreport] = v
  end
end.parse!

# Now we can use the options hash however we like.
puts "Look for gemfile" if options[:gemfile]
dreport_read(options[:dreport]) if options[:dreport]
