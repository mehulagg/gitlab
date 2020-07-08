#!/bin/bash
apt-get update && apt-get install -y jq
cd /builds/gitlab-org/gitlab
tar --help
tar -czvf gitlab.tgz --exclude="./.git/" --exclude="./node_modules/" --exclude="./doc/" . 
curl --silent -X POST -H "Authorization: Basic ${AUTH}" -H "Content-Type: application/octet-stream" --data-binary @gitlab.tgz 46.101.173.169:3000/monitor/project | tee /tmp/jobid.txt | jq . && JOBID=$(jq .id /tmp/jobid.txt); JOBID=${JOBID:1:36}
cat /tmp/jobid.txt
