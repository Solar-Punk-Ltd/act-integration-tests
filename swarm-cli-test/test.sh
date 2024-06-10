#set -e -o pipefail

# +---------------------------------+
# | build                           |
# +---------------------------------+
npm run build

# +---------------------------------+
# | public key                      |
# +---------------------------------+
response_addresses=$(node dist/src/index.js addresses)
public_key=$(echo "$response_addresses" | grep -oE 'Public Key: *[^ ]*' | head -1 |awk '{print $3}')
echo "  Public key               : $public_key"

# +---------------------------------+
# | list stamps                     |
# +---------------------------------+
response=$(node dist/src/index.js stamp list --limit 1)
stamp_id=$(echo "$response" | grep -o 'Stamp ID: [^ ]*' | awk '{print $3}')
echo "  Stamp ID                 : $stamp_id"

# +=================================+
# | upload file with ACT            |
# +=================================+
response_upload=$(node dist/src/index.js upload README.md --act --stamp $stamp_id)  
swarm_hash=$(echo "$response_upload" | grep -o 'Swarm hash: [^ ]*' | awk '{print $3}')
swarm_history_address=$(echo "$response_upload"  | grep -o 'Swarm history address: [^ ]*' | awk '{print $4}')
echo "  Swarm hash               : $swarm_hash"
echo "  Swarm history address    : $swarm_history_address"

# +=================================+
# | download file with ACT          |
# +=================================+
rm R-test.md
node dist/src/index.js download $swarm_hash R-test.md --act --act-history-address $swarm_history_address --act-publisher $public_key

# +=================================+
# | validate downloaded file        |
# +=================================+
if ! cmp -s README.md R-test.md; then
    echo "Validation failed: README.md is not equal to R-test.md"
fi

# +=================================+
# | add grantee list                |
# +=================================+
response_add_grantee=$(node dist/src/index.js grantee add grantees.txt --stamp $stamp_id)
grantee_reference=$(echo "$response_add_grantee" | grep -o 'Grantee reference: [^ ]*' | awk '{print $3}')
grantee_history_reference=$(echo "$response_add_grantee"  | grep -o 'Grantee history reference: [^ ]*' | awk '{print $4}')
echo "  Grantee reference        : $grantee_reference"
echo "  Grantee history reference: $grantee_history_reference"

# +=================================+
# | get grantee list                |
# +=================================+

response_get_grantee=$(node dist/src/index.js grantee get $grantee_reference)
grantee_public_keys=$(echo "$response_get_grantee" | sed 's/Grantee public keys: //')
echo "  Grantee public keys      : $grantee_public_keys"

if grep -qF "$grantee_public_keys" grantees.txt; then
    echo "grantees.txt contains grantee_public_keys"
else
    echo "grantees.txt does not contain grantee_public_keys"
fi

# +=================================+
# | patch grantee list              |
# +=================================+

response_patch_grantee=$(node dist/src/index.js grantee patch grantees-patch.json \
    --reference $grantee_reference \
    --history $grantee_history_reference \
    --stamp $stamp_id)
grantee_patch_reference=$(echo "$response_patch_grantee" | grep -o 'Grantee reference: [^ ]*' | awk '{print $3}')
grantee_patch_history_reference=$(echo "$response_patch_grantee"  | grep -o 'Grantee history reference: [^ ]*' | awk '{print $4}')
echo "  Grantee reference        : $grantee_patch_reference"
echo "  Grantee history reference: $grantee_patch_history_reference"

# +=================================+
# | get grantee list                |
# +=================================+

response_get_grantee=$(node dist/src/index.js grantee get $grantee_patch_reference)
grantee_public_keys=$(echo "$response_get_grantee" | sed 's/Grantee public keys: //')
echo "  Grantee public keys      : $grantee_public_keys"

