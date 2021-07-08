require "json"  
require 'securerandom'

  summary = ""
  # all_gems = LibData.all_instances
  # all_gems.each do |gem|
  #   if gem.signals[:score].to_i == 0
  #     summary = summary + gem.name + ","
  #   end
  # end

  foo = '{"version":"14.0.0",
  "vulnerabilities":[{
         "id":"038e8cggg96a16af7zzz12dfdhhzzzc9a4fa164e9da70123sd6ce95",
         "category":"dependency_scanning",
         "name":"Unreliable libraries",
         "message":"Libraries that are not frequently mantained detected",
         "description":"Based on the score calculated from the librariy metadata the below libraries seems to have less frequent maintance",
         "severity":"Info",
         "solution":"Upgrade to version 2.0.0 or above.",
         "scanner":{
            "id":"depscore",
            "name":"depscore"
         },
         "location":{
            "file":"client/package.json",
            "dependency":{
               "package":{
                  "name":"handlebars"
               },
               "version":"4.0.11"
            }
         },
         "identifiers":[
            {
               "type":"cwe",
               "name":"CWE-1104",
               "value":"Use of Unmaintained Third Party Components",
               "url":"https://cwe.mitre.org/data/definitions/1104.html"
            }
         ]
      }
   ]
}
'

  summary_json = JSON(foo)
  File.open("gl-depscore-report.json", "w") do |f|
    f.write(summary_json.to_json)
  end
  exit(0)
