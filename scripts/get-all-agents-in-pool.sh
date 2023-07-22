#!/bin/bash

# bash "safe" options
#set -eu
# Pre-req: the "Project Collection build service (org_name)" account must be granted "reader" role to the particular Agent pool.
while getopts p: flag; do
  case "${flag}" in
  p) pool_name=${OPTARG} ;;
  esac
done
sys_token_length=${#SYSTEM_ACCESSTOKEN}
echo "SYSTEM_ACCESSTOKEN length is $sys_token_length"
#token=$(echo -n ":$SYSTEM_ACCESSTOKEN" | base64)
#converted_token_length=${#token}
#echo "Converted token length is $converted_token_length"
#pool_url
pool_url="${ENDPOINT_URL_SYSTEMVSSCONNECTION}_apis/distributedtask/pools?poolName=$pool_name&api-version=6.0"
#header

headers=(
  "Authorization: Bearer $SYSTEM_ACCESSTOKEN"
)

#call API
echo "Calling API: $pool_url to get the Agent pool $pool_name"
pool_response=$(curl -s -X GET -H "${headers[@]}" "$pool_url")

pool_id=$(echo $pool_response | jq -r '.value[] | "\(.id)"')
echo "agent pool $pool_name id is $pool_id"

#agent_url
agent_url="${ENDPOINT_URL_SYSTEMVSSCONNECTION}_apis/distributedtask/pools/$pool_id/agents?api-version=6.0"
echo "Calling API: $agent_url to get the Agents in pool $pool_name"
agent_response=$(curl -s -X GET -H "${headers[@]}" "$agent_url")
echo "agent_response is $agent_response"
#agents=$(echo $agent_response | jq -c '[.value[] | {agentId: .id, agentName: .name}]')
#agents=$(echo $agent_response | jq -c '.value[] | {agentId: .id, agentName: [.name]}')
agents=$(echo $agent_response | jq -c '.value[] | {"\(.id)": {"agentName": "\(.name)"}}' | tr -d '\n' | sed 's/}{/,/g')
echo "Agents are: ${agents}"
echo "##vso[task.setvariable variable=agents;isoutput=true]$agents"
