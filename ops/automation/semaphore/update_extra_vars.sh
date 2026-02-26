#!/bin/bash

read -p "Please enter your env group name: " ENV_NAME
# read -p "Enter path to the JSON ENV: " ENV_PATH
read -p "Your Semaphore Url (eg: cicd.capanicus.com): " SEMA_URL
read -p "Paste Your API Token: " API_TOKEN
# SEMA_URL="127.0.0.1:3000"
# API_TOKEN="YOUR_API_TOKEN"
ENV_JSON=$(jq -c . env.json)
ENV_ID=$(curl -s \
  -H "Authorization: Bearer ${API_TOKEN}" \
  http://${SEMA_URL}/api/project/1/environment \
  | jq -r --arg NAME "$ENV_NAME" '.[] | select(.name==$NAME) | .id')

ENV_LIST=$(curl -s \
  -H "Authorization: Bearer ${API_TOKEN}" \
   http://${SEMA_URL}/api/project/1/environment \
| jq '.[].name')

new_payload() {
    jq -n \
    --arg name "$ENV_NAME" \
    --arg env "$ENV_JSON" \
    '{
      name: $name,
      project_id: 1,
      env: "{}",
      json: $env,
      secrets: null
    }' 
}

payload() {
    jq -n \
    --arg name "$ENV_NAME" \
    --arg env "$ENV_JSON" \
    --arg id "$ENV_ID" \
    '{
      id: ($id | tonumber),
      name: $name,
      project_id: 1,
      env: "{}",
      json: $env,
      secrets: null
    }' 
}

echo "Searching for: $ENV_NAME"

if [[ -z "$ENV_ID" ]]; then
  echo "$ENV_NAME Does not exists adding it to the Variable group..."
  new_payload > payload.new.json

  curl -v -X POST \
    -H "Authorization: Bearer ${API_TOKEN}" \
    -H "Content-Type: application/json" \
    -d @payload.new.json \
    http://${SEMA_URL}/api/project/1/environment 
else
  echo "ENV ID for $ENV_NAME: ${ENV_ID}"
  echo "updating the ENV..."
  payload > payload.update.json

  curl -v -X PUT \
    -H "Authorization: Bearer ${API_TOKEN}" \
    -H "Content-Type: application/json" \
    -d @payload.update.json \
    http://${SEMA_URL}/api/project/1/environment/${ENV_ID}
fi


echo "${ENV_LIST}"