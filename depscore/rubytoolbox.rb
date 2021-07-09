require_relative "libdata"
require_relative "score"

class RubyToolbox
  def initialize
    @apirul = "https://www.ruby-toolbox.com/api/projects/compare/"
  end

  def parse_api_response(response)
    begin
      if response.code != 200
        puts "[!] Something is wrong, got resposne code #{response.code}"
      end
      res_gem_info = JSON.parse(response.body)

      score = Score.new

      all_deps = LibData.all_instances
      # populate libdata object with data from the api resposne
      res_gem_info["projects"].each do |gem|
        dep = all_deps.select { |dep| dep.name == gem["rubygem"]["name"] }
        # .select retuns an array
        # dep is an array with length 1
        # to access stuff inside dep use dep[0]
        dep[0].signals[:latest_release_on] = gem["rubygem"]["latest_release_on"]
        dep[0].signals[:tot_downloads] = gem["rubygem"]["stats"]["downloads"].to_i
        dep[0].signals[:reverse_dep_count] = gem["rubygem"]["stats"]["reverse_dependencies_count"].to_i
        dep[0].signals[:latest_vesion_age] = ((Date.today - Date.parse(gem["rubygem"]["latest_release_on"])) / 30).to_f.round(2) #Signal -> in months

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
        dep[0].signals[:rel_freq_last_4quater] = release_count
        # puts dep[0].signals.to_h
        dep[0].signals[:score] = score.compute_score(dep[0].signals.to_h)
        # puts "Score = #{dep[0].signals[:score]}"
        # utils = Utils.new
        # utils.debug_libdata
      end
    rescue => exception
      puts "\n[!] Error processing api response from response www.ruby-toolbox.com."
      puts "> Error: #{exception.message} #{exception.backtrace}"
      puts "> Response code: #{response.code}"
      # puts "> Response from api request: \n #{response}\n"
    end
  end # endof parse_api_response()

  def fetch_metadata
    puts "[*] Fetching gem metadata from rubytoolbox"
    # read libdata obj
    all_gems = LibData.all_instances
    gem_counter = 0
    gem_list = ""
    res = ""
    # construct batch of 100 comma seperated libs
    all_gems.each do |gem|
      gem_counter += 1
      if (gem_counter <= 100)
        gem_list = gem_list + gem.name + ","
      else
        res = send_req (gem_list)
        parse_api_response(res)
        gem_list = ""
        gem_counter = 0
      end
    end
    if gem_list != ""
      res = send_req (gem_list)
      parse_api_response(res)
    end

    # invoke the rubytool api with the batch
    # read the result back
    # add to libdata obj
  end

  def send_req(gem_list)
    gem_list = gem_list.chomp(",")
    req_url = @apirul + gem_list
    utils = Utils.new
    utils.api_request(req_url)
  end
end
