# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150306023112) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "appearances", force: true do |t|
    t.string   "title"
    t.text     "description"
    t.string   "logo"
    t.integer  "updated_by"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "dark_logo"
    t.string   "light_logo"
  end

  create_table "application_settings", force: true do |t|
    t.integer  "default_projects_limit"
    t.boolean  "signup_enabled"
    t.boolean  "signin_enabled"
    t.boolean  "gravatar_enabled"
    t.text     "sign_in_text"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "home_page_url"
    t.integer  "default_branch_protection", default: 2
    t.boolean  "twitter_sharing_enabled",   default: true
  end

  create_table "audit_events", force: true do |t|
    t.integer  "author_id",   null: false
    t.string   "type",        null: false
    t.integer  "entity_id",   null: false
    t.string   "entity_type", null: false
    t.text     "details"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "audit_events", ["author_id"], name: "index_audit_events_on_author_id", using: :btree
  add_index "audit_events", ["entity_id", "entity_type"], name: "index_audit_events_on_entity_id_and_entity_type", using: :btree
  add_index "audit_events", ["type"], name: "index_audit_events_on_type", using: :btree

  create_table "broadcast_messages", force: true do |t|
    t.text     "message",    null: false
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.integer  "alert_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "color"
    t.string   "font"
  end

  create_table "deploy_keys_projects", force: true do |t|
    t.integer  "deploy_key_id", null: false
    t.integer  "project_id",    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "deploy_keys_projects", ["project_id"], name: "index_deploy_keys_projects_on_project_id", using: :btree

  create_table "emails", force: true do |t|
    t.integer  "user_id",    null: false
    t.string   "email",      null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "emails", ["email"], name: "index_emails_on_email", unique: true, using: :btree
  add_index "emails", ["user_id"], name: "index_emails_on_user_id", using: :btree

  create_table "events", force: true do |t|
    t.string   "target_type"
    t.integer  "target_id"
    t.string   "title"
    t.text     "data"
    t.integer  "project_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "action"
    t.integer  "author_id"
  end

  add_index "events", ["action"], name: "index_events_on_action", using: :btree
  add_index "events", ["author_id"], name: "index_events_on_author_id", using: :btree
  add_index "events", ["created_at"], name: "index_events_on_created_at", using: :btree
  add_index "events", ["project_id"], name: "index_events_on_project_id", using: :btree
  add_index "events", ["target_id"], name: "index_events_on_target_id", using: :btree
  add_index "events", ["target_type"], name: "index_events_on_target_type", using: :btree

  create_table "forked_project_links", force: true do |t|
    t.integer  "forked_to_project_id",   null: false
    t.integer  "forked_from_project_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "forked_project_links", ["forked_to_project_id"], name: "index_forked_project_links_on_forked_to_project_id", unique: true, using: :btree

  create_table "git_hooks", force: true do |t|
    t.string   "force_push_regex"
    t.string   "delete_branch_regex"
    t.string   "commit_message_regex"
    t.boolean  "deny_delete_tag"
    t.integer  "project_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "author_email_regex"
    t.boolean  "member_check",         default: false, null: false
    t.string   "file_name_regex"
  end

  create_table "identities", force: true do |t|
    t.string   "extern_uid"
    t.string   "provider"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "identities", ["created_at", "id"], name: "index_identities_on_created_at_and_id", using: :btree
  add_index "identities", ["user_id"], name: "index_identities_on_user_id", using: :btree

  create_table "issues", force: true do |t|
    t.string   "title"
    t.integer  "assignee_id"
    t.integer  "author_id"
    t.integer  "project_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position",     default: 0
    t.string   "branch_name"
    t.text     "description"
    t.integer  "milestone_id"
    t.string   "state"
    t.integer  "iid"
  end

  add_index "issues", ["assignee_id"], name: "index_issues_on_assignee_id", using: :btree
  add_index "issues", ["author_id"], name: "index_issues_on_author_id", using: :btree
  add_index "issues", ["created_at", "id"], name: "index_issues_on_created_at_and_id", using: :btree
  add_index "issues", ["created_at"], name: "index_issues_on_created_at", using: :btree
  add_index "issues", ["milestone_id"], name: "index_issues_on_milestone_id", using: :btree
  add_index "issues", ["project_id", "iid"], name: "index_issues_on_project_id_and_iid", unique: true, using: :btree
  add_index "issues", ["project_id"], name: "index_issues_on_project_id", using: :btree
  add_index "issues", ["title"], name: "index_issues_on_title", using: :btree

  create_table "keys", force: true do |t|
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "key"
    t.string   "title"
    t.string   "type"
    t.string   "fingerprint"
  end

  add_index "keys", ["created_at", "id"], name: "index_keys_on_created_at_and_id", using: :btree
  add_index "keys", ["user_id"], name: "index_keys_on_user_id", using: :btree

  create_table "label_links", force: true do |t|
    t.integer  "label_id"
    t.integer  "target_id"
    t.string   "target_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "label_links", ["label_id"], name: "index_label_links_on_label_id", using: :btree
  add_index "label_links", ["target_id", "target_type"], name: "index_label_links_on_target_id_and_target_type", using: :btree

  create_table "labels", force: true do |t|
    t.string   "title"
    t.string   "color"
    t.integer  "project_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "labels", ["project_id"], name: "index_labels_on_project_id", using: :btree

  create_table "ldap_group_links", force: true do |t|
    t.string   "cn",           null: false
    t.integer  "group_access", null: false
    t.integer  "group_id",     null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "provider"
  end

  create_table "members", force: true do |t|
    t.integer  "access_level",       null: false
    t.integer  "source_id",          null: false
    t.string   "source_type",        null: false
    t.integer  "user_id",            null: false
    t.integer  "notification_level", null: false
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "members", ["access_level"], name: "index_members_on_access_level", using: :btree
  add_index "members", ["created_at", "id"], name: "index_members_on_created_at_and_id", using: :btree
  add_index "members", ["source_id", "source_type"], name: "index_members_on_source_id_and_source_type", using: :btree
  add_index "members", ["type"], name: "index_members_on_type", using: :btree
  add_index "members", ["user_id"], name: "index_members_on_user_id", using: :btree

  create_table "merge_request_diffs", force: true do |t|
    t.string   "state"
    t.text     "st_commits"
    t.text     "st_diffs"
    t.integer  "merge_request_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "merge_request_diffs", ["merge_request_id"], name: "index_merge_request_diffs_on_merge_request_id", unique: true, using: :btree

  create_table "merge_requests", force: true do |t|
    t.string   "target_branch",                 null: false
    t.string   "source_branch",                 null: false
    t.integer  "source_project_id",             null: false
    t.integer  "author_id"
    t.integer  "assignee_id"
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "milestone_id"
    t.string   "state"
    t.string   "merge_status"
    t.integer  "target_project_id",             null: false
    t.integer  "iid"
    t.text     "description"
    t.integer  "position",          default: 0
    t.datetime "locked_at"
  end

  add_index "merge_requests", ["assignee_id"], name: "index_merge_requests_on_assignee_id", using: :btree
  add_index "merge_requests", ["author_id"], name: "index_merge_requests_on_author_id", using: :btree
  add_index "merge_requests", ["created_at", "id"], name: "index_merge_requests_on_created_at_and_id", using: :btree
  add_index "merge_requests", ["created_at"], name: "index_merge_requests_on_created_at", using: :btree
  add_index "merge_requests", ["milestone_id"], name: "index_merge_requests_on_milestone_id", using: :btree
  add_index "merge_requests", ["source_branch"], name: "index_merge_requests_on_source_branch", using: :btree
  add_index "merge_requests", ["source_project_id"], name: "index_merge_requests_on_source_project_id", using: :btree
  add_index "merge_requests", ["target_branch"], name: "index_merge_requests_on_target_branch", using: :btree
  add_index "merge_requests", ["target_project_id", "iid"], name: "index_merge_requests_on_target_project_id_and_iid", unique: true, using: :btree
  add_index "merge_requests", ["title"], name: "index_merge_requests_on_title", using: :btree

  create_table "milestones", force: true do |t|
    t.string   "title",       null: false
    t.integer  "project_id",  null: false
    t.text     "description"
    t.date     "due_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "state"
    t.integer  "iid"
  end

  add_index "milestones", ["created_at", "id"], name: "index_milestones_on_created_at_and_id", using: :btree
  add_index "milestones", ["due_date"], name: "index_milestones_on_due_date", using: :btree
  add_index "milestones", ["project_id", "iid"], name: "index_milestones_on_project_id_and_iid", unique: true, using: :btree
  add_index "milestones", ["project_id"], name: "index_milestones_on_project_id", using: :btree

  create_table "namespaces", force: true do |t|
    t.string   "name",                            null: false
    t.string   "path",                            null: false
    t.integer  "owner_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type"
    t.string   "description",     default: "",    null: false
    t.string   "avatar"
    t.boolean  "membership_lock", default: false
  end

  add_index "namespaces", ["created_at", "id"], name: "index_namespaces_on_created_at_and_id", using: :btree
  add_index "namespaces", ["name"], name: "index_namespaces_on_name", unique: true, using: :btree
  add_index "namespaces", ["owner_id"], name: "index_namespaces_on_owner_id", using: :btree
  add_index "namespaces", ["path"], name: "index_namespaces_on_path", unique: true, using: :btree
  add_index "namespaces", ["type"], name: "index_namespaces_on_type", using: :btree

  create_table "notes", force: true do |t|
    t.text     "note"
    t.string   "noteable_type"
    t.integer  "author_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "project_id"
    t.string   "attachment"
    t.string   "line_code"
    t.string   "commit_id"
    t.integer  "noteable_id"
    t.boolean  "system",        default: false, null: false
    t.text     "st_diff"
  end

  add_index "notes", ["author_id"], name: "index_notes_on_author_id", using: :btree
  add_index "notes", ["commit_id"], name: "index_notes_on_commit_id", using: :btree
  add_index "notes", ["created_at", "id"], name: "index_notes_on_created_at_and_id", using: :btree
  add_index "notes", ["created_at"], name: "index_notes_on_created_at", using: :btree
  add_index "notes", ["noteable_id", "noteable_type"], name: "index_notes_on_noteable_id_and_noteable_type", using: :btree
  add_index "notes", ["noteable_type"], name: "index_notes_on_noteable_type", using: :btree
  add_index "notes", ["project_id", "noteable_type"], name: "index_notes_on_project_id_and_noteable_type", using: :btree
  add_index "notes", ["project_id"], name: "index_notes_on_project_id", using: :btree
  add_index "notes", ["updated_at"], name: "index_notes_on_updated_at", using: :btree

  create_table "oauth_access_grants", force: true do |t|
    t.integer  "resource_owner_id", null: false
    t.integer  "application_id",    null: false
    t.string   "token",             null: false
    t.integer  "expires_in",        null: false
    t.text     "redirect_uri",      null: false
    t.datetime "created_at",        null: false
    t.datetime "revoked_at"
    t.string   "scopes"
  end

  add_index "oauth_access_grants", ["token"], name: "index_oauth_access_grants_on_token", unique: true, using: :btree

  create_table "oauth_access_tokens", force: true do |t|
    t.integer  "resource_owner_id"
    t.integer  "application_id"
    t.string   "token",             null: false
    t.string   "refresh_token"
    t.integer  "expires_in"
    t.datetime "revoked_at"
    t.datetime "created_at",        null: false
    t.string   "scopes"
  end

  add_index "oauth_access_tokens", ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true, using: :btree
  add_index "oauth_access_tokens", ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id", using: :btree
  add_index "oauth_access_tokens", ["token"], name: "index_oauth_access_tokens_on_token", unique: true, using: :btree

  create_table "oauth_applications", force: true do |t|
    t.string   "name",                      null: false
    t.string   "uid",                       null: false
    t.string   "secret",                    null: false
    t.text     "redirect_uri",              null: false
    t.string   "scopes",       default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "owner_id"
    t.string   "owner_type"
  end

  add_index "oauth_applications", ["owner_id", "owner_type"], name: "index_oauth_applications_on_owner_id_and_owner_type", using: :btree
  add_index "oauth_applications", ["uid"], name: "index_oauth_applications_on_uid", unique: true, using: :btree

  create_table "project_group_links", force: true do |t|
    t.integer  "project_id",                null: false
    t.integer  "group_id",                  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "group_access", default: 30, null: false
  end

  create_table "projects", force: true do |t|
    t.string   "name"
    t.string   "path"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id"
    t.boolean  "issues_enabled",                default: true,     null: false
    t.boolean  "wall_enabled",                  default: true,     null: false
    t.boolean  "merge_requests_enabled",        default: true,     null: false
    t.boolean  "wiki_enabled",                  default: true,     null: false
    t.integer  "namespace_id"
    t.string   "issues_tracker",                default: "gitlab", null: false
    t.string   "issues_tracker_id"
    t.boolean  "snippets_enabled",              default: true,     null: false
    t.datetime "last_activity_at"
    t.string   "import_url"
    t.integer  "visibility_level",              default: 0,        null: false
    t.boolean  "archived",                      default: false,    null: false
    t.string   "avatar"
    t.string   "import_status"
    t.float    "repository_size",               default: 0.0
    t.text     "merge_requests_template"
    t.integer  "star_count",                    default: 0,        null: false
    t.boolean  "merge_requests_rebase_enabled", default: false
    t.string   "import_type"
    t.string   "import_source"
    t.boolean  "merge_requests_rebase_default", default: false
  end

  add_index "projects", ["created_at", "id"], name: "index_projects_on_created_at_and_id", using: :btree
  add_index "projects", ["creator_id"], name: "index_projects_on_creator_id", using: :btree
  add_index "projects", ["last_activity_at"], name: "index_projects_on_last_activity_at", using: :btree
  add_index "projects", ["namespace_id"], name: "index_projects_on_namespace_id", using: :btree
  add_index "projects", ["star_count"], name: "index_projects_on_star_count", using: :btree

  create_table "protected_branches", force: true do |t|
    t.integer  "project_id",                          null: false
    t.string   "name",                                null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "developers_can_push", default: false, null: false
  end

  add_index "protected_branches", ["project_id"], name: "index_protected_branches_on_project_id", using: :btree

  create_table "services", force: true do |t|
    t.string   "type"
    t.string   "title"
    t.integer  "project_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "active",     default: false, null: false
    t.text     "properties"
    t.boolean  "template",   default: false
  end

  add_index "services", ["created_at", "id"], name: "index_services_on_created_at_and_id", using: :btree
  add_index "services", ["project_id"], name: "index_services_on_project_id", using: :btree

  create_table "snippets", force: true do |t|
    t.string   "title"
    t.text     "content"
    t.integer  "author_id",                    null: false
    t.integer  "project_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "file_name"
    t.datetime "expires_at"
    t.string   "type"
    t.integer  "visibility_level", default: 0, null: false
  end

  add_index "snippets", ["author_id"], name: "index_snippets_on_author_id", using: :btree
  add_index "snippets", ["created_at", "id"], name: "index_snippets_on_created_at_and_id", using: :btree
  add_index "snippets", ["created_at"], name: "index_snippets_on_created_at", using: :btree
  add_index "snippets", ["expires_at"], name: "index_snippets_on_expires_at", using: :btree
  add_index "snippets", ["project_id"], name: "index_snippets_on_project_id", using: :btree
  add_index "snippets", ["visibility_level"], name: "index_snippets_on_visibility_level", using: :btree

  create_table "taggings", force: true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context"
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], name: "index_taggings_on_tag_id", using: :btree
  add_index "taggings", ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context", using: :btree

  create_table "tags", force: true do |t|
    t.string "name"
  end

  create_table "users", force: true do |t|
    t.string   "email",                       default: "",    null: false
    t.string   "encrypted_password",          default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",               default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.boolean  "admin",                       default: false, null: false
    t.integer  "projects_limit",              default: 10
    t.string   "skype",                       default: "",    null: false
    t.string   "linkedin",                    default: "",    null: false
    t.string   "twitter",                     default: "",    null: false
    t.string   "authentication_token"
    t.integer  "theme_id",                    default: 1,     null: false
    t.string   "bio"
    t.integer  "failed_attempts",             default: 0
    t.datetime "locked_at"
    t.string   "username"
    t.boolean  "can_create_group",            default: true,  null: false
    t.boolean  "can_create_team",             default: true,  null: false
    t.string   "state"
    t.integer  "color_scheme_id",             default: 1,     null: false
    t.integer  "notification_level",          default: 1,     null: false
    t.datetime "password_expires_at"
    t.integer  "created_by_id"
    t.datetime "last_credential_check_at"
    t.string   "avatar"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.boolean  "hide_no_ssh_key",             default: false
    t.string   "website_url",                 default: "",    null: false
    t.datetime "admin_email_unsubscribed_at"
    t.string   "github_access_token"
    t.string   "gitlab_access_token"
    t.string   "notification_email"
    t.boolean  "hide_no_password",           default: false
    t.boolean  "password_automatically_set", default: false
  end

  add_index "users", ["admin"], name: "index_users_on_admin", using: :btree
  add_index "users", ["authentication_token"], name: "index_users_on_authentication_token", unique: true, using: :btree
  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["created_at", "id"], name: "index_users_on_created_at_and_id", using: :btree
  add_index "users", ["current_sign_in_at"], name: "index_users_on_current_sign_in_at", using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["name"], name: "index_users_on_name", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["username"], name: "index_users_on_username", using: :btree

  create_table "users_star_projects", force: true do |t|
    t.integer  "project_id", null: false
    t.integer  "user_id",    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users_star_projects", ["project_id"], name: "index_users_star_projects_on_project_id", using: :btree
  add_index "users_star_projects", ["user_id", "project_id"], name: "index_users_star_projects_on_user_id_and_project_id", unique: true, using: :btree
  add_index "users_star_projects", ["user_id"], name: "index_users_star_projects_on_user_id", using: :btree

  create_table "web_hooks", force: true do |t|
    t.string   "url"
    t.integer  "project_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type",                  default: "ProjectHook"
    t.integer  "service_id"
    t.boolean  "push_events",           default: true,          null: false
    t.boolean  "issues_events",         default: false,         null: false
    t.boolean  "merge_requests_events", default: false,         null: false
    t.boolean  "tag_push_events",       default: false
  end

  add_index "web_hooks", ["created_at", "id"], name: "index_web_hooks_on_created_at_and_id", using: :btree
  add_index "web_hooks", ["project_id"], name: "index_web_hooks_on_project_id", using: :btree

end
