# 1. Publishing new ACT content without additional grantees
# - I'm a publisher
# - I upload some new content
# - I create an ACT for the content, but without additional grantees
# - I can access the content

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

# 1/a. Reading and editing an existing ACT
# - I'm a publisher
# - I have an existing ACT for some content
# - I can read and edit the ACT

# TODO: Implement 1/a.