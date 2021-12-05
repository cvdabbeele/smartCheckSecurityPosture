#!/bin/bash
# SmartCheck API docs: https://deep-security.github.io/smartcheck-docs/api/

[[ -z ${DSSC_HOST} ]] && printf "%s\n" "DSSC_HOST was not defined" 
[[ -z ${DSSC_USERNAME} ]] && printf "%s\n" "DSSC_USERNAME was not defined" 
[[ -z ${DSSC_PASSWORD} ]] && printf "%s\n" "DSSC_PASSWORD was not defined" 
[[ -z ${NUMBEROFBATCHES} ]] && printf "%s\n" "NUMBEROFBATCHES was not defined" 
[[ -z ${OUTFILE} ]] && OUTFILE="scanfindings_`date "+%Y%m%d_%H:%M"`"

# Authenticate to SmartCheck and get a bearer token
#---------------------------------------------------
printf "%s\n" "Authenticating to ${DSSC_HOST}"
BEARERTOKEN=$(curl -k -s --location --insecure --request POST ${DSSC_HOST}'/api/sessions' --header 'Content-Type: application/json' --header 'Api-Version: 2018-05-01' --data-raw "{
   \"user\": {   \"userid\": \"${DSSC_USERNAME}\",     \"password\": \"${DSSC_PASSWORD}\"     }
}"  | jq -r ".token")
[[ -z ${BEARERTOKEN} ]] && printf "%s\n"  "FAILED to get BEARERTOKEN"

# Get the last batches of critical scanresults of images
#--------------------------------------------------------
printf "%s\n"  "scandate, image, malware, criticalContents, criticalVulnerabilities, criticalChecklists" > /outvol/${OUTFILE}
NUMBEROFBATCHES=$((${NUMBEROFBATCHES}))  #ensure this is a number
LOOPS=$((${NUMBEROFBATCHES})) 
NEXT="something"
while [ $LOOPS -gt 0 ] && [ ${NEXT} != "null" ];do
  CURRENTBATCH=$((NUMBEROFBATCHES-LOOPS+1))
  printf '%s' "Getting Critical findings, batch ${CURRENTBATCH}"
  SCANIDSRAW=$(curl -s -k --location --request GET ${DSSC_HOST}/api/scans/ \
  --header 'Content-Type: application/json' \
  --header 'Api-Version: 2018-05-01' \
  --header 'Authorization: Bearer'${BEARERTOKEN} | jq -r "")
  NEXT=$(printf "%s\n" "$SCANIDSRAW" | jq -r "try .next")
  SCANIDS=($(printf "%s\n" "${SCANIDSRAW}" | jq -r ".scans[].id"))

  for SCANID in "${SCANIDS[@]}"; do
    printf '%s' "."
    curl -s -k --location --request GET ${DSSC_HOST}/api/scans/${SCANID} \
    --header 'Content-Type: application/json' \
    --header 'Api-Version: 2018-05-01' \
    --header 'Authorization: Bearer'${BEARERTOKEN}  \
    | jq -r ' [.details.completed, .name, .findings.malware, .findings.contents.total.critical,.findings.vulnerabilities.total.critical, .findings.checklists.total.critical ] | @csv'  >>/outvol/${OUTFILE}
  done
  printf '\n'
  ((LOOPS--))
done
cat /outvol/${OUTFILE}
#close /outvol/${OUTFILE} 
