require "bundler"
require_relative "libdata"
require_relative "utils"
# require_relative "computescore"
require "date"

class ScoreGem
  def parse_api_response(response)
    begin
      if response.code != 200
        puts "[!] Something is wrong, got resposne code #{response.code}"
      end
      res_gem_info = JSON.parse(response.body)

      cal_score = ComputeScore.new

      # populate libdata object with data from the api resposne
      res_gem_info["projects"].each do |gem|
        gem_obj = LibData.new
        gem_obj.signals = {}
        gem_obj.signals[:name] = gem["rubygem"]["name"]
        gem_obj.signals[:latest_release_on] = gem["rubygem"]["latest_release_on"]
        gem_obj.signals[:tot_downloads] = gem["rubygem"]["stats"]["downloads"].to_i
        gem_obj.signals[:reverse_dep_count] = gem["rubygem"]["stats"]["reverse_dependencies_count"].to_i
        gem_obj.signals[:latest_vesion_age] = (Date.today - Date.parse(gem["rubygem"]["latest_release_on"])) / 30 #Signal -> in months

        # cal number of release in past 4 quarter, ignore current quarter
        quarterly_release_counts = gem["rubygem"]["stats"]["quarterly_release_counts"]
        release_count = 0
        current_quarter = (Date.today.month / 3.0).ceil
        current_quarter -= 1 #ignore current quarter
        # puts "Current quarter #{current_quarter}"
        if current_quarter < 4
          past_yer_quaters = 4 - current_quarter
          past_yer_quaters.times do |count|
            # puts "#{Date.today.year - 1}-#{4 - count}"
            release_count += quarterly_release_counts["#{Date.today.year - 1}-#{4 - count}"].to_i
          end
          current_quarter.downto(1) do |count|
            # puts "#{Date.today.year}-#{count}"
            release_count += quarterly_release_counts["#{Date.today.year}-#{count}"].to_i
          end
        end
        gem_obj.signals[:rel_freq_last_4quater] = release_count
        puts gem_obj.signals
        gem_obj.signals[:score] = cal_score.score_lib(gem_obj.signals)
        puts "Signal = #{gem_obj.signals}"
      end
    rescue => exception
      puts "\n[!] Error processing api response from response www.ruby-toolbox.com."
      puts "> Error: #{exception.message} #{exception.backtrace}"
      puts "> Response code: #{response.code}"
      # puts "> Response from api request: \n #{response}\n"
    end
  end # endof parse_api_response()

  def read_gem_lock
    begin
      # inspect Gemfile.lock https://gist.github.com/flavio/1722530
      lockfile = Bundler::LockfileParser.new(Bundler.read_file("test-files/Gemfile.lock"))
      gem_counter = 0
      gem_names = ""
      base_api_url = "https://www.ruby-toolbox.com/api/projects/compare/"
      req_url = base_api_url
      lockfile.specs.each do |gem|
        gem_counter += 1
        #puts "#{s.name}-#{s.version.to_s}"
        #concat the gems to batch of 100, api can take only 100 gems per request
        if gem_counter < 100 && !(gem.equal? lockfile.specs.last)
          # Adding gems to the batch. There are more gems in Gemfile and batch size is less than 100
          req_url = req_url + gem.name + ","
        elsif (gem.equal? lockfile.specs.last)
          # Reached the end of gemfile, and can't make a batch of 100 gems. Gonna send req with current list of gems
          req_url = req_url + gem.name
          req_url.chomp!(",")
          utils = Utils.new
          parse_api_response(utils.api_request(req_url))
        else
          # Batch size is now 100. Gonna send req with 100 gems
          req_url.chomp!(",")
          # make request # process response
          utils = Utils.new
          parse_api_response(utils.api_request(req_url))
          # prep next batch
          # puts "Before reset #{gem_counter}"
          gem_counter = 1
          # puts "After reset #{gem_counter}"
          req_url = base_api_url
          req_url = req_url + gem.name + ","
        end
      end # finish reading the gemfile
    rescue => exception
      puts "\n[!] Error in fetching gem details"
      puts "> Error: #{exception.message}"
      puts "> Request url: #{req_url}\n"
      return nil
    end
  end #endof read_gem_lock()
end #class end
