require "json"  
  summary = ""
  # all_gems = LibData.all_instances
  # all_gems.each do |gem|
  #   if gem.signals[:score].to_i == 0
  #     summary = summary + gem.name + ","
  #   end
  # end

  foo = '{"version":"14.0.0",
  "vulnerabilities":[{
         "id":"038e8c173096a16af7zzzzzzzzzc9a4fa164e9da701046ce95",
         "category":"dependency_scanning",
         "name":"Unreliable libraries",
         "message":"Libraries that are not frequently mantained detected",
         "description":"Based on the score calculated from the librariy metadata the below libraries seems to have less frequent maintance",
         "cve":"yarn.lock:execa:gemnasium:05cfa2e8-2d0c-42c1-8894-638e2f12ff3d",
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
               "type":"gemnasium",
               "name":"Gemnasium-4f3402a7-97dd-45fc-9ed5-f49e707020c3",
               "value":"4f3402a7-97dd-45fc-9ed5-f49e707020c3",
               "url":"https://gitlab.com/gitlab-org/security-products/gemnasium-db/-/blob/master/npm/postcss/CVE-2021-23382.yml"
            },
            {
               "type":"cve",
               "name":"CVE-2021-23382",
               "value":"CVE-2021-23382",
               "url":"https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2021-23382"
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
