#!/bin/bash
API_URL="https://5003-iwz00ie3gdkhvxpx2ni1z-5c13a017.sandbox.novita.ai/api"

TOKEN=$(curl -s -X POST "$API_URL/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"username":"麺家弍色","password":"admin123"}' \
  | grep -o '"token":"[^"]*"' | cut -d'"' -f4)

curl -s -X GET "$API_URL/customers" \
  -H "Authorization: Bearer $TOKEN" \
  | jq '.[] | {id: .id, name: .name}'
