# public key
GET http://{{host}}:{{bee_api_port}}/addresses
Accept: */*
[Options]
variable: host=localhost
variable: bee_api_port=1633
HTTP 200
[Captures]
public_key: jsonpath "$.publicKey"

# stamp
POST http://{{host}}:{{bee_api_port}}/stamps/420000000/17
Accept: */*
HTTP 201
[Captures]
batch_id: jsonpath "$.batchID"

# upload
POST http://{{host}}:{{bee_api_port}}/bzz?name={{file_name}}
Accept: */*
swarm-postage-batch-id: {{batch_id}}
swarm-deferred-upload: true
Content-type: application/octet-stream
Swarm-Act: true
file,{{file_name}};
HTTP 201
[Captures]
reference: jsonpath "$.reference"
history_address: header "Swarm-Act-History-Address"

# download with ACT
GET http://{{host}}:{{bee_api_port}}/bzz/{{reference}}/{{file_name}}
Accept: */*
Swarm-Act: true
Swarm-Act-History-Address: {{history_address}}
Swarm-Act-Publisher: {{public_key}}
Swarm-Act-Timestamp: 1
HTTP 200
file,{{file_name}};

# download with ACT valid public key but not for current ACT
GET http://{{host}}:{{bee_api_port}}/bzz/{{reference}}/{{file_name}}
Accept: */*
Swarm-Act: true
Swarm-Act-History-Address: {{history_address}}
Swarm-Act-Publisher: 02d28938c3d617ba84f431e4dbb24c767c05d622cf8bbd61bbfaa429c763324723
Swarm-Act-Timestamp: 1
HTTP 500

# download without ACT
GET http://{{host}}:{{bee_api_port}}/bzz/{{reference}}/{{file_name}}
Accept: */*
HTTP 404
