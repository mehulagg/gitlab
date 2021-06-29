require "httparty"
require_relative "libdata"

class Utils
  def api_request(url, headers = {})
    begin
      hostname = (url.match /https:\/\/[a-z0-9.-]*\//)[0]
      puts "[*] Sending API request to: #{hostname}"
      # print "Sending request to #{url}"
      response = HTTParty.get(url, headers)
      puts "[*] Response code received: #{response.code}"
    rescue => error
      puts "\n[!] Error while doing API request"
      puts "> Error: #{error.message}"
      puts "> Request url #{url} headers #{headers}"
      puts "> Response code: #{response.code}\n"
    end
    return response
  end

  def debug_libdata()
    all_gems = LibData.all_instances
    # puts   "#{all_gems.class}"
    # # lib = LibData.new

    # lib = all_gems.select { |gem| gem.name == "actionmailbox" }
    # lib[0].signals[:version] = 999
    # puts "#{lib[0].signals[:version]}"

    # all_gems_new = LibData.all_instances
    # lib_new = all_gems_new.select { |gem| gem.name == "actionmailbox" }
    # puts "#{lib_new[0].signals[:version]}"

    # puts lib_new[0].signals.class 
      
  



    puts "Number of gems: #{all_gems.count}"
    all_gems.each do |gem|
      puts "Name: #{gem.name}"
      puts "#{gem.signals}"
      # puts "#{gem.signals[:tot_downloads]}" if gem.signals[:tot_downloads]
      # puts "#{gem.signals[:reverse_dep_count]}" if gem.signals[:reverse_dep_count]
      # puts "#{gem.signals[:latest_vesion_age]}" if gem.signals[:latest_vesion_age]
      # puts "#{gem.signals[:version]}" if gem.signals[:version]
      # puts "#{gem.signals[:lang]}" if gem.signals[:lang]
      # puts "#{gem.signals[:score]}" if gem.signals[:score]

      puts "----"
    end
  end
end
