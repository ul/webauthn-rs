#!/bin/zsh

username="test3"

response=$(curl \
    --insecure --no-progress-meter \
    -X POST "https://localhost:8443/api/v1/authenticate" \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -d "username=$username")

opt=$(jq -crn --argjson x "$response" \
    '$x.request.publicKeyCredentialRequestOptions | . += {"userVerification": "preferred"}')

finish=$(jq -crn --argjson x "$response" '$x.actions.finish')
request_id=$(jq -crn --argjson x "$response" '$x.request.requestId')

cargo run --quiet --example webauthn-cli --features u2fhid -- \
    --origin "https://localhost:8443" --auth-options-json "$opt" |
    jq -cr --arg request_id "$request_id" '{credential: ., requestId: $request_id}' |
    curl --insecure --no-progress-meter -X POST $finish -H "Content-Type: application/json" -d @-
