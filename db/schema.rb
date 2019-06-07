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

ActiveRecord::Schema.define(version: 20190429125842) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "unaccent"
  enable_extension "pg_trgm"

  create_table "active_poll_translations", force: :cascade do |t|
    t.integer  "active_poll_id", null: false
    t.string   "locale",         null: false
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.text     "description"
    t.index ["active_poll_id"], name: "index_active_poll_translations_on_active_poll_id", using: :btree
    t.index ["locale"], name: "index_active_poll_translations_on_locale", using: :btree
  end

  create_table "active_polls", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "activities", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "action"
    t.string   "actionable_type"
    t.integer  "actionable_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["actionable_id", "actionable_type"], name: "index_activities_on_actionable_id_and_actionable_type", using: :btree
    t.index ["user_id"], name: "index_activities_on_user_id", using: :btree
  end

  create_table "admin_notification_translations", force: :cascade do |t|
    t.integer  "admin_notification_id", null: false
    t.string   "locale",                null: false
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.string   "title"
    t.text     "body"
    t.index ["admin_notification_id"], name: "index_admin_notification_translations_on_admin_notification_id", using: :btree
    t.index ["locale"], name: "index_admin_notification_translations_on_locale", using: :btree
  end

  create_table "admin_notifications", force: :cascade do |t|
    t.string   "title"
    t.text     "body"
    t.string   "link"
    t.string   "segment_recipient"
    t.integer  "recipients_count"
    t.date     "sent_at"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  create_table "administrators", force: :cascade do |t|
    t.integer "user_id"
    t.string  "description"
    t.index ["user_id"], name: "index_administrators_on_user_id", using: :btree
  end

  create_table "ahoy_events", id: :uuid, default: nil, force: :cascade do |t|
    t.uuid     "visit_id"
    t.integer  "user_id"
    t.string   "name"
    t.jsonb    "properties"
    t.datetime "time"
    t.string   "ip"
    t.index ["name", "time"], name: "index_ahoy_events_on_name_and_time", using: :btree
    t.index ["time"], name: "index_ahoy_events_on_time", using: :btree
    t.index ["user_id"], name: "index_ahoy_events_on_user_id", using: :btree
    t.index ["visit_id"], name: "index_ahoy_events_on_visit_id", using: :btree
  end

  create_table "banner_sections", force: :cascade do |t|
    t.integer  "banner_id"
    t.integer  "web_section_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  create_table "banner_translations", force: :cascade do |t|
    t.integer  "banner_id",   null: false
    t.string   "locale",      null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.string   "title"
    t.text     "description"
    t.index ["banner_id"], name: "index_banner_translations_on_banner_id", using: :btree
    t.index ["locale"], name: "index_banner_translations_on_locale", using: :btree
  end

  create_table "banners", force: :cascade do |t|
    t.string   "title",            limit: 80
    t.string   "description"
    t.string   "target_url"
    t.date     "post_started_at"
    t.date     "post_ended_at"
    t.datetime "hidden_at"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.text     "background_color"
    t.text     "font_color"
    t.index ["hidden_at"], name: "index_banners_on_hidden_at", using: :btree
  end

  create_table "budget_ballot_lines", force: :cascade do |t|
    t.integer  "ballot_id"
    t.integer  "investment_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "budget_id"
    t.integer  "group_id"
    t.integer  "heading_id"
    t.index ["ballot_id", "investment_id"], name: "index_budget_ballot_lines_on_ballot_id_and_investment_id", unique: true, using: :btree
    t.index ["ballot_id"], name: "index_budget_ballot_lines_on_ballot_id", using: :btree
    t.index ["investment_id"], name: "index_budget_ballot_lines_on_investment_id", using: :btree
  end

  create_table "budget_ballots", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "budget_id"
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.integer  "ballot_lines_count", default: 0
    t.boolean  "physical",           default: false
    t.integer  "poll_ballot_id"
  end

  create_table "budget_content_blocks", force: :cascade do |t|
    t.integer  "heading_id"
    t.text     "body"
    t.string   "locale"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["heading_id"], name: "index_budget_content_blocks_on_heading_id", using: :btree
  end

  create_table "budget_group_translations", force: :cascade do |t|
    t.integer  "budget_group_id", null: false
    t.string   "locale",          null: false
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.string   "name"
    t.index ["budget_group_id"], name: "index_budget_group_translations_on_budget_group_id", using: :btree
    t.index ["locale"], name: "index_budget_group_translations_on_locale", using: :btree
  end

  create_table "budget_groups", force: :cascade do |t|
    t.integer "budget_id"
    t.string  "name",                 limit: 50
    t.string  "slug"
    t.integer "max_votable_headings",            default: 1
    t.index ["budget_id"], name: "index_budget_groups_on_budget_id", using: :btree
  end

  create_table "budget_heading_translations", force: :cascade do |t|
    t.integer  "budget_heading_id", null: false
    t.string   "locale",            null: false
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.string   "name"
    t.index ["budget_heading_id"], name: "index_budget_heading_translations_on_budget_heading_id", using: :btree
    t.index ["locale"], name: "index_budget_heading_translations_on_locale", using: :btree
  end

  create_table "budget_headings", force: :cascade do |t|
    t.integer "group_id"
    t.string  "name",                 limit: 50
    t.bigint  "price"
    t.integer "population"
    t.string  "slug"
    t.boolean "allow_custom_content",            default: false
    t.text    "latitude"
    t.text    "longitude"
    t.index ["group_id"], name: "index_budget_headings_on_group_id", using: :btree
  end

  create_table "budget_investment_milestone_translations", force: :cascade do |t|
    t.integer  "budget_investment_milestone_id", null: false
    t.string   "locale",                         null: false
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.string   "title"
    t.text     "description"
    t.index ["budget_investment_milestone_id"], name: "index_6770e7675fe296cf87aa0fd90492c141b5269e0b", using: :btree
    t.index ["locale"], name: "index_budget_investment_milestone_translations_on_locale", using: :btree
  end

  create_table "budget_investment_milestones", force: :cascade do |t|
    t.integer  "investment_id"
    t.string   "title",            limit: 80
    t.text     "description"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.datetime "publication_date"
    t.integer  "status_id"
    t.index ["status_id"], name: "index_budget_investment_milestones_on_status_id", using: :btree
  end

  create_table "budget_investment_statuses", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "hidden_at"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["hidden_at"], name: "index_budget_investment_statuses_on_hidden_at", using: :btree
  end

  create_table "budget_investments", force: :cascade do |t|
    t.integer  "author_id"
    t.integer  "administrator_id"
    t.string   "title"
    t.text     "description"
    t.string   "external_url"
    t.bigint   "price"
    t.string   "feasibility",                      limit: 15, default: "undecided"
    t.text     "price_explanation"
    t.text     "unfeasibility_explanation"
    t.boolean  "valuation_finished",                          default: false
    t.integer  "valuator_assignments_count",                  default: 0
    t.bigint   "price_first_year"
    t.string   "duration"
    t.datetime "hidden_at"
    t.integer  "cached_votes_up",                             default: 0
    t.integer  "comments_count",                              default: 0
    t.integer  "confidence_score",                            default: 0,           null: false
    t.integer  "physical_votes",                              default: 0
    t.tsvector "tsv"
    t.datetime "created_at",                                                        null: false
    t.datetime "updated_at",                                                        null: false
    t.integer  "heading_id"
    t.string   "responsible_name"
    t.integer  "budget_id"
    t.integer  "group_id"
    t.boolean  "selected",                                    default: false
    t.string   "location"
    t.string   "organization_name"
    t.datetime "unfeasible_email_sent_at"
    t.integer  "ballot_lines_count",                          default: 0
    t.integer  "previous_heading_id"
    t.boolean  "winner",                                      default: false
    t.boolean  "incompatible",                                default: false
    t.integer  "community_id"
    t.boolean  "visible_to_valuators",                        default: false
    t.integer  "valuator_group_assignments_count",            default: 0
    t.datetime "confirmed_hide_at"
    t.datetime "ignored_flag_at"
    t.integer  "flags_count",                                 default: 0
    t.index ["administrator_id"], name: "index_budget_investments_on_administrator_id", using: :btree
    t.index ["author_id"], name: "index_budget_investments_on_author_id", using: :btree
    t.index ["community_id"], name: "index_budget_investments_on_community_id", using: :btree
    t.index ["heading_id"], name: "index_budget_investments_on_heading_id", using: :btree
    t.index ["tsv"], name: "index_budget_investments_on_tsv", using: :gin
  end

  create_table "budget_phase_translations", force: :cascade do |t|
    t.integer  "budget_phase_id", null: false
    t.string   "locale",          null: false
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.text     "description"
    t.text     "summary"
    t.index ["budget_phase_id"], name: "index_budget_phase_translations_on_budget_phase_id", using: :btree
    t.index ["locale"], name: "index_budget_phase_translations_on_locale", using: :btree
  end

  create_table "budget_phases", force: :cascade do |t|
    t.integer  "budget_id"
    t.integer  "next_phase_id"
    t.string   "kind",                         null: false
    t.text     "summary"
    t.text     "description"
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.boolean  "enabled",       default: true
    t.index ["ends_at"], name: "index_budget_phases_on_ends_at", using: :btree
    t.index ["kind"], name: "index_budget_phases_on_kind", using: :btree
    t.index ["next_phase_id"], name: "index_budget_phases_on_next_phase_id", using: :btree
    t.index ["starts_at"], name: "index_budget_phases_on_starts_at", using: :btree
  end

  create_table "budget_reclassified_votes", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "investment_id"
    t.string   "reason"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "budget_translations", force: :cascade do |t|
    t.integer  "budget_id",  null: false
    t.string   "locale",     null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "name"
    t.index ["budget_id"], name: "index_budget_translations_on_budget_id", using: :btree
    t.index ["locale"], name: "index_budget_translations_on_locale", using: :btree
  end

  create_table "budget_valuator_assignments", force: :cascade do |t|
    t.integer  "valuator_id"
    t.integer  "investment_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.index ["investment_id"], name: "index_budget_valuator_assignments_on_investment_id", using: :btree
  end

  create_table "budget_valuator_group_assignments", force: :cascade do |t|
    t.integer "valuator_group_id"
    t.integer "investment_id"
  end

  create_table "budgets", force: :cascade do |t|
    t.string   "name",                          limit: 80
    t.string   "currency_symbol",               limit: 10
    t.string   "phase",                         limit: 40, default: "accepting"
    t.datetime "created_at",                                                     null: false
    t.datetime "updated_at",                                                     null: false
    t.text     "description_accepting"
    t.text     "description_reviewing"
    t.text     "description_selecting"
    t.text     "description_valuating"
    t.text     "description_balloting"
    t.text     "description_reviewing_ballots"
    t.text     "description_finished"
    t.string   "slug"
    t.text     "description_drafting"
    t.text     "description_publishing_prices"
    t.text     "description_informing"
  end

  create_table "campaigns", force: :cascade do |t|
    t.string   "name"
    t.string   "track_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "ckeditor_assets", force: :cascade do |t|
    t.string   "data_file_name",               null: false
    t.string   "data_content_type"
    t.integer  "data_file_size"
    t.string   "data_fingerprint"
    t.string   "type",              limit: 30
    t.integer  "width"
    t.integer  "height"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.index ["type"], name: "index_ckeditor_assets_on_type", using: :btree
  end

  create_table "comments", force: :cascade do |t|
    t.integer  "commentable_id"
    t.string   "commentable_type"
    t.text     "body"
    t.string   "subject"
    t.integer  "user_id",                            null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "hidden_at"
    t.integer  "flags_count",        default: 0
    t.datetime "ignored_flag_at"
    t.integer  "moderator_id"
    t.integer  "administrator_id"
    t.integer  "cached_votes_total", default: 0
    t.integer  "cached_votes_up",    default: 0
    t.integer  "cached_votes_down",  default: 0
    t.datetime "confirmed_hide_at"
    t.string   "ancestry"
    t.integer  "confidence_score",   default: 0,     null: false
    t.boolean  "valuation",          default: false
    t.index ["ancestry"], name: "index_comments_on_ancestry", using: :btree
    t.index ["cached_votes_down"], name: "index_comments_on_cached_votes_down", using: :btree
    t.index ["cached_votes_total"], name: "index_comments_on_cached_votes_total", using: :btree
    t.index ["cached_votes_up"], name: "index_comments_on_cached_votes_up", using: :btree
    t.index ["commentable_id", "commentable_type"], name: "index_comments_on_commentable_id_and_commentable_type", using: :btree
    t.index ["hidden_at"], name: "index_comments_on_hidden_at", using: :btree
    t.index ["user_id"], name: "index_comments_on_user_id", using: :btree
    t.index ["valuation"], name: "index_comments_on_valuation", using: :btree
  end

  create_table "communities", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "dashboard_actions", force: :cascade do |t|
    t.string   "title",                     limit: 80
    t.text     "description"
    t.string   "link"
    t.boolean  "request_to_administrators",            default: false
    t.integer  "day_offset",                           default: 0
    t.integer  "required_supports",                    default: 0
    t.integer  "order",                                default: 0
    t.boolean  "active",                               default: true
    t.datetime "hidden_at"
    t.integer  "action_type",                          default: 0,     null: false
    t.string   "short_description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "published_proposal",                   default: false
  end

  create_table "dashboard_administrator_tasks", force: :cascade do |t|
    t.string   "source_type"
    t.integer  "source_id"
    t.integer  "user_id"
    t.datetime "executed_at"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["source_type", "source_id"], name: "index_dashboard_administrator_tasks_on_source", using: :btree
    t.index ["user_id"], name: "index_dashboard_administrator_tasks_on_user_id", using: :btree
  end

  create_table "dashboard_executed_actions", force: :cascade do |t|
    t.integer  "proposal_id"
    t.integer  "action_id"
    t.datetime "executed_at"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["action_id"], name: "index_proposal_action", using: :btree
    t.index ["proposal_id"], name: "index_dashboard_executed_actions_on_proposal_id", using: :btree
  end

  create_table "debates", force: :cascade do |t|
    t.string   "title",                        limit: 80
    t.text     "description"
    t.integer  "author_id"
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
    t.string   "visit_id"
    t.datetime "hidden_at"
    t.integer  "flags_count",                             default: 0
    t.datetime "ignored_flag_at"
    t.integer  "cached_votes_total",                      default: 0
    t.integer  "cached_votes_up",                         default: 0
    t.integer  "cached_votes_down",                       default: 0
    t.integer  "comments_count",                          default: 0
    t.datetime "confirmed_hide_at"
    t.integer  "cached_anonymous_votes_total",            default: 0
    t.integer  "cached_votes_score",                      default: 0
    t.bigint   "hot_score",                               default: 0
    t.integer  "confidence_score",                        default: 0
    t.integer  "geozone_id"
    t.tsvector "tsv"
    t.datetime "featured_at"
    t.index ["author_id", "hidden_at"], name: "index_debates_on_author_id_and_hidden_at", using: :btree
    t.index ["author_id"], name: "index_debates_on_author_id", using: :btree
    t.index ["cached_votes_down"], name: "index_debates_on_cached_votes_down", using: :btree
    t.index ["cached_votes_score"], name: "index_debates_on_cached_votes_score", using: :btree
    t.index ["cached_votes_total"], name: "index_debates_on_cached_votes_total", using: :btree
    t.index ["cached_votes_up"], name: "index_debates_on_cached_votes_up", using: :btree
    t.index ["confidence_score"], name: "index_debates_on_confidence_score", using: :btree
    t.index ["geozone_id"], name: "index_debates_on_geozone_id", using: :btree
    t.index ["hidden_at"], name: "index_debates_on_hidden_at", using: :btree
    t.index ["hot_score"], name: "index_debates_on_hot_score", using: :btree
    t.index ["title"], name: "index_debates_on_title", using: :btree
    t.index ["tsv"], name: "index_debates_on_tsv", using: :gin
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree
  end

  create_table "direct_messages", force: :cascade do |t|
    t.integer  "sender_id"
    t.integer  "receiver_id"
    t.string   "title"
    t.text     "body"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "documents", force: :cascade do |t|
    t.string   "title"
    t.string   "attachment_file_name"
    t.string   "attachment_content_type"
    t.integer  "attachment_file_size"
    t.datetime "attachment_updated_at"
    t.integer  "user_id"
    t.string   "documentable_type"
    t.integer  "documentable_id"
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.boolean  "admin",                   default: false
    t.index ["documentable_type", "documentable_id"], name: "index_documents_on_documentable_type_and_documentable_id", using: :btree
    t.index ["user_id", "documentable_type", "documentable_id"], name: "access_documents", using: :btree
    t.index ["user_id"], name: "index_documents_on_user_id", using: :btree
  end

  create_table "failed_census_calls", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "document_number"
    t.string   "document_type"
    t.date     "date_of_birth"
    t.string   "postal_code"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.string   "district_code"
    t.integer  "poll_officer_id"
    t.integer  "year_of_birth"
    t.index ["user_id"], name: "index_failed_census_calls_on_user_id", using: :btree
  end

  create_table "flags", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "flaggable_type"
    t.integer  "flaggable_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["flaggable_type", "flaggable_id"], name: "index_flags_on_flaggable_type_and_flaggable_id", using: :btree
    t.index ["user_id", "flaggable_type", "flaggable_id"], name: "access_inappropiate_flags", using: :btree
    t.index ["user_id"], name: "index_flags_on_user_id", using: :btree
  end

  create_table "follows", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "followable_type"
    t.integer  "followable_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.index ["followable_type", "followable_id"], name: "index_follows_on_followable_type_and_followable_id", using: :btree
    t.index ["user_id", "followable_type", "followable_id"], name: "access_follows", using: :btree
    t.index ["user_id"], name: "index_follows_on_user_id", using: :btree
  end

  create_table "geozones", force: :cascade do |t|
    t.string   "name"
    t.string   "html_map_coordinates"
    t.string   "external_code"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.string   "census_code"
  end

  create_table "geozones_polls", force: :cascade do |t|
    t.integer "geozone_id"
    t.integer "poll_id"
    t.index ["geozone_id"], name: "index_geozones_polls_on_geozone_id", using: :btree
    t.index ["poll_id"], name: "index_geozones_polls_on_poll_id", using: :btree
  end

  create_table "i18n_content_translations", force: :cascade do |t|
    t.integer  "i18n_content_id", null: false
    t.string   "locale",          null: false
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.text     "value"
    t.index ["i18n_content_id"], name: "index_i18n_content_translations_on_i18n_content_id", using: :btree
    t.index ["locale"], name: "index_i18n_content_translations_on_locale", using: :btree
  end

  create_table "i18n_contents", force: :cascade do |t|
    t.string "key"
  end

  create_table "identities", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "provider"
    t.string   "uid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_identities_on_user_id", using: :btree
  end

  create_table "images", force: :cascade do |t|
    t.string   "imageable_type"
    t.integer  "imageable_id"
    t.string   "title",                   limit: 80
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.string   "attachment_file_name"
    t.string   "attachment_content_type"
    t.integer  "attachment_file_size"
    t.datetime "attachment_updated_at"
    t.integer  "user_id"
    t.index ["imageable_type", "imageable_id"], name: "index_images_on_imageable_type_and_imageable_id", using: :btree
    t.index ["user_id"], name: "index_images_on_user_id", using: :btree
  end

  create_table "legislation_annotations", force: :cascade do |t|
    t.string   "quote"
    t.text     "ranges"
    t.text     "text"
    t.integer  "legislation_draft_version_id"
    t.integer  "author_id"
    t.datetime "hidden_at"
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.integer  "comments_count",               default: 0
    t.string   "range_start"
    t.integer  "range_start_offset"
    t.string   "range_end"
    t.integer  "range_end_offset"
    t.text     "context"
    t.index ["author_id"], name: "index_legislation_annotations_on_author_id", using: :btree
    t.index ["hidden_at"], name: "index_legislation_annotations_on_hidden_at", using: :btree
    t.index ["legislation_draft_version_id"], name: "index_legislation_annotations_on_legislation_draft_version_id", using: :btree
    t.index ["range_start", "range_end"], name: "index_legislation_annotations_on_range_start_and_range_end", using: :btree
  end

  create_table "legislation_answers", force: :cascade do |t|
    t.integer  "legislation_question_id"
    t.integer  "legislation_question_option_id"
    t.integer  "user_id"
    t.datetime "hidden_at"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.index ["hidden_at"], name: "index_legislation_answers_on_hidden_at", using: :btree
    t.index ["legislation_question_id"], name: "index_legislation_answers_on_legislation_question_id", using: :btree
    t.index ["legislation_question_option_id"], name: "index_legislation_answers_on_legislation_question_option_id", using: :btree
    t.index ["user_id"], name: "index_legislation_answers_on_user_id", using: :btree
  end

  create_table "legislation_draft_version_translations", force: :cascade do |t|
    t.integer  "legislation_draft_version_id", null: false
    t.string   "locale",                       null: false
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.string   "title"
    t.text     "changelog"
    t.text     "body"
    t.text     "body_html"
    t.text     "toc_html"
    t.index ["legislation_draft_version_id"], name: "index_900e5ba94457606e69e89193db426e8ddff809bc", using: :btree
    t.index ["locale"], name: "index_legislation_draft_version_translations_on_locale", using: :btree
  end

  create_table "legislation_draft_versions", force: :cascade do |t|
    t.integer  "legislation_process_id"
    t.string   "title"
    t.text     "changelog"
    t.string   "status",                 default: "draft"
    t.boolean  "final_version",          default: false
    t.text     "body"
    t.datetime "hidden_at"
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.text     "body_html"
    t.text     "toc_html"
    t.index ["hidden_at"], name: "index_legislation_draft_versions_on_hidden_at", using: :btree
    t.index ["legislation_process_id"], name: "index_legislation_draft_versions_on_legislation_process_id", using: :btree
    t.index ["status"], name: "index_legislation_draft_versions_on_status", using: :btree
  end

  create_table "legislation_process_translations", force: :cascade do |t|
    t.integer  "legislation_process_id", null: false
    t.string   "locale",                 null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.string   "title"
    t.text     "summary"
    t.text     "description"
    t.text     "additional_info"
    t.text     "milestones_summary"
    t.text     "homepage"
    t.index ["legislation_process_id"], name: "index_199e5fed0aca73302243f6a1fca885ce10cdbb55", using: :btree
    t.index ["locale"], name: "index_legislation_process_translations_on_locale", using: :btree
  end

  create_table "legislation_processes", force: :cascade do |t|
    t.string   "title"
    t.text     "description"
    t.text     "additional_info"
    t.date     "start_date"
    t.date     "end_date"
    t.date     "debate_start_date"
    t.date     "debate_end_date"
    t.date     "draft_publication_date"
    t.date     "allegations_start_date"
    t.date     "allegations_end_date"
    t.date     "result_publication_date"
    t.datetime "hidden_at"
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.text     "summary"
    t.boolean  "debate_phase_enabled",       default: false
    t.boolean  "allegations_phase_enabled",  default: false
    t.boolean  "draft_publication_enabled",  default: false
    t.boolean  "result_publication_enabled", default: false
    t.boolean  "published",                  default: true
    t.date     "proposals_phase_start_date"
    t.date     "proposals_phase_end_date"
    t.boolean  "proposals_phase_enabled"
    t.text     "proposals_description"
    t.date     "draft_start_date"
    t.date     "draft_end_date"
    t.boolean  "draft_phase_enabled",        default: false
    t.boolean  "homepage_enabled",           default: false
    t.text     "background_color"
    t.text     "font_color"
    t.string   "title_label"
    t.string   "summary_label"
    t.boolean  "description_enabled",        default: true
    t.string   "description_label"
    t.boolean  "video_url_enabled",          default: true
    t.string   "video_url_label"
    t.boolean  "image_enabled",              default: true
    t.string   "image_label"
    t.boolean  "documents_enabled",          default: true
    t.string   "documents_label"
    t.boolean  "geozone_enabled",            default: true
    t.string   "geozone_label"
    t.boolean  "tags_enabled",               default: true
    t.string   "tags_label"
    t.index ["allegations_end_date"], name: "index_legislation_processes_on_allegations_end_date", using: :btree
    t.index ["allegations_start_date"], name: "index_legislation_processes_on_allegations_start_date", using: :btree
    t.index ["debate_end_date"], name: "index_legislation_processes_on_debate_end_date", using: :btree
    t.index ["debate_start_date"], name: "index_legislation_processes_on_debate_start_date", using: :btree
    t.index ["draft_end_date"], name: "index_legislation_processes_on_draft_end_date", using: :btree
    t.index ["draft_publication_date"], name: "index_legislation_processes_on_draft_publication_date", using: :btree
    t.index ["draft_start_date"], name: "index_legislation_processes_on_draft_start_date", using: :btree
    t.index ["end_date"], name: "index_legislation_processes_on_end_date", using: :btree
    t.index ["hidden_at"], name: "index_legislation_processes_on_hidden_at", using: :btree
    t.index ["result_publication_date"], name: "index_legislation_processes_on_result_publication_date", using: :btree
    t.index ["start_date"], name: "index_legislation_processes_on_start_date", using: :btree
  end

  create_table "legislation_proposals", force: :cascade do |t|
    t.integer  "legislation_process_id"
    t.string   "title",                  limit: 80
    t.text     "description"
    t.integer  "author_id"
    t.datetime "hidden_at"
    t.integer  "flags_count",                       default: 0
    t.datetime "ignored_flag_at"
    t.integer  "cached_votes_up",                   default: 0
    t.integer  "comments_count",                    default: 0
    t.datetime "confirmed_hide_at"
    t.bigint   "hot_score",                         default: 0
    t.integer  "confidence_score",                  default: 0
    t.string   "responsible_name",       limit: 60
    t.text     "summary"
    t.string   "video_url"
    t.tsvector "tsv"
    t.integer  "geozone_id"
    t.datetime "retired_at"
    t.string   "retired_reason"
    t.text     "retired_explanation"
    t.integer  "community_id"
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
    t.integer  "cached_votes_total",                default: 0
    t.integer  "cached_votes_down",                 default: 0
    t.boolean  "selected"
    t.integer  "cached_votes_score",                default: 0
    t.index ["cached_votes_score"], name: "index_legislation_proposals_on_cached_votes_score", using: :btree
    t.index ["legislation_process_id"], name: "index_legislation_proposals_on_legislation_process_id", using: :btree
  end

  create_table "legislation_question_option_translations", force: :cascade do |t|
    t.integer  "legislation_question_option_id", null: false
    t.string   "locale",                         null: false
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.string   "value"
    t.index ["legislation_question_option_id"], name: "index_61bcec8729110b7f8e1e9e5ce08780878597a209", using: :btree
    t.index ["locale"], name: "index_legislation_question_option_translations_on_locale", using: :btree
  end

  create_table "legislation_question_options", force: :cascade do |t|
    t.integer  "legislation_question_id"
    t.string   "value"
    t.integer  "answers_count",           default: 0
    t.datetime "hidden_at"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.index ["hidden_at"], name: "index_legislation_question_options_on_hidden_at", using: :btree
    t.index ["legislation_question_id"], name: "index_legislation_question_options_on_legislation_question_id", using: :btree
  end

  create_table "legislation_question_translations", force: :cascade do |t|
    t.integer  "legislation_question_id", null: false
    t.string   "locale",                  null: false
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.text     "title"
    t.index ["legislation_question_id"], name: "index_d34cc1e1fe6d5162210c41ce56533c5afabcdbd3", using: :btree
    t.index ["locale"], name: "index_legislation_question_translations_on_locale", using: :btree
  end

  create_table "legislation_questions", force: :cascade do |t|
    t.integer  "legislation_process_id"
    t.text     "title"
    t.integer  "answers_count",          default: 0
    t.datetime "hidden_at"
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.integer  "comments_count",         default: 0
    t.integer  "author_id"
    t.index ["hidden_at"], name: "index_legislation_questions_on_hidden_at", using: :btree
    t.index ["legislation_process_id"], name: "index_legislation_questions_on_legislation_process_id", using: :btree
  end

  create_table "links", force: :cascade do |t|
    t.string   "label"
    t.string   "url"
    t.string   "linkable_type"
    t.integer  "linkable_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.index ["linkable_type", "linkable_id"], name: "index_links_on_linkable_type_and_linkable_id", using: :btree
  end

  create_table "local_census_records", force: :cascade do |t|
    t.string   "document_number", null: false
    t.string   "document_type",   null: false
    t.date     "date_of_birth",   null: false
    t.string   "postal_code",     null: false
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  create_table "locks", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "tries",        default: 0
    t.datetime "locked_until", default: '2000-01-01 01:01:01', null: false
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
    t.index ["user_id"], name: "index_locks_on_user_id", using: :btree
  end

  create_table "managers", force: :cascade do |t|
    t.integer "user_id"
    t.index ["user_id"], name: "index_managers_on_user_id", using: :btree
  end

  create_table "map_locations", force: :cascade do |t|
    t.float   "latitude"
    t.float   "longitude"
    t.integer "zoom"
    t.integer "proposal_id"
    t.integer "investment_id"
    t.index ["investment_id"], name: "index_map_locations_on_investment_id", using: :btree
    t.index ["proposal_id"], name: "index_map_locations_on_proposal_id", using: :btree
  end

  create_table "milestone_statuses", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "hidden_at"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["hidden_at"], name: "index_milestone_statuses_on_hidden_at", using: :btree
  end

  create_table "milestone_translations", force: :cascade do |t|
    t.integer  "milestone_id", null: false
    t.string   "locale",       null: false
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.string   "title"
    t.text     "description"
    t.index ["locale"], name: "index_milestone_translations_on_locale", using: :btree
    t.index ["milestone_id"], name: "index_milestone_translations_on_milestone_id", using: :btree
  end

  create_table "milestones", force: :cascade do |t|
    t.string   "milestoneable_type"
    t.integer  "milestoneable_id"
    t.string   "title",              limit: 80
    t.text     "description"
    t.datetime "publication_date"
    t.integer  "status_id"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.index ["status_id"], name: "index_milestones_on_status_id", using: :btree
  end

  create_table "moderators", force: :cascade do |t|
    t.integer "user_id"
    t.index ["user_id"], name: "index_moderators_on_user_id", using: :btree
  end

  create_table "newsletters", force: :cascade do |t|
    t.string   "subject"
    t.string   "segment_recipient", null: false
    t.string   "from"
    t.text     "body"
    t.date     "sent_at"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.datetime "hidden_at"
  end

  create_table "notifications", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "notifiable_type"
    t.integer  "notifiable_id"
    t.integer  "counter",         default: 1
    t.datetime "emailed_at"
    t.datetime "read_at"
    t.index ["user_id"], name: "index_notifications_on_user_id", using: :btree
  end

  create_table "organizations", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "name",             limit: 60
    t.datetime "verified_at"
    t.datetime "rejected_at"
    t.string   "responsible_name", limit: 60
    t.index ["user_id"], name: "index_organizations_on_user_id", using: :btree
  end

  create_table "poll_answers", force: :cascade do |t|
    t.integer  "question_id"
    t.integer  "author_id"
    t.string   "answer"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["author_id"], name: "index_poll_answers_on_author_id", using: :btree
    t.index ["question_id", "answer"], name: "index_poll_answers_on_question_id_and_answer", using: :btree
    t.index ["question_id"], name: "index_poll_answers_on_question_id", using: :btree
  end

  create_table "poll_ballot_sheets", force: :cascade do |t|
    t.text     "data"
    t.integer  "poll_id"
    t.integer  "officer_assignment_id"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.index ["officer_assignment_id"], name: "index_poll_ballot_sheets_on_officer_assignment_id", using: :btree
    t.index ["poll_id"], name: "index_poll_ballot_sheets_on_poll_id", using: :btree
  end

  create_table "poll_ballots", force: :cascade do |t|
    t.integer  "ballot_sheet_id"
    t.text     "data"
    t.integer  "external_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  create_table "poll_booth_assignments", force: :cascade do |t|
    t.integer  "booth_id"
    t.integer  "poll_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["booth_id"], name: "index_poll_booth_assignments_on_booth_id", using: :btree
    t.index ["poll_id"], name: "index_poll_booth_assignments_on_poll_id", using: :btree
  end

  create_table "poll_booths", force: :cascade do |t|
    t.string "name"
    t.string "location"
  end

  create_table "poll_officer_assignments", force: :cascade do |t|
    t.integer  "booth_assignment_id"
    t.integer  "officer_id"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.date     "date",                                null: false
    t.boolean  "final",               default: false
    t.string   "user_data_log",       default: ""
    t.index ["booth_assignment_id"], name: "index_poll_officer_assignments_on_booth_assignment_id", using: :btree
    t.index ["officer_id"], name: "index_poll_officer_assignments_on_officer_id", using: :btree
  end

  create_table "poll_officers", force: :cascade do |t|
    t.integer "user_id"
    t.integer "failed_census_calls_count", default: 0
    t.index ["user_id"], name: "index_poll_officers_on_user_id", using: :btree
  end

  create_table "poll_partial_results", force: :cascade do |t|
    t.integer "question_id"
    t.integer "author_id"
    t.string  "answer"
    t.integer "amount"
    t.string  "origin"
    t.date    "date"
    t.integer "booth_assignment_id"
    t.integer "officer_assignment_id"
    t.text    "amount_log",                default: ""
    t.text    "officer_assignment_id_log", default: ""
    t.text    "author_id_log",             default: ""
    t.index ["answer"], name: "index_poll_partial_results_on_answer", using: :btree
    t.index ["author_id"], name: "index_poll_partial_results_on_author_id", using: :btree
    t.index ["booth_assignment_id", "date"], name: "index_poll_partial_results_on_booth_assignment_id_and_date", using: :btree
    t.index ["origin"], name: "index_poll_partial_results_on_origin", using: :btree
    t.index ["question_id"], name: "index_poll_partial_results_on_question_id", using: :btree
  end

  create_table "poll_question_answer_translations", force: :cascade do |t|
    t.integer  "poll_question_answer_id", null: false
    t.string   "locale",                  null: false
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.string   "title"
    t.text     "description"
    t.index ["locale"], name: "index_poll_question_answer_translations_on_locale", using: :btree
    t.index ["poll_question_answer_id"], name: "index_85270fa85f62081a3a227186b4c95fe4f7fa94b9", using: :btree
  end

  create_table "poll_question_answer_videos", force: :cascade do |t|
    t.string  "title"
    t.string  "url"
    t.integer "answer_id"
    t.index ["answer_id"], name: "index_poll_question_answer_videos_on_answer_id", using: :btree
  end

  create_table "poll_question_answers", force: :cascade do |t|
    t.string  "title"
    t.text    "description"
    t.integer "question_id"
    t.integer "given_order", default: 1
    t.boolean "most_voted",  default: false
    t.index ["question_id"], name: "index_poll_question_answers_on_question_id", using: :btree
  end

  create_table "poll_question_translations", force: :cascade do |t|
    t.integer  "poll_question_id", null: false
    t.string   "locale",           null: false
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.string   "title"
    t.index ["locale"], name: "index_poll_question_translations_on_locale", using: :btree
    t.index ["poll_question_id"], name: "index_poll_question_translations_on_poll_question_id", using: :btree
  end

  create_table "poll_questions", force: :cascade do |t|
    t.integer  "proposal_id"
    t.integer  "poll_id"
    t.integer  "author_id"
    t.string   "author_visible_name"
    t.string   "title"
    t.integer  "comments_count"
    t.datetime "hidden_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.tsvector "tsv"
    t.string   "video_url"
    t.index ["author_id"], name: "index_poll_questions_on_author_id", using: :btree
    t.index ["poll_id"], name: "index_poll_questions_on_poll_id", using: :btree
    t.index ["proposal_id"], name: "index_poll_questions_on_proposal_id", using: :btree
    t.index ["tsv"], name: "index_poll_questions_on_tsv", using: :gin
  end

  create_table "poll_recounts", force: :cascade do |t|
    t.integer "author_id"
    t.string  "origin"
    t.date    "date"
    t.integer "booth_assignment_id"
    t.integer "officer_assignment_id"
    t.text    "officer_assignment_id_log", default: ""
    t.text    "author_id_log",             default: ""
    t.integer "white_amount",              default: 0
    t.text    "white_amount_log",          default: ""
    t.integer "null_amount",               default: 0
    t.text    "null_amount_log",           default: ""
    t.integer "total_amount",              default: 0
    t.text    "total_amount_log",          default: ""
    t.index ["booth_assignment_id"], name: "index_poll_recounts_on_booth_assignment_id", using: :btree
    t.index ["officer_assignment_id"], name: "index_poll_recounts_on_officer_assignment_id", using: :btree
  end

  create_table "poll_shifts", force: :cascade do |t|
    t.integer  "booth_id"
    t.integer  "officer_id"
    t.date     "date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "officer_name"
    t.string   "officer_email"
    t.integer  "task",          default: 0, null: false
    t.index ["booth_id", "officer_id", "date", "task"], name: "index_poll_shifts_on_booth_id_and_officer_id_and_date_and_task", unique: true, using: :btree
    t.index ["booth_id"], name: "index_poll_shifts_on_booth_id", using: :btree
    t.index ["officer_id"], name: "index_poll_shifts_on_officer_id", using: :btree
  end

  create_table "poll_translations", force: :cascade do |t|
    t.integer  "poll_id",     null: false
    t.string   "locale",      null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.string   "name"
    t.text     "summary"
    t.text     "description"
    t.index ["locale"], name: "index_poll_translations_on_locale", using: :btree
    t.index ["poll_id"], name: "index_poll_translations_on_poll_id", using: :btree
  end

  create_table "poll_voters", force: :cascade do |t|
    t.string   "document_number"
    t.string   "document_type"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.integer  "poll_id",               null: false
    t.integer  "booth_assignment_id"
    t.integer  "age"
    t.string   "gender"
    t.integer  "geozone_id"
    t.integer  "answer_id"
    t.integer  "officer_assignment_id"
    t.integer  "user_id"
    t.string   "origin"
    t.integer  "officer_id"
    t.string   "token"
    t.index ["booth_assignment_id"], name: "index_poll_voters_on_booth_assignment_id", using: :btree
    t.index ["document_number"], name: "index_poll_voters_on_document_number", using: :btree
    t.index ["officer_assignment_id"], name: "index_poll_voters_on_officer_assignment_id", using: :btree
    t.index ["poll_id", "document_number", "document_type"], name: "doc_by_poll", using: :btree
    t.index ["poll_id"], name: "index_poll_voters_on_poll_id", using: :btree
    t.index ["user_id"], name: "index_poll_voters_on_user_id", using: :btree
  end

  create_table "polls", force: :cascade do |t|
    t.string   "name"
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.boolean  "published",          default: false
    t.boolean  "geozone_restricted", default: false
    t.text     "summary"
    t.text     "description"
    t.integer  "comments_count",     default: 0
    t.integer  "author_id"
    t.datetime "hidden_at"
    t.string   "slug"
    t.boolean  "results_enabled",    default: false
    t.boolean  "stats_enabled",      default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "budget_id"
    t.string   "related_type"
    t.integer  "related_id"
    t.index ["budget_id"], name: "index_polls_on_budget_id", unique: true, using: :btree
    t.index ["related_type", "related_id"], name: "index_polls_on_related_type_and_related_id", using: :btree
    t.index ["starts_at", "ends_at"], name: "index_polls_on_starts_at_and_ends_at", using: :btree
  end

  create_table "progress_bar_translations", force: :cascade do |t|
    t.integer  "progress_bar_id", null: false
    t.string   "locale",          null: false
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.string   "title"
    t.index ["locale"], name: "index_progress_bar_translations_on_locale", using: :btree
    t.index ["progress_bar_id"], name: "index_progress_bar_translations_on_progress_bar_id", using: :btree
  end

  create_table "progress_bars", force: :cascade do |t|
    t.integer  "kind"
    t.integer  "percentage"
    t.string   "progressable_type"
    t.integer  "progressable_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  create_table "proposal_notifications", force: :cascade do |t|
    t.string   "title"
    t.text     "body"
    t.integer  "author_id"
    t.integer  "proposal_id"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.boolean  "moderated",         default: false
    t.datetime "hidden_at"
    t.datetime "ignored_at"
    t.datetime "confirmed_hide_at"
  end

  create_table "proposals", force: :cascade do |t|
    t.string   "title",               limit: 80
    t.text     "description"
    t.integer  "author_id"
    t.datetime "hidden_at"
    t.integer  "flags_count",                    default: 0
    t.datetime "ignored_flag_at"
    t.integer  "cached_votes_up",                default: 0
    t.integer  "comments_count",                 default: 0
    t.datetime "confirmed_hide_at"
    t.bigint   "hot_score",                      default: 0
    t.integer  "confidence_score",               default: 0
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.string   "responsible_name",    limit: 60
    t.text     "summary"
    t.string   "video_url"
    t.tsvector "tsv"
    t.integer  "geozone_id"
    t.datetime "retired_at"
    t.string   "retired_reason"
    t.text     "retired_explanation"
    t.integer  "community_id"
    t.datetime "published_at"
    t.boolean  "selected",                       default: false
    t.index ["author_id", "hidden_at"], name: "index_proposals_on_author_id_and_hidden_at", using: :btree
    t.index ["author_id"], name: "index_proposals_on_author_id", using: :btree
    t.index ["cached_votes_up"], name: "index_proposals_on_cached_votes_up", using: :btree
    t.index ["community_id"], name: "index_proposals_on_community_id", using: :btree
    t.index ["confidence_score"], name: "index_proposals_on_confidence_score", using: :btree
    t.index ["geozone_id"], name: "index_proposals_on_geozone_id", using: :btree
    t.index ["hidden_at"], name: "index_proposals_on_hidden_at", using: :btree
    t.index ["hot_score"], name: "index_proposals_on_hot_score", using: :btree
    t.index ["summary"], name: "index_proposals_on_summary", using: :btree
    t.index ["title"], name: "index_proposals_on_title", using: :btree
    t.index ["tsv"], name: "index_proposals_on_tsv", using: :gin
  end

  create_table "related_content_scores", force: :cascade do |t|
    t.integer "user_id"
    t.integer "related_content_id"
    t.integer "value"
    t.index ["related_content_id"], name: "index_related_content_scores_on_related_content_id", using: :btree
    t.index ["user_id", "related_content_id"], name: "unique_user_related_content_scoring", unique: true, using: :btree
    t.index ["user_id"], name: "index_related_content_scores_on_user_id", using: :btree
  end

  create_table "related_contents", force: :cascade do |t|
    t.string   "parent_relationable_type"
    t.integer  "parent_relationable_id"
    t.string   "child_relationable_type"
    t.integer  "child_relationable_id"
    t.integer  "related_content_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "hidden_at"
    t.integer  "related_content_scores_count", default: 0
    t.integer  "author_id"
    t.index ["child_relationable_type", "child_relationable_id"], name: "index_related_contents_on_child_relationable", using: :btree
    t.index ["hidden_at"], name: "index_related_contents_on_hidden_at", using: :btree
    t.index ["parent_relationable_id", "parent_relationable_type", "child_relationable_id", "child_relationable_type"], name: "unique_parent_child_related_content", unique: true, using: :btree
    t.index ["parent_relationable_type", "parent_relationable_id"], name: "index_related_contents_on_parent_relationable", using: :btree
    t.index ["related_content_id"], name: "opposite_related_content", using: :btree
  end

  create_table "reports", force: :cascade do |t|
    t.boolean  "stats"
    t.boolean  "results"
    t.string   "process_type"
    t.integer  "process_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.boolean  "advanced_stats"
    t.index ["process_type", "process_id"], name: "index_reports_on_process_type_and_process_id", using: :btree
  end

  create_table "settings", force: :cascade do |t|
    t.string "key"
    t.string "value"
    t.index ["key"], name: "index_settings_on_key", using: :btree
  end

  create_table "signature_sheets", force: :cascade do |t|
    t.string   "signable_type"
    t.integer  "signable_id"
    t.text     "document_numbers"
    t.boolean  "processed",        default: false
    t.integer  "author_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "signatures", force: :cascade do |t|
    t.integer  "signature_sheet_id"
    t.integer  "user_id"
    t.string   "document_number"
    t.boolean  "verified",           default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "site_customization_content_blocks", force: :cascade do |t|
    t.string   "name"
    t.string   "locale"
    t.text     "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name", "locale"], name: "index_site_customization_content_blocks_on_name_and_locale", unique: true, using: :btree
  end

  create_table "site_customization_images", force: :cascade do |t|
    t.string   "name",               null: false
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.index ["name"], name: "index_site_customization_images_on_name", unique: true, using: :btree
  end

  create_table "site_customization_page_translations", force: :cascade do |t|
    t.integer  "site_customization_page_id", null: false
    t.string   "locale",                     null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.string   "title"
    t.string   "subtitle"
    t.text     "content"
    t.index ["locale"], name: "index_site_customization_page_translations_on_locale", using: :btree
    t.index ["site_customization_page_id"], name: "index_7fa0f9505738cb31a31f11fb2f4c4531fed7178b", using: :btree
  end

  create_table "site_customization_pages", force: :cascade do |t|
    t.string   "slug",                                 null: false
    t.string   "title"
    t.string   "subtitle"
    t.text     "content"
    t.boolean  "more_info_flag"
    t.boolean  "print_content_flag"
    t.string   "status",             default: "draft"
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.string   "locale"
  end

  create_table "stats_versions", force: :cascade do |t|
    t.string   "process_type"
    t.integer  "process_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.index ["process_type", "process_id"], name: "index_stats_versions_on_process_type_and_process_id", using: :btree
  end

  create_table "taggings", force: :cascade do |t|
    t.integer  "tag_id"
    t.string   "taggable_type"
    t.integer  "taggable_id"
    t.string   "tagger_type"
    t.integer  "tagger_id"
    t.string   "context",       limit: 128
    t.datetime "created_at"
    t.index ["tag_id"], name: "index_taggings_on_tag_id", using: :btree
    t.index ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context", using: :btree
  end

  create_table "tags", force: :cascade do |t|
    t.string  "name",                        limit: 160
    t.integer "taggings_count",                          default: 0
    t.integer "debates_count",                           default: 0
    t.integer "proposals_count",                         default: 0
    t.string  "kind"
    t.integer "budget/investments_count",                default: 0
    t.integer "legislation/proposals_count",             default: 0
    t.integer "legislation/processes_count",             default: 0
    t.index ["debates_count"], name: "index_tags_on_debates_count", using: :btree
    t.index ["legislation/processes_count"], name: "index_tags_on_legislation/processes_count", using: :btree
    t.index ["legislation/proposals_count"], name: "index_tags_on_legislation/proposals_count", using: :btree
    t.index ["name"], name: "index_tags_on_name", unique: true, using: :btree
    t.index ["proposals_count"], name: "index_tags_on_proposals_count", using: :btree
  end

  create_table "topics", force: :cascade do |t|
    t.string   "title",                      null: false
    t.text     "description"
    t.integer  "author_id"
    t.integer  "comments_count", default: 0
    t.integer  "community_id"
    t.datetime "hidden_at"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.index ["community_id"], name: "index_topics_on_community_id", using: :btree
    t.index ["hidden_at"], name: "index_topics_on_hidden_at", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                                     default: ""
    t.string   "encrypted_password",                        default: "",                    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                             default: 0,                     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                                                                null: false
    t.datetime "updated_at",                                                                null: false
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.boolean  "email_on_comment",                          default: false
    t.boolean  "email_on_comment_reply",                    default: false
    t.string   "phone_number",                   limit: 30
    t.string   "official_position"
    t.integer  "official_level",                            default: 0
    t.datetime "hidden_at"
    t.string   "sms_confirmation_code"
    t.string   "username",                       limit: 60
    t.string   "document_number"
    t.string   "document_type"
    t.datetime "residence_verified_at"
    t.string   "email_verification_token"
    t.datetime "verified_at"
    t.string   "unconfirmed_phone"
    t.string   "confirmed_phone"
    t.datetime "letter_requested_at"
    t.datetime "confirmed_hide_at"
    t.string   "letter_verification_code"
    t.integer  "failed_census_calls_count",                 default: 0
    t.datetime "level_two_verified_at"
    t.string   "erase_reason"
    t.datetime "erased_at"
    t.boolean  "public_activity",                           default: true
    t.boolean  "newsletter",                                default: true
    t.integer  "notifications_count",                       default: 0
    t.boolean  "registering_with_oauth",                    default: false
    t.string   "locale"
    t.string   "oauth_email"
    t.integer  "geozone_id"
    t.string   "redeemable_code"
    t.string   "gender",                         limit: 10
    t.datetime "date_of_birth"
    t.boolean  "email_on_proposal_notification",            default: true
    t.boolean  "email_digest",                              default: true
    t.boolean  "email_on_direct_message",                   default: true
    t.boolean  "official_position_badge",                   default: false
    t.datetime "password_changed_at",                       default: '2015-01-01 01:01:01', null: false
    t.boolean  "created_from_signature",                    default: false
    t.integer  "failed_email_digests_count",                default: 0
    t.text     "former_users_data_log",                     default: ""
    t.integer  "balloted_heading_id"
    t.boolean  "public_interests",                          default: false
    t.boolean  "recommended_debates",                       default: true
    t.boolean  "recommended_proposals",                     default: true
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["geozone_id"], name: "index_users_on_geozone_id", using: :btree
    t.index ["hidden_at"], name: "index_users_on_hidden_at", using: :btree
    t.index ["password_changed_at"], name: "index_users_on_password_changed_at", using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
    t.index ["username"], name: "index_users_on_username", using: :btree
  end

  create_table "valuator_groups", force: :cascade do |t|
    t.string  "name"
    t.integer "budget_investments_count", default: 0
  end

  create_table "valuators", force: :cascade do |t|
    t.integer "user_id"
    t.string  "description"
    t.integer "budget_investments_count", default: 0
    t.integer "valuator_group_id"
    t.index ["user_id"], name: "index_valuators_on_user_id", using: :btree
  end

  create_table "verified_users", force: :cascade do |t|
    t.string   "document_number"
    t.string   "document_type"
    t.string   "phone"
    t.string   "email"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.index ["document_number"], name: "index_verified_users_on_document_number", using: :btree
    t.index ["email"], name: "index_verified_users_on_email", using: :btree
    t.index ["phone"], name: "index_verified_users_on_phone", using: :btree
  end

  create_table "visits", id: :uuid, default: nil, force: :cascade do |t|
    t.uuid     "visitor_id"
    t.string   "ip"
    t.text     "user_agent"
    t.text     "referrer"
    t.text     "landing_page"
    t.integer  "user_id"
    t.string   "referring_domain"
    t.string   "search_keyword"
    t.string   "browser"
    t.string   "os"
    t.string   "device_type"
    t.integer  "screen_height"
    t.integer  "screen_width"
    t.string   "country"
    t.string   "region"
    t.string   "city"
    t.string   "postal_code"
    t.decimal  "latitude"
    t.decimal  "longitude"
    t.string   "utm_source"
    t.string   "utm_medium"
    t.string   "utm_term"
    t.string   "utm_content"
    t.string   "utm_campaign"
    t.datetime "started_at"
    t.index ["started_at"], name: "index_visits_on_started_at", using: :btree
    t.index ["user_id"], name: "index_visits_on_user_id", using: :btree
  end

  create_table "votes", force: :cascade do |t|
    t.string   "votable_type"
    t.integer  "votable_id"
    t.string   "voter_type"
    t.integer  "voter_id"
    t.boolean  "vote_flag"
    t.string   "vote_scope"
    t.integer  "vote_weight"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "signature_id"
    t.index ["signature_id"], name: "index_votes_on_signature_id", using: :btree
    t.index ["votable_id", "votable_type", "vote_scope"], name: "index_votes_on_votable_id_and_votable_type_and_vote_scope", using: :btree
    t.index ["voter_id", "voter_type", "vote_scope"], name: "index_votes_on_voter_id_and_voter_type_and_vote_scope", using: :btree
  end

  create_table "web_sections", force: :cascade do |t|
    t.text     "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "widget_card_translations", force: :cascade do |t|
    t.integer  "widget_card_id", null: false
    t.string   "locale",         null: false
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.string   "label"
    t.string   "title"
    t.text     "description"
    t.string   "link_text"
    t.index ["locale"], name: "index_widget_card_translations_on_locale", using: :btree
    t.index ["widget_card_id"], name: "index_widget_card_translations_on_widget_card_id", using: :btree
  end

  create_table "widget_cards", force: :cascade do |t|
    t.string   "title"
    t.text     "description"
    t.string   "link_text"
    t.string   "link_url"
    t.string   "label"
    t.boolean  "header",                     default: false
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.integer  "site_customization_page_id"
    t.integer  "columns",                    default: 4
    t.index ["site_customization_page_id"], name: "index_widget_cards_on_site_customization_page_id", using: :btree
  end

  create_table "widget_feeds", force: :cascade do |t|
    t.string   "kind"
    t.integer  "limit",      default: 3
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_foreign_key "administrators", "users"
  add_foreign_key "budget_investments", "communities"
  add_foreign_key "dashboard_administrator_tasks", "users"
  add_foreign_key "dashboard_executed_actions", "dashboard_actions", column: "action_id"
  add_foreign_key "dashboard_executed_actions", "proposals"
  add_foreign_key "documents", "users"
  add_foreign_key "failed_census_calls", "poll_officers"
  add_foreign_key "failed_census_calls", "users"
  add_foreign_key "flags", "users"
  add_foreign_key "follows", "users"
  add_foreign_key "geozones_polls", "geozones"
  add_foreign_key "geozones_polls", "polls"
  add_foreign_key "identities", "users"
  add_foreign_key "images", "users"
  add_foreign_key "legislation_draft_versions", "legislation_processes"
  add_foreign_key "legislation_proposals", "legislation_processes"
  add_foreign_key "locks", "users"
  add_foreign_key "managers", "users"
  add_foreign_key "moderators", "users"
  add_foreign_key "notifications", "users"
  add_foreign_key "organizations", "users"
  add_foreign_key "poll_answers", "poll_questions", column: "question_id"
  add_foreign_key "poll_booth_assignments", "polls"
  add_foreign_key "poll_officer_assignments", "poll_booth_assignments", column: "booth_assignment_id"
  add_foreign_key "poll_partial_results", "poll_booth_assignments", column: "booth_assignment_id"
  add_foreign_key "poll_partial_results", "poll_officer_assignments", column: "officer_assignment_id"
  add_foreign_key "poll_partial_results", "poll_questions", column: "question_id"
  add_foreign_key "poll_partial_results", "users", column: "author_id"
  add_foreign_key "poll_question_answer_videos", "poll_question_answers", column: "answer_id"
  add_foreign_key "poll_question_answers", "poll_questions", column: "question_id"
  add_foreign_key "poll_questions", "polls"
  add_foreign_key "poll_questions", "proposals"
  add_foreign_key "poll_questions", "users", column: "author_id"
  add_foreign_key "poll_recounts", "poll_booth_assignments", column: "booth_assignment_id"
  add_foreign_key "poll_recounts", "poll_officer_assignments", column: "officer_assignment_id"
  add_foreign_key "poll_voters", "polls"
  add_foreign_key "polls", "budgets"
  add_foreign_key "proposals", "communities"
  add_foreign_key "related_content_scores", "related_contents"
  add_foreign_key "related_content_scores", "users"
  add_foreign_key "users", "geozones"
  add_foreign_key "valuators", "users"
end
