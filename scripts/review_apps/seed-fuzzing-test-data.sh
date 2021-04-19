[[ "$TRACE" ]] && set -x

function create_user() {
    local user="${1}"

    # API details at https://docs.gitlab.com/ee/api/users.html#user-creation
    #
    # We set "can_create_group=false" because we don't want the DAST user to create groups.
    # Otherwise, the DAST user likely creates a group and enables 2FA for all group members,
    # which leads to the DAST scan getting "stuck" on the 2FA set up page.
    # Once https://gitlab.com/gitlab-org/gitlab/-/issues/231447 is resolved, we can use
    # DAST_AUTH_EXCLUDE_URLS instead to prevent DAST from enabling 2FA.
    curl --silent --show-error --header "PRIVATE-TOKEN: ${REVIEW_APPS_ROOT_TOKEN}" \
        --data "email=${user}@example.com" \
        --data "name=${user}" \
        --data "username=${user}" \
        --data "password=${REVIEW_APPS_ROOT_PASSWORD}" \
        --data "skip_confirmation=true" \
        --data "can_create_group=true" \
        "${CI_ENVIRONMENT_URL}/api/v4/users" > /tmp/user.json

    [[ "$TRACE" ]] && cat /tmp/user.json >&2

    jq .id /tmp/user.json
}
function create_group_for_user() {
    local userid="${1}"

    # API details at https://docs.gitlab.com/ee/api/projects.html#create-project-for-user
    curl --silent --show-error --header "PRIVATE-TOKEN: ${REVIEW_APPS_ROOT_TOKEN}" \
        --data "paht=api-generated-group${userid}" \
        --data "name=awesome-api-test-group-${userid}" \
        --data "visibility=private" \
        "${CI_ENVIRONMENT_URL}/api/v4/groups" > /tmp/groups.json

    [[ "$TRACE" ]] && cat /tmp/groups.json >&2
}

function create_project_for_user() {
    local userid="${1}"

    # API details at https://docs.gitlab.com/ee/api/projects.html#create-project-for-user
    curl --silent --show-error --header "PRIVATE-TOKEN: ${REVIEW_APPS_ROOT_TOKEN}" \
        --data "user_id=${userid}" \
        --data "name=awesome-test-project-${userid}" \
        --data "visibility=private" \
        "${CI_ENVIRONMENT_URL}/api/v4/projects/user/${userid}" > /tmp/project.json

    [[ "$TRACE" ]] && cat /tmp/project.json >&2
}


function trigger_proj_user_creation(){
    local u1=$(create_user "user1")
    create_group_for_user $u1
    create_project_for_user $u1
    local u2=($create_user "user2")
    create_group_for_user $u2
    create_project_for_user $u2
}

