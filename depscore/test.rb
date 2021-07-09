require "json"  
require 'securerandom'

  summary = ""
  # all_gems = LibData.all_instances
  # all_gems.each do |gem|
  #   if gem.signals[:score].to_i == 0
  #     summary = summary + gem.name + ","
  #   end
  # end

#   foo = '{"version":"14.0.0",
#   "vulnerabilities":[{
#          "id":"038e8c1296a16af7zzzzzzzzzc9a4fa164e9da70123sd6ce95",
#          "category":"dependency_scanning",
#          "name":"Unreliable libraries",
#          "message":"Libraries that are not frequently mantained detected",
#          "description":"Based on the score calculated from the librariy metadata the below libraries seems to have less frequent maintance",
#          "cve":"038e8c1296a16af7zzzzzzzzzc9a4fa164e9da70123sd6ce95",
#          "severity":"Info",
#          "solution":"Upgrade to version 2.0.0 or above.",
#          "scanner":{
#             "id":"depscore",
#             "name":"depscore"
#          },
#          "location":{
#             "file":"package.json",
#             "dependency":{
#                "package":{
#                   "name":"handlebars"
#                },
#                "version":"4.0.11"
#             }
#          },
#          "identifiers":[
#             {
#                "type":"cwe",
#                "name":"CWE-1104",
#                "value":"Use of Unmaintained Third Party Components",
#                "url":"https://cwe.mitre.org/data/definitions/1104.html"
#             }
#          ],
#          "links": [
#         {
#           "url": "https://cwe.mitre.org/data/definitions/1104.html"
#         }
#       ]

#       }
#    ]
# }
# '

foo = '{"version":"14.0.0",
"vulnerabilities":[{
    "id": "222d333f-3500-4139-a304-3005df76588d",
    "category": "dependency_scanning",
    "name": "Use of Unmaintained Third Party Components",
    "message": "Use of Unmaintained Third Party Components",
    "description": "From the following metadata, the thirdparty component zeitwerk looks not well maintaned.Total download:64645105.Number of reverse dependency:193.Latest version age:7.47.Latest release on:2020-11-27.Number of releases last year:3.Score: 0.3",
    "cve": "222d333f-3500-4139-a304-3005df76588d",
    "severity": "Info",
    "solution": "Find an alternate third party library.",
    "scanner":
    {
        "id": "depscore",
        "name": "depscore"
    },
    "location":
    {
        "file": "Gemfile",
        "dependency":
        {
            "package":
            {
                "name": "zeitwerk"
            },
            "version": "2.4.2"
        }
    },
    "identifiers": [
    {
        "type": "cwe",
        "name": "CWE-1104",
        "value": "Use of Unmaintained Third Party Components",
        "url": "https://cwe.mitre.org/data/definitions/1104.html"
    }],
    "links": [
    {
        "url": "https://cwe.mitre.org/data/definitions/1104.html"
    }]
}]}'

  summary_json = JSON(foo)
  File.open("gl-depscore-report.json", "w") do |f|
    f.write(summary_json.to_json)
  end
  exit(0)
