# public key
GET http://localhost:1635/addresses
Accept: */*
HTTP 200
[Captures]
public_key: jsonpath "$.publicKey"

# stamp
POST http://localhost:1635/stamps/420000000/17
Accept: */*
HTTP 201
[Captures]
batch_id: jsonpath "$.batchID"

# upload
POST http://localhost:1633/bzz?name=README.md
Accept: */*
swarm-postage-batch-id: {{batch_id}}
swarm-deferred-upload: true
Content-type: application/octet-stream
Swarm-Act: true
file,README.md;
HTTP 201
[Captures]
reference: jsonpath "$.reference"
history_address: header "Swarm-Act-History-Address"

# download with ACT
GET http://localhost:1633/bzz/{{reference}}/README.md
Accept: */*
Swarm-Act: true
Swarm-Act-History-Address: {{history_address}}
Swarm-Act-Publisher: {{public_key}}
Swarm-Act-Timestamp: 1
HTTP 200
file,README.md;

# download with ACT valid public key but not for current ACT
GET http://localhost:1633/bzz/{{reference}}/README.md
Accept: */*
Swarm-Act: true
Swarm-Act-History-Address: {{history_address}}
Swarm-Act-Publisher: 02d28938c3d617ba84f431e4dbb24c767c05d622cf8bbd61bbfaa429c763324723
Swarm-Act-Timestamp: 1
HTTP 500

# download without ACT
GET http://localhost:1633/bzz/{{reference}}/README.md
Accept: */*
HTTP 404
