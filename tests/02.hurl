# 2. Granting access to new viewers
# - I'm a publisher
# - I have an existing ACT for some content, but without additional grantees
# - I grant access to the content for some new viewers
# - Those viewers can access the content

POST http://{{host}}:{{bee_api_port}}/grantee
Accept: */*
swarm-postage-batch-id: {{batch_id}}
Content-type: application/json
{"grantees": []
}
HTTP 201
[Captures]
grantees_ref: jsonpath "$['ref']"
history_ref: jsonpath "$['historyref']"

# 2/a. Adding additional viewers to existing grantees
# - I'm a publisher
# - I have an existing ACT for some content with some existing grantees
# - I grant access to the content to additional viewers
# - The existing viewers can access the content still
# - The additional viewers can access the content

GET http://{{host}}:{{bee_api_port}}/grantee/{{grantees_ref}}
Accept: */*
swarm-postage-batch-id: {{batch_id}}
HTTP 200
[Captures]
grantees: body

PATCH http://{{host}}:{{bee_api_port}}/grantee/{{grantees_ref}}
Accept: */*
swarm-postage-batch-id: {{batch_id}}
Swarm-Act-History-Address: {{history_ref}}
Content-type: application/json
{
"add": ["03c11754db8b94831731e57a3f598b147a2eb6c9ed8569c5ac091236f67602f6d6"],
"revoke": ["03c11754db8b94831731e57a3f598b147a2eb6c9ed8569c5ac091236f67602f6d5"]
}
HTTP 200
[Captures]
grantees_ref: jsonpath "$['ref']"
history_ref: jsonpath "$['historyref']"

GET http://{{host}}:{{bee_api_port}}/grantee/{{grantees_ref}}
Accept: */*
swarm-postage-batch-id: {{batch_id}}
HTTP 200
[Captures]
grantees: body

# 2/b. Removing viewers from grantee list without content change
# - I'm a publisher
# - I remove viewers from the grantee list of the ACT content
# - The content is unchanged
# - The removed viewers can access the content still
# - The existing viewers can access the content still

PATCH http://{{host}}:{{bee_api_port}}/grantee/{{grantees_ref}}
Accept: */*
swarm-postage-batch-id: {{batch_id}}
Swarm-Act-History-Address: {{history_ref}}
Content-type: application/json
{
"add": [],
"revoke": ["03c11754db8b94831731e57a3f598b147a2eb6c9ed8569c5ac091236f67602f6d6"]
}
HTTP 200
[Captures]
grantees_ref: jsonpath "$['ref']"
history_ref: jsonpath "$['historyref']"

GET http://{{host}}:{{bee_api_port}}/grantee/{{grantees_ref}}
Accept: */*
swarm-postage-batch-id: {{batch_id}}
HTTP 200
[Captures]
grantees: body

# 2/c. Removing viewers from grantee list with content update
# - I'm a publisher
# - I remove viewers from the grantee list of the ACT content
# - The content is updated
# - The removed viewers can't access the latest version of content anymore
# - The removed viewers can access an older version of the content, the version up until the moment they were removed
# - The existing viewers can access the content still, including the latest version

# TODO: Implement 2/c.