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
         "severity":"Info",
         "solution":"Check for alternate libraries",
         "scanner":{
            "id":"depscore",
            "name":"depscore"
         },
         "location":{
            "file":"client/package.json",
            "dependency":{
               "package":{
                  "name":"handlebars,handlebars,handlebars,handlebars,handlebars,handlebars,handlebars,handlebars,handlebars,handlebars,handlebars,handlebars,handlebars"
               }
            }
         },
         "identifiers":[
           
         ]
      }
   ]
}
'

  summary_json = JSON(foo)
  File.open("gl-depscore-report.json", "w") do |f|
    f.write(summary_json.to_json)
  end
