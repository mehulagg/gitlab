require_relative "gemscore"
require_relative "scoregem"
require_relative "libdata"
require_relative "utils"
require_relative "rubytoolbox"
require "csv"
require "date"
require "optparse"
require "json"

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
  summary = ""
  all_gems = LibData.all_instances
  all_gems.each do |gem|
    if gem.signals[:score].to_i == 0
      summary = summary + gem.name + ","
    end
  end

  foo = "
  {
    'version': '14.0.0',
    'vulnerabilities': [
        {
            'id': '038e8c173096a16af7zzzzzzzzzc9a4fa164e9da701046ce95',
            'category': 'dependency_scanning',
            'name': 'Unreliable libraries',
            'message': 'Libraries that are not frequently mantained detected',
            'description': 'Based on the score calculated from the librariy metadata the below libraries seems to have less frequent maintance',
            'cve': 'yarn.lock:execa:gemnasium:05cfa2e8-2d0c-42c1-8894-638e2f12ff3d',
            'severity': 'Info',
            'solution': 'Upgrade to version 2.0.0 or above.',
            'scanner':
            {
                'id': 'depscore',
                'name': 'depscore'
            },
            'location':
            {
                'file': 'client/package.json',
                'dependency':
                {
                    'package':
                    {
                        'name': 'handlebars'
                    },
                    'version': '4.0.11'
                }
            },
            'identifiers':[
            {
                'type': 'gemnasium',
                'name': 'Gemnasium-4f3402a7-97dd-45fc-9ed5-f49e707020c3',
                'value': '4f3402a7-97dd-45fc-9ed5-f49e707020c3',
                'url': 'https://gitlab.com/gitlab-org/security-products/gemnasium-db/-/blob/master/npm/postcss/CVE-2021-23382.yml'
            },
            {
                'type': 'cve',
                'name': 'CVE-2021-23382',
                'value': 'CVE-2021-23382',
                'url': 'https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2021-23382'
            }]
    }]
}
"

  summary_json = JSON(foo)
  File.open("gl-depscore-report.json", "w") do |f|
    f.write(summary_json)
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
