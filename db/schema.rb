# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2023_08_13_055201) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "hstore"
  enable_extension "pg_stat_statements"
  enable_extension "plpgsql"

  create_table "blazer_audits", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "query_id"
    t.text "statement"
    t.string "data_source"
    t.datetime "created_at", precision: nil
    t.index ["query_id"], name: "index_blazer_audits_on_query_id"
    t.index ["user_id"], name: "index_blazer_audits_on_user_id"
  end

  create_table "blazer_checks", force: :cascade do |t|
    t.bigint "creator_id"
    t.bigint "query_id"
    t.string "state"
    t.string "schedule"
    t.text "emails"
    t.text "slack_channels"
    t.string "check_type"
    t.text "message"
    t.datetime "last_run_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["creator_id"], name: "index_blazer_checks_on_creator_id"
    t.index ["query_id"], name: "index_blazer_checks_on_query_id"
  end

  create_table "blazer_dashboard_queries", force: :cascade do |t|
    t.bigint "dashboard_id"
    t.bigint "query_id"
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["dashboard_id"], name: "index_blazer_dashboard_queries_on_dashboard_id"
    t.index ["query_id"], name: "index_blazer_dashboard_queries_on_query_id"
  end

  create_table "blazer_dashboards", force: :cascade do |t|
    t.bigint "creator_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["creator_id"], name: "index_blazer_dashboards_on_creator_id"
  end

  create_table "blazer_queries", force: :cascade do |t|
    t.bigint "creator_id"
    t.string "name"
    t.text "description"
    t.text "statement"
    t.string "data_source"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["creator_id"], name: "index_blazer_queries_on_creator_id"
  end

  create_table "client_users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at", precision: nil
    t.datetime "remember_created_at", precision: nil
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at", precision: nil
    t.datetime "last_sign_in_at", precision: nil
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at", precision: nil
    t.datetime "confirmation_sent_at", precision: nil
    t.string "unconfirmed_email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "contact_sfid"
    t.string "account_sfid"
    t.string "password_salt"
    t.string "user_agent", default: "", null: false
    t.integer "failed_attempts", default: 0, null: false
    t.datetime "locked_at", precision: nil
    t.datetime "password_changed_at", precision: nil
    t.index ["account_sfid"], name: "index_client_users_on_account_sfid"
    t.index ["confirmation_token"], name: "index_client_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_client_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_client_users_on_reset_password_token", unique: true
  end

  create_table "direction_events", force: :cascade do |t|
    t.integer "direction_id"
    t.string "direction_sfid"
    t.string "old_status"
    t.string "new_status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "old_hc_lastop"
    t.string "new_hc_lastop"
    t.boolean "mail_queued", default: false
    t.index ["direction_id"], name: "index_direction_events_on_direction_id"
    t.index ["direction_sfid"], name: "index_direction_events_on_direction_sfid"
  end

  create_table "educations", primary_key: "sfid", id: :string, force: :cascade do |t|
    t.string "school_name"
    t.string "department"
    t.string "joined"
    t.string "left"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "contact_sfid"
    t.string "school_type"
    t.string "degree"
    t.string "degree_name"
    t.string "major"
    t.index ["contact_sfid"], name: "index_educations_on_contact_sfid"
  end

  create_table "fc_users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at", precision: nil
    t.datetime "remember_created_at", precision: nil
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at", precision: nil
    t.datetime "last_sign_in_at", precision: nil
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at", precision: nil
    t.datetime "confirmation_sent_at", precision: nil
    t.string "unconfirmed_email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "account_id"
    t.integer "second_factor_attempts_count", default: 0
    t.string "encrypted_otp_secret_key"
    t.string "encrypted_otp_secret_key_iv"
    t.string "encrypted_otp_secret_key_salt"
    t.string "direct_otp"
    t.datetime "direct_otp_sent_at", precision: nil
    t.datetime "totp_timestamp", precision: nil
    t.string "lead_sfid"
    t.string "lead_no"
    t.string "account_sfid"
    t.datetime "activated_at", precision: nil
    t.string "contact_sfid"
    t.string "activation_token"
    t.datetime "registration_completed_at", precision: nil
    t.string "profile_image"
    t.string "password_salt"
    t.string "user_agent", default: "", null: false
    t.integer "failed_attempts", default: 0, null: false
    t.datetime "locked_at", precision: nil
    t.datetime "password_changed_at", precision: nil
    t.index ["account_id"], name: "index_fc_users_on_account_id"
    t.index ["account_sfid"], name: "index_fc_users_on_account_sfid"
    t.index ["activation_token"], name: "index_fc_users_on_activation_token", unique: true
    t.index ["confirmation_token"], name: "index_fc_users_on_confirmation_token", unique: true
    t.index ["contact_sfid"], name: "index_fc_users_on_contact_sfid", unique: true
    t.index ["email"], name: "index_fc_users_on_email", unique: true
    t.index ["encrypted_otp_secret_key"], name: "index_fc_users_on_encrypted_otp_secret_key", unique: true
    t.index ["lead_no"], name: "index_fc_users_on_lead_no", unique: true
    t.index ["lead_sfid"], name: "index_fc_users_on_lead_sfid"
    t.index ["reset_password_token"], name: "index_fc_users_on_reset_password_token", unique: true
  end

  create_table "flipper_features", force: :cascade do |t|
    t.string "key", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_flipper_features_on_key", unique: true
  end

  create_table "flipper_gates", force: :cascade do |t|
    t.string "feature_key", null: false
    t.string "key", null: false
    t.string "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["feature_key", "key", "value"], name: "index_flipper_gates_on_feature_key_and_key_and_value", unique: true
  end

  create_table "impressions", force: :cascade do |t|
    t.string "impressionable_type"
    t.integer "impressionable_id"
    t.integer "user_id"
    t.string "controller_name"
    t.string "action_name"
    t.string "view_name"
    t.string "request_hash"
    t.string "ip_address"
    t.string "session_hash"
    t.text "message"
    t.text "referrer"
    t.text "params"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["controller_name", "action_name", "ip_address"], name: "controlleraction_ip_index"
    t.index ["controller_name", "action_name", "request_hash"], name: "controlleraction_request_index"
    t.index ["controller_name", "action_name", "session_hash"], name: "controlleraction_session_index"
    t.index ["impressionable_type", "impressionable_id", "ip_address"], name: "poly_ip_index"
    t.index ["impressionable_type", "impressionable_id", "params"], name: "poly_params_request_index"
    t.index ["impressionable_type", "impressionable_id", "request_hash"], name: "poly_request_index"
    t.index ["impressionable_type", "impressionable_id", "session_hash"], name: "poly_session_index"
    t.index ["impressionable_type", "message", "impressionable_id"], name: "impressionable_type_message_index"
    t.index ["impressionable_type", "user_id", "message"], name: "impressionable_type_user_id_message_index"
    t.index ["user_id"], name: "index_impressions_on_user_id"
  end

  create_table "matching_events", force: :cascade do |t|
    t.integer "matching_id"
    t.string "root"
    t.string "new_status"
    t.string "old_status"
    t.string "old_hc_lastop"
    t.string "new_hc_lastop"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["matching_id"], name: "index_matching_events_on_matching_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.string "kind"
    t.string "subject"
    t.text "body"
    t.string "sender_type"
    t.bigint "sender_id"
    t.boolean "draft", default: false
    t.string "notification_code"
    t.string "link", limit: 1024
    t.string "notified_object_type"
    t.bigint "notified_object_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["kind"], name: "index_notifications_on_kind"
    t.index ["notified_object_type", "notified_object_id"], name: "notifications_notified_object"
    t.index ["sender_type", "sender_id"], name: "index_notifications_on_sender_type_and_sender_id"
  end

  create_table "oauth_access_grants", force: :cascade do |t|
    t.bigint "resource_owner_id", null: false
    t.bigint "application_id", null: false
    t.string "token", null: false
    t.integer "expires_in", null: false
    t.text "redirect_uri", null: false
    t.string "scopes", default: "", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "revoked_at", precision: nil
    t.string "code_challenge"
    t.string "code_challenge_method"
    t.index ["application_id"], name: "index_oauth_access_grants_on_application_id"
    t.index ["resource_owner_id"], name: "index_oauth_access_grants_on_resource_owner_id"
    t.index ["token"], name: "index_oauth_access_grants_on_token", unique: true
  end

  create_table "oauth_access_tokens", force: :cascade do |t|
    t.bigint "resource_owner_id"
    t.bigint "application_id", null: false
    t.string "token", null: false
    t.string "refresh_token"
    t.integer "expires_in"
    t.string "scopes"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "revoked_at", precision: nil
    t.string "previous_refresh_token", default: "", null: false
    t.index ["application_id"], name: "index_oauth_access_tokens_on_application_id"
    t.index ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true
    t.index ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id"
    t.index ["token"], name: "index_oauth_access_tokens_on_token", unique: true
  end

  create_table "oauth_applications", force: :cascade do |t|
    t.string "name", null: false
    t.string "uid", null: false
    t.text "redirect_uri", null: false
    t.string "scopes", default: "", null: false
    t.boolean "confidential", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "original_secret"
    t.string "encrypted_secret"
    t.string "encrypted_secret_iv"
    t.index ["uid"], name: "index_oauth_applications_on_uid", unique: true
  end

  create_table "oauth_openid_requests", force: :cascade do |t|
    t.bigint "access_grant_id", null: false
    t.string "nonce", null: false
    t.index ["access_grant_id"], name: "index_oauth_openid_requests_on_access_grant_id"
  end

  create_table "project_category_meta", force: :cascade do |t|
    t.string "slug", null: false
    t.string "work_category_main", null: false
    t.string "work_category_sub"
    t.string "title"
    t.text "description"
    t.string "keywords"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_project_category_meta_on_slug", unique: true
  end

  create_table "receipts", force: :cascade do |t|
    t.string "receiver_type"
    t.bigint "receiver_id"
    t.bigint "notification_id"
    t.string "mailbox"
    t.datetime "read_at", precision: nil
    t.datetime "deleted_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["mailbox"], name: "index_receipts_on_mailbox"
    t.index ["notification_id"], name: "index_receipts_on_notification_id"
    t.index ["receiver_type", "receiver_id"], name: "index_receipts_on_receiver_type_and_receiver_id"
  end

  create_table "salesforce_api_limit_stats", force: :cascade do |t|
    t.integer "daily_api_requests_max"
    t.integer "daily_api_requests_remaining"
    t.integer "daily_api_requests_calls"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "salesforce_picklist_values", force: :cascade do |t|
    t.string "sobject"
    t.string "field"
    t.string "slug"
    t.string "label"
    t.string "value"
    t.boolean "active"
    t.boolean "default_value"
    t.string "valid_for"
    t.integer "position"
    t.datetime "updated_at", precision: nil, default: -> { "now()" }
    t.index ["position"], name: "index_salesforce_picklist_values_on_position"
    t.index ["sobject", "field", "label"], name: "index_salesforce_picklist_values_on_sobject_and_field_and_label", unique: true
    t.index ["sobject", "field", "slug"], name: "index_salesforce_picklist_values_on_sobject_and_field_and_slug", unique: true
    t.index ["sobject", "field"], name: "index_salesforce_picklist_values_on_sobject_and_field"
  end

  add_foreign_key "oauth_access_grants", "fc_users", column: "resource_owner_id"
  add_foreign_key "oauth_access_grants", "oauth_applications", column: "application_id"
  add_foreign_key "oauth_access_tokens", "fc_users", column: "resource_owner_id"
  add_foreign_key "oauth_access_tokens", "oauth_applications", column: "application_id"
  add_foreign_key "oauth_openid_requests", "oauth_access_grants", column: "access_grant_id", on_delete: :cascade

  create_view "project_daily_page_views", materialized: true, sql_definition: <<-SQL
      SELECT opportunity.id AS project_id,
      COALESCE(subquery.pv, (0)::bigint) AS pv
     FROM (salesforce.opportunity
       LEFT JOIN ( SELECT count(impressions.request_hash) AS pv,
              impressions.impressionable_id
             FROM impressions
            WHERE ((impressions.created_at >= ((date_trunc('day'::text, (CURRENT_TIMESTAMP + 'PT9H'::interval)) - 'P1D'::interval) - 'PT9H'::interval)) AND (impressions.created_at < (date_trunc('day'::text, (CURRENT_TIMESTAMP + 'PT9H'::interval)) - 'PT9H'::interval)) AND ((impressions.impressionable_type)::text = 'Opportunity'::text))
            GROUP BY impressions.impressionable_id) subquery ON ((opportunity.id = subquery.impressionable_id)));
  SQL
  add_index "project_daily_page_views", ["project_id"], name: "index_project_daily_page_views_on_project_id", unique: true
  add_index "project_daily_page_views", ["pv"], name: "index_project_daily_page_views_on_pv"

  create_view "project_monthly_page_views", materialized: true, sql_definition: <<-SQL
      SELECT count(impressions.request_hash) AS pv,
      impressions.impressionable_id AS project_id
     FROM impressions
    WHERE ((impressions.created_at >= (date_trunc('month'::text, (CURRENT_TIMESTAMP - 'P1M'::interval)) - 'PT9H'::interval)) AND (impressions.created_at < (date_trunc('month'::text, CURRENT_TIMESTAMP) - 'PT9H'::interval)) AND ((impressions.impressionable_type)::text = 'Opportunity'::text))
    GROUP BY impressions.impressionable_id;
  SQL
  add_index "project_monthly_page_views", ["project_id"], name: "index_project_monthly_page_views_on_project_id", unique: true
  add_index "project_monthly_page_views", ["pv"], name: "index_project_monthly_page_views_on_pv"

  create_view "project_weekly_page_views", materialized: true, sql_definition: <<-SQL
      SELECT count(impressions.request_hash) AS pv,
      impressions.impressionable_id AS project_id
     FROM impressions
    WHERE ((impressions.created_at >= (date_trunc('week'::text, (CURRENT_TIMESTAMP - 'P7D'::interval)) - 'PT9H'::interval)) AND (impressions.created_at < (date_trunc('week'::text, CURRENT_TIMESTAMP) - 'PT9H'::interval)) AND ((impressions.impressionable_type)::text = 'Opportunity'::text))
    GROUP BY impressions.impressionable_id;
  SQL
  add_index "project_weekly_page_views", ["project_id"], name: "index_project_weekly_page_views_on_project_id", unique: true
  add_index "project_weekly_page_views", ["pv"], name: "index_project_weekly_page_views_on_pv"

  create_trigger("salesforce_contact_after_update_of_web_loginemail_c_row_tr", :generated => true, :compatibility => 1).
      on("salesforce.contact").
      after(:update).
      of(:web_loginemail__c) do
    "IF NEW.recordtypename__c = 'FC' THEN UPDATE fc_users SET email = NEW.web_loginemail__c WHERE fc_users.contact_sfid = NEW.sfid; ELSIF NEW.recordtypename__c = 'FC会社' THEN UPDATE fc_users SET email = NEW.web_loginemail__c WHERE fc_users.contact_sfid = NEW.sfid; ELSIF NEW.recordtypename__c = 'クライアント' THEN UPDATE client_users SET email = NEW.web_loginemail__c WHERE client_users.contact_sfid = NEW.sfid; END IF;"
  end

  create_trigger("salesforce_direction_c_after_insert_row_tr", :generated => true, :compatibility => 1).
      on("salesforce.direction__c").
      after(:insert) do
    "INSERT INTO direction_events(direction_id, direction_sfid, old_hc_lastop, new_hc_lastop, old_status, new_status, created_at, updated_at, mail_queued) VALUES(NEW.id, NEW.sfid, NULL, NEW._hc_lastop, NULL, NEW.status__c, NOW(), NOW(), NEW.ismailqueue__c);"
  end

  create_trigger("salesforce_direction_c_after_update_of_status_c_ismailqueue__tr", :generated => true, :compatibility => 1).
      on("salesforce.direction__c").
      after(:update).
      of(:status__c, :ismailqueue__c) do
    "IF OLD._hc_lastop = 'SYNCED' AND NEW._hc_lastop = 'SYNCED' THEN INSERT INTO direction_events(direction_id, direction_sfid, old_hc_lastop, new_hc_lastop, old_status, new_status, created_at, updated_at, mail_queued) VALUES(NEW.id, NEW.sfid, OLD._hc_lastop, NEW._hc_lastop, OLD.status__c, NEW.status__c, NOW(), NOW(), NEW.ismailqueue__c); END IF;"
  end

  create_trigger("salesforce_matching_c_after_insert_row_tr", :generated => true, :compatibility => 1).
      on("salesforce.matching__c").
      after(:insert) do
    "IF NEW.recordtypeid = '01228000000gxWjAAI' THEN INSERT INTO matching_events(matching_id, old_hc_lastop, new_hc_lastop, root, old_status, new_status, created_at, updated_at) VALUES(NEW.id, NULL, NEW._hc_lastop, NEW.root__c, NULL, NEW.matching_status__c, NOW(), NOW()); END IF;"
  end

  create_trigger("salesforce_matching_c_after_update_of_matching_status_c_row_tr", :generated => true, :compatibility => 1).
      on("salesforce.matching__c").
      after(:update).
      of(:matching_status__c) do
    "IF NEW.recordtypeid = '01228000000gxWjAAI' THEN INSERT INTO matching_events(matching_id, old_hc_lastop, new_hc_lastop, root, old_status, new_status, created_at, updated_at) VALUES(NEW.id, OLD._hc_lastop, NEW._hc_lastop, NEW.root__c, OLD.matching_status__c, NEW.matching_status__c, NOW(), NOW()); END IF;"
  end

end
