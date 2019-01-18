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

ActiveRecord::Schema.define(version: 20190112190324) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "unaccent"
  enable_extension "pg_trgm"

  create_table "activities", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "action"
    t.integer  "actionable_id"
    t.string   "actionable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "activities", ["actionable_id", "actionable_type"], name: "index_activities_on_actionable_id_and_actionable_type", using: :btree
  add_index "activities", ["user_id"], name: "index_activities_on_user_id", using: :btree

  create_table "admin_notification_translations", force: :cascade do |t|
    t.integer  "admin_notification_id", null: false
    t.string   "locale",                null: false
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.string   "title"
    t.text     "body"
  end

  add_index "admin_notification_translations", ["admin_notification_id"], name: "index_admin_notification_translations_on_admin_notification_id", using: :btree
  add_index "admin_notification_translations", ["locale"], name: "index_admin_notification_translations_on_locale", using: :btree

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
  end

  add_index "administrators", ["user_id"], name: "index_administrators_on_user_id", using: :btree

  create_table "ahoy_events", id: :uuid, default: nil, force: :cascade do |t|
    t.uuid     "visit_id"
    t.integer  "user_id"
    t.string   "name"
    t.jsonb    "properties"
    t.datetime "time"
    t.string   "ip"
  end

  add_index "ahoy_events", ["name", "time"], name: "index_ahoy_events_on_name_and_time", using: :btree
  add_index "ahoy_events", ["time"], name: "index_ahoy_events_on_time", using: :btree
  add_index "ahoy_events", ["user_id"], name: "index_ahoy_events_on_user_id", using: :btree
  add_index "ahoy_events", ["visit_id"], name: "index_ahoy_events_on_visit_id", using: :btree

  create_table "annotations", force: :cascade do |t|
    t.string   "quote"
    t.text     "ranges"
    t.text     "text"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.integer  "user_id"
    t.integer  "legacy_legislation_id"
  end

  add_index "annotations", ["legacy_legislation_id"], name: "index_annotations_on_legacy_legislation_id", using: :btree
  add_index "annotations", ["user_id"], name: "index_annotations_on_user_id", using: :btree

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
  end

  add_index "banner_translations", ["banner_id"], name: "index_banner_translations_on_banner_id", using: :btree
  add_index "banner_translations", ["locale"], name: "index_banner_translations_on_locale", using: :btree

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
  end

  add_index "banners", ["hidden_at"], name: "index_banners_on_hidden_at", using: :btree

  create_table "budget_ballot_lines", force: :cascade do |t|
    t.integer  "ballot_id"
    t.integer  "investment_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "budget_id"
    t.integer  "group_id"
    t.integer  "heading_id"
  end

  add_index "budget_ballot_lines", ["ballot_id", "investment_id"], name: "index_budget_ballot_lines_on_ballot_id_and_investment_id", unique: true, using: :btree
  add_index "budget_ballot_lines", ["ballot_id"], name: "index_budget_ballot_lines_on_ballot_id", using: :btree
  add_index "budget_ballot_lines", ["investment_id"], name: "index_budget_ballot_lines_on_investment_id", using: :btree

  create_table "budget_ballots", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "budget_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "budget_content_blocks", force: :cascade do |t|
    t.integer  "heading_id"
    t.text     "body"
    t.string   "locale"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "budget_content_blocks", ["heading_id"], name: "index_budget_content_blocks_on_heading_id", using: :btree

  create_table "budget_groups", force: :cascade do |t|
    t.integer "budget_id"
    t.string  "name",                 limit: 50
    t.string  "slug"
    t.integer "max_votable_headings",            default: 1
  end

  add_index "budget_groups", ["budget_id"], name: "index_budget_groups_on_budget_id", using: :btree

  create_table "budget_headings", force: :cascade do |t|
    t.integer "group_id"
    t.string  "name",                 limit: 50
    t.integer "price",                limit: 8
    t.integer "population"
    t.string  "slug"
    t.boolean "allow_custom_content",            default: false
    t.text    "latitude"
    t.text    "longitude"
  end

  add_index "budget_headings", ["group_id"], name: "index_budget_headings_on_group_id", using: :btree

  create_table "budget_investment_milestone_translations", force: :cascade do |t|
    t.integer  "budget_investment_milestone_id", null: false
    t.string   "locale",                         null: false
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.string   "title"
    t.text     "description"
  end

  add_index "budget_investment_milestone_translations", ["budget_investment_milestone_id"], name: "index_6770e7675fe296cf87aa0fd90492c141b5269e0b", using: :btree
  add_index "budget_investment_milestone_translations", ["locale"], name: "index_budget_investment_milestone_translations_on_locale", using: :btree

  create_table "budget_investment_milestones", force: :cascade do |t|
    t.integer  "investment_id"
    t.string   "title",            limit: 80
    t.text     "description"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.datetime "publication_date"
    t.integer  "status_id"
  end

  add_index "budget_investment_milestones", ["status_id"], name: "index_budget_investment_milestones_on_status_id", using: :btree

  create_table "budget_investment_statuses", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "hidden_at"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "budget_investment_statuses", ["hidden_at"], name: "index_budget_investment_statuses_on_hidden_at", using: :btree

  create_table "budget_investments", force: :cascade do |t|
    t.integer  "author_id"
    t.integer  "administrator_id"
    t.string   "title"
    t.text     "description"
    t.string   "external_url"
    t.integer  "price",                            limit: 8
    t.string   "feasibility",                      limit: 15, default: "undecided"
    t.text     "price_explanation"
    t.text     "unfeasibility_explanation"
    t.boolean  "valuation_finished",                          default: false
    t.integer  "valuator_assignments_count",                  default: 0
    t.integer  "price_first_year",                 limit: 8
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
  end

  add_index "budget_investments", ["administrator_id"], name: "index_budget_investments_on_administrator_id", using: :btree
  add_index "budget_investments", ["author_id"], name: "index_budget_investments_on_author_id", using: :btree
  add_index "budget_investments", ["community_id"], name: "index_budget_investments_on_community_id", using: :btree
  add_index "budget_investments", ["heading_id"], name: "index_budget_investments_on_heading_id", using: :btree
  add_index "budget_investments", ["tsv"], name: "index_budget_investments_on_tsv", using: :gin

  create_table "budget_phases", force: :cascade do |t|
    t.integer  "budget_id"
    t.integer  "next_phase_id"
    t.string   "kind",                         null: false
    t.text     "summary"
    t.text     "description"
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.boolean  "enabled",       default: true
  end

  add_index "budget_phases", ["ends_at"], name: "index_budget_phases_on_ends_at", using: :btree
  add_index "budget_phases", ["kind"], name: "index_budget_phases_on_kind", using: :btree
  add_index "budget_phases", ["next_phase_id"], name: "index_budget_phases_on_next_phase_id", using: :btree
  add_index "budget_phases", ["starts_at"], name: "index_budget_phases_on_starts_at", using: :btree

  create_table "budget_reclassified_votes", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "investment_id"
    t.string   "reason"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "budget_valuator_assignments", force: :cascade do |t|
    t.integer  "valuator_id"
    t.integer  "investment_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "budget_valuator_assignments", ["investment_id"], name: "index_budget_valuator_assignments_on_investment_id", using: :btree

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
  end

  add_index "ckeditor_assets", ["type"], name: "index_ckeditor_assets_on_type", using: :btree

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
  end

  add_index "comments", ["ancestry"], name: "index_comments_on_ancestry", using: :btree
  add_index "comments", ["cached_votes_down"], name: "index_comments_on_cached_votes_down", using: :btree
  add_index "comments", ["cached_votes_total"], name: "index_comments_on_cached_votes_total", using: :btree
  add_index "comments", ["cached_votes_up"], name: "index_comments_on_cached_votes_up", using: :btree
  add_index "comments", ["commentable_id", "commentable_type"], name: "index_comments_on_commentable_id_and_commentable_type", using: :btree
  add_index "comments", ["hidden_at"], name: "index_comments_on_hidden_at", using: :btree
  add_index "comments", ["user_id"], name: "index_comments_on_user_id", using: :btree
  add_index "comments", ["valuation"], name: "index_comments_on_valuation", using: :btree

  create_table "communities", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.integer  "hot_score",                    limit: 8,  default: 0
    t.integer  "confidence_score",                        default: 0
    t.integer  "geozone_id"
    t.tsvector "tsv"
    t.datetime "featured_at"
  end

  add_index "debates", ["author_id", "hidden_at"], name: "index_debates_on_author_id_and_hidden_at", using: :btree
  add_index "debates", ["author_id"], name: "index_debates_on_author_id", using: :btree
  add_index "debates", ["cached_votes_down"], name: "index_debates_on_cached_votes_down", using: :btree
  add_index "debates", ["cached_votes_score"], name: "index_debates_on_cached_votes_score", using: :btree
  add_index "debates", ["cached_votes_total"], name: "index_debates_on_cached_votes_total", using: :btree
  add_index "debates", ["cached_votes_up"], name: "index_debates_on_cached_votes_up", using: :btree
  add_index "debates", ["confidence_score"], name: "index_debates_on_confidence_score", using: :btree
  add_index "debates", ["geozone_id"], name: "index_debates_on_geozone_id", using: :btree
  add_index "debates", ["hidden_at"], name: "index_debates_on_hidden_at", using: :btree
  add_index "debates", ["hot_score"], name: "index_debates_on_hot_score", using: :btree
  add_index "debates", ["title"], name: "index_debates_on_title", using: :btree
  add_index "debates", ["tsv"], name: "index_debates_on_tsv", using: :gin

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
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

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
    t.integer  "documentable_id"
    t.string   "documentable_type"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "documents", ["documentable_type", "documentable_id"], name: "index_documents_on_documentable_type_and_documentable_id", using: :btree
  add_index "documents", ["user_id", "documentable_type", "documentable_id"], name: "access_documents", using: :btree
  add_index "documents", ["user_id"], name: "index_documents_on_user_id", using: :btree

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
  end

  add_index "failed_census_calls", ["user_id"], name: "index_failed_census_calls_on_user_id", using: :btree

  create_table "flags", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "flaggable_type"
    t.integer  "flaggable_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "flags", ["flaggable_type", "flaggable_id"], name: "index_flags_on_flaggable_type_and_flaggable_id", using: :btree
  add_index "flags", ["user_id", "flaggable_type", "flaggable_id"], name: "access_inappropiate_flags", using: :btree
  add_index "flags", ["user_id"], name: "index_flags_on_user_id", using: :btree

  create_table "follows", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "followable_id"
    t.string   "followable_type"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "follows", ["followable_type", "followable_id"], name: "index_follows_on_followable_type_and_followable_id", using: :btree
  add_index "follows", ["user_id", "followable_type", "followable_id"], name: "access_follows", using: :btree
  add_index "follows", ["user_id"], name: "index_follows_on_user_id", using: :btree

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
  end

  add_index "geozones_polls", ["geozone_id"], name: "index_geozones_polls_on_geozone_id", using: :btree
  add_index "geozones_polls", ["poll_id"], name: "index_geozones_polls_on_poll_id", using: :btree

  create_table "i18n_content_translations", force: :cascade do |t|
    t.integer  "i18n_content_id", null: false
    t.string   "locale",          null: false
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.text     "value"
  end

  add_index "i18n_content_translations", ["i18n_content_id"], name: "index_i18n_content_translations_on_i18n_content_id", using: :btree
  add_index "i18n_content_translations", ["locale"], name: "index_i18n_content_translations_on_locale", using: :btree

  create_table "i18n_contents", force: :cascade do |t|
    t.string "key"
  end

  create_table "identities", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "provider"
    t.string   "uid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "identities", ["user_id"], name: "index_identities_on_user_id", using: :btree

  create_table "images", force: :cascade do |t|
    t.integer  "imageable_id"
    t.string   "imageable_type"
    t.string   "title",                   limit: 80
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.string   "attachment_file_name"
    t.string   "attachment_content_type"
    t.integer  "attachment_file_size"
    t.datetime "attachment_updated_at"
    t.integer  "user_id"
  end

  add_index "images", ["imageable_type", "imageable_id"], name: "index_images_on_imageable_type_and_imageable_id", using: :btree
  add_index "images", ["user_id"], name: "index_images_on_user_id", using: :btree

  create_table "legacy_legislations", force: :cascade do |t|
    t.string   "title"
    t.text     "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
  end

  add_index "legislation_annotations", ["author_id"], name: "index_legislation_annotations_on_author_id", using: :btree
  add_index "legislation_annotations", ["hidden_at"], name: "index_legislation_annotations_on_hidden_at", using: :btree
  add_index "legislation_annotations", ["legislation_draft_version_id"], name: "index_legislation_annotations_on_legislation_draft_version_id", using: :btree
  add_index "legislation_annotations", ["range_start", "range_end"], name: "index_legislation_annotations_on_range_start_and_range_end", using: :btree

  create_table "legislation_answers", force: :cascade do |t|
    t.integer  "legislation_question_id"
    t.integer  "legislation_question_option_id"
    t.integer  "user_id"
    t.datetime "hidden_at"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  add_index "legislation_answers", ["hidden_at"], name: "index_legislation_answers_on_hidden_at", using: :btree
  add_index "legislation_answers", ["legislation_question_id"], name: "index_legislation_answers_on_legislation_question_id", using: :btree
  add_index "legislation_answers", ["legislation_question_option_id"], name: "index_legislation_answers_on_legislation_question_option_id", using: :btree
  add_index "legislation_answers", ["user_id"], name: "index_legislation_answers_on_user_id", using: :btree

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
  end

  add_index "legislation_draft_version_translations", ["legislation_draft_version_id"], name: "index_900e5ba94457606e69e89193db426e8ddff809bc", using: :btree
  add_index "legislation_draft_version_translations", ["locale"], name: "index_legislation_draft_version_translations_on_locale", using: :btree

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
  end

  add_index "legislation_draft_versions", ["hidden_at"], name: "index_legislation_draft_versions_on_hidden_at", using: :btree
  add_index "legislation_draft_versions", ["legislation_process_id"], name: "index_legislation_draft_versions_on_legislation_process_id", using: :btree
  add_index "legislation_draft_versions", ["status"], name: "index_legislation_draft_versions_on_status", using: :btree

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
  end

  add_index "legislation_process_translations", ["legislation_process_id"], name: "index_199e5fed0aca73302243f6a1fca885ce10cdbb55", using: :btree
  add_index "legislation_process_translations", ["locale"], name: "index_legislation_process_translations_on_locale", using: :btree

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
  end

  add_index "legislation_processes", ["allegations_end_date"], name: "index_legislation_processes_on_allegations_end_date", using: :btree
  add_index "legislation_processes", ["allegations_start_date"], name: "index_legislation_processes_on_allegations_start_date", using: :btree
  add_index "legislation_processes", ["debate_end_date"], name: "index_legislation_processes_on_debate_end_date", using: :btree
  add_index "legislation_processes", ["debate_start_date"], name: "index_legislation_processes_on_debate_start_date", using: :btree
  add_index "legislation_processes", ["draft_end_date"], name: "index_legislation_processes_on_draft_end_date", using: :btree
  add_index "legislation_processes", ["draft_publication_date"], name: "index_legislation_processes_on_draft_publication_date", using: :btree
  add_index "legislation_processes", ["draft_start_date"], name: "index_legislation_processes_on_draft_start_date", using: :btree
  add_index "legislation_processes", ["end_date"], name: "index_legislation_processes_on_end_date", using: :btree
  add_index "legislation_processes", ["hidden_at"], name: "index_legislation_processes_on_hidden_at", using: :btree
  add_index "legislation_processes", ["result_publication_date"], name: "index_legislation_processes_on_result_publication_date", using: :btree
  add_index "legislation_processes", ["start_date"], name: "index_legislation_processes_on_start_date", using: :btree

  create_table "legislation_proposals", force: :cascade do |t|
    t.integer  "legislation_process_id"
    t.string   "title",                  limit: 80
    t.text     "description"
    t.string   "question"
    t.string   "external_url"
    t.integer  "author_id"
    t.datetime "hidden_at"
    t.integer  "flags_count",                       default: 0
    t.datetime "ignored_flag_at"
    t.integer  "cached_votes_up",                   default: 0
    t.integer  "comments_count",                    default: 0
    t.datetime "confirmed_hide_at"
    t.integer  "hot_score",              limit: 8,  default: 0
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
  end

  add_index "legislation_proposals", ["legislation_process_id"], name: "index_legislation_proposals_on_legislation_process_id", using: :btree

  create_table "legislation_question_option_translations", force: :cascade do |t|
    t.integer  "legislation_question_option_id", null: false
    t.string   "locale",                         null: false
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.string   "value"
  end

  add_index "legislation_question_option_translations", ["legislation_question_option_id"], name: "index_61bcec8729110b7f8e1e9e5ce08780878597a209", using: :btree
  add_index "legislation_question_option_translations", ["locale"], name: "index_legislation_question_option_translations_on_locale", using: :btree

  create_table "legislation_question_options", force: :cascade do |t|
    t.integer  "legislation_question_id"
    t.string   "value"
    t.integer  "answers_count",           default: 0
    t.datetime "hidden_at"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "legislation_question_options", ["hidden_at"], name: "index_legislation_question_options_on_hidden_at", using: :btree
  add_index "legislation_question_options", ["legislation_question_id"], name: "index_legislation_question_options_on_legislation_question_id", using: :btree

  create_table "legislation_question_translations", force: :cascade do |t|
    t.integer  "legislation_question_id", null: false
    t.string   "locale",                  null: false
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.text     "title"
  end

  add_index "legislation_question_translations", ["legislation_question_id"], name: "index_d34cc1e1fe6d5162210c41ce56533c5afabcdbd3", using: :btree
  add_index "legislation_question_translations", ["locale"], name: "index_legislation_question_translations_on_locale", using: :btree

  create_table "legislation_questions", force: :cascade do |t|
    t.integer  "legislation_process_id"
    t.text     "title"
    t.integer  "answers_count",          default: 0
    t.datetime "hidden_at"
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.integer  "comments_count",         default: 0
    t.integer  "author_id"
  end

  add_index "legislation_questions", ["hidden_at"], name: "index_legislation_questions_on_hidden_at", using: :btree
  add_index "legislation_questions", ["legislation_process_id"], name: "index_legislation_questions_on_legislation_process_id", using: :btree

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
  end

  add_index "locks", ["user_id"], name: "index_locks_on_user_id", using: :btree

  create_table "managers", force: :cascade do |t|
    t.integer "user_id"
  end

  add_index "managers", ["user_id"], name: "index_managers_on_user_id", using: :btree

  create_table "map_locations", force: :cascade do |t|
    t.float   "latitude"
    t.float   "longitude"
    t.integer "zoom"
    t.integer "proposal_id"
    t.integer "investment_id"
  end

  add_index "map_locations", ["investment_id"], name: "index_map_locations_on_investment_id", using: :btree
  add_index "map_locations", ["proposal_id"], name: "index_map_locations_on_proposal_id", using: :btree

  create_table "milestone_statuses", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "hidden_at"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "milestone_statuses", ["hidden_at"], name: "index_milestone_statuses_on_hidden_at", using: :btree

  create_table "milestone_translations", force: :cascade do |t|
    t.integer  "milestone_id", null: false
    t.string   "locale",       null: false
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.string   "title"
    t.text     "description"
  end

  add_index "milestone_translations", ["locale"], name: "index_milestone_translations_on_locale", using: :btree
  add_index "milestone_translations", ["milestone_id"], name: "index_milestone_translations_on_milestone_id", using: :btree

  create_table "milestones", force: :cascade do |t|
    t.integer  "milestoneable_id"
    t.string   "milestoneable_type"
    t.string   "title",              limit: 80
    t.text     "description"
    t.datetime "publication_date"
    t.integer  "status_id"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  add_index "milestones", ["status_id"], name: "index_milestones_on_status_id", using: :btree

  create_table "moderators", force: :cascade do |t|
    t.integer "user_id"
  end

  add_index "moderators", ["user_id"], name: "index_moderators_on_user_id", using: :btree

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
    t.integer  "notifiable_id"
    t.string   "notifiable_type"
    t.integer  "counter",         default: 1
    t.datetime "emailed_at"
    t.datetime "read_at"
  end

  add_index "notifications", ["user_id"], name: "index_notifications_on_user_id", using: :btree

  create_table "organizations", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "name",             limit: 60
    t.datetime "verified_at"
    t.datetime "rejected_at"
    t.string   "responsible_name", limit: 60
  end

  add_index "organizations", ["user_id"], name: "index_organizations_on_user_id", using: :btree

  create_table "poll_answers", force: :cascade do |t|
    t.integer  "question_id"
    t.integer  "author_id"
    t.string   "answer"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "poll_answers", ["author_id"], name: "index_poll_answers_on_author_id", using: :btree
  add_index "poll_answers", ["question_id", "answer"], name: "index_poll_answers_on_question_id_and_answer", using: :btree
  add_index "poll_answers", ["question_id"], name: "index_poll_answers_on_question_id", using: :btree

  create_table "poll_booth_assignments", force: :cascade do |t|
    t.integer  "booth_id"
    t.integer  "poll_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "poll_booth_assignments", ["booth_id"], name: "index_poll_booth_assignments_on_booth_id", using: :btree
  add_index "poll_booth_assignments", ["poll_id"], name: "index_poll_booth_assignments_on_poll_id", using: :btree

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
  end

  add_index "poll_officer_assignments", ["booth_assignment_id"], name: "index_poll_officer_assignments_on_booth_assignment_id", using: :btree
  add_index "poll_officer_assignments", ["officer_id"], name: "index_poll_officer_assignments_on_officer_id", using: :btree

  create_table "poll_officers", force: :cascade do |t|
    t.integer "user_id"
    t.integer "failed_census_calls_count", default: 0
  end

  add_index "poll_officers", ["user_id"], name: "index_poll_officers_on_user_id", using: :btree

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
  end

  add_index "poll_partial_results", ["answer"], name: "index_poll_partial_results_on_answer", using: :btree
  add_index "poll_partial_results", ["author_id"], name: "index_poll_partial_results_on_author_id", using: :btree
  add_index "poll_partial_results", ["booth_assignment_id", "date"], name: "index_poll_partial_results_on_booth_assignment_id_and_date", using: :btree
  add_index "poll_partial_results", ["origin"], name: "index_poll_partial_results_on_origin", using: :btree
  add_index "poll_partial_results", ["question_id"], name: "index_poll_partial_results_on_question_id", using: :btree

  create_table "poll_question_answer_translations", force: :cascade do |t|
    t.integer  "poll_question_answer_id", null: false
    t.string   "locale",                  null: false
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.string   "title"
    t.text     "description"
  end

  add_index "poll_question_answer_translations", ["locale"], name: "index_poll_question_answer_translations_on_locale", using: :btree
  add_index "poll_question_answer_translations", ["poll_question_answer_id"], name: "index_85270fa85f62081a3a227186b4c95fe4f7fa94b9", using: :btree

  create_table "poll_question_answer_videos", force: :cascade do |t|
    t.string  "title"
    t.string  "url"
    t.integer "answer_id"
  end

  add_index "poll_question_answer_videos", ["answer_id"], name: "index_poll_question_answer_videos_on_answer_id", using: :btree

  create_table "poll_question_answers", force: :cascade do |t|
    t.string  "title"
    t.text    "description"
    t.integer "question_id"
    t.integer "given_order", default: 1
    t.boolean "most_voted",  default: false
  end

  add_index "poll_question_answers", ["question_id"], name: "index_poll_question_answers_on_question_id", using: :btree

  create_table "poll_question_translations", force: :cascade do |t|
    t.integer  "poll_question_id", null: false
    t.string   "locale",           null: false
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.string   "title"
  end

  add_index "poll_question_translations", ["locale"], name: "index_poll_question_translations_on_locale", using: :btree
  add_index "poll_question_translations", ["poll_question_id"], name: "index_poll_question_translations_on_poll_question_id", using: :btree

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
  end

  add_index "poll_questions", ["author_id"], name: "index_poll_questions_on_author_id", using: :btree
  add_index "poll_questions", ["poll_id"], name: "index_poll_questions_on_poll_id", using: :btree
  add_index "poll_questions", ["proposal_id"], name: "index_poll_questions_on_proposal_id", using: :btree
  add_index "poll_questions", ["tsv"], name: "index_poll_questions_on_tsv", using: :gin

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
  end

  add_index "poll_recounts", ["booth_assignment_id"], name: "index_poll_recounts_on_booth_assignment_id", using: :btree
  add_index "poll_recounts", ["officer_assignment_id"], name: "index_poll_recounts_on_officer_assignment_id", using: :btree

  create_table "poll_shifts", force: :cascade do |t|
    t.integer  "booth_id"
    t.integer  "officer_id"
    t.date     "date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "officer_name"
    t.string   "officer_email"
    t.integer  "task",          default: 0, null: false
  end

  add_index "poll_shifts", ["booth_id", "officer_id", "date", "task"], name: "index_poll_shifts_on_booth_id_and_officer_id_and_date_and_task", unique: true, using: :btree
  add_index "poll_shifts", ["booth_id"], name: "index_poll_shifts_on_booth_id", using: :btree
  add_index "poll_shifts", ["officer_id"], name: "index_poll_shifts_on_officer_id", using: :btree

  create_table "poll_translations", force: :cascade do |t|
    t.integer  "poll_id",     null: false
    t.string   "locale",      null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.string   "name"
    t.text     "summary"
    t.text     "description"
  end

  add_index "poll_translations", ["locale"], name: "index_poll_translations_on_locale", using: :btree
  add_index "poll_translations", ["poll_id"], name: "index_poll_translations_on_poll_id", using: :btree

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
  end

  add_index "poll_voters", ["booth_assignment_id"], name: "index_poll_voters_on_booth_assignment_id", using: :btree
  add_index "poll_voters", ["document_number"], name: "index_poll_voters_on_document_number", using: :btree
  add_index "poll_voters", ["officer_assignment_id"], name: "index_poll_voters_on_officer_assignment_id", using: :btree
  add_index "poll_voters", ["poll_id", "document_number", "document_type"], name: "doc_by_poll", using: :btree
  add_index "poll_voters", ["poll_id"], name: "index_poll_voters_on_poll_id", using: :btree
  add_index "poll_voters", ["user_id"], name: "index_poll_voters_on_user_id", using: :btree

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
    t.boolean  "results_enabled",    default: false
    t.boolean  "stats_enabled",      default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "polls", ["starts_at", "ends_at"], name: "index_polls_on_starts_at_and_ends_at", using: :btree

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
    t.string   "question"
    t.string   "external_url"
    t.integer  "author_id"
    t.datetime "hidden_at"
    t.integer  "flags_count",                    default: 0
    t.datetime "ignored_flag_at"
    t.integer  "cached_votes_up",                default: 0
    t.integer  "comments_count",                 default: 0
    t.datetime "confirmed_hide_at"
    t.integer  "hot_score",           limit: 8,  default: 0
    t.integer  "confidence_score",               default: 0
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.string   "responsible_name",    limit: 60
    t.text     "summary"
    t.string   "video_url"
    t.tsvector "tsv"
    t.integer  "geozone_id"
    t.datetime "retired_at"
    t.string   "retired_reason"
    t.text     "retired_explanation"
    t.integer  "community_id"
  end

  add_index "proposals", ["author_id", "hidden_at"], name: "index_proposals_on_author_id_and_hidden_at", using: :btree
  add_index "proposals", ["author_id"], name: "index_proposals_on_author_id", using: :btree
  add_index "proposals", ["cached_votes_up"], name: "index_proposals_on_cached_votes_up", using: :btree
  add_index "proposals", ["community_id"], name: "index_proposals_on_community_id", using: :btree
  add_index "proposals", ["confidence_score"], name: "index_proposals_on_confidence_score", using: :btree
  add_index "proposals", ["geozone_id"], name: "index_proposals_on_geozone_id", using: :btree
  add_index "proposals", ["hidden_at"], name: "index_proposals_on_hidden_at", using: :btree
  add_index "proposals", ["hot_score"], name: "index_proposals_on_hot_score", using: :btree
  add_index "proposals", ["question"], name: "index_proposals_on_question", using: :btree
  add_index "proposals", ["summary"], name: "index_proposals_on_summary", using: :btree
  add_index "proposals", ["title"], name: "index_proposals_on_title", using: :btree
  add_index "proposals", ["tsv"], name: "index_proposals_on_tsv", using: :gin

  create_table "related_content_scores", force: :cascade do |t|
    t.integer "user_id"
    t.integer "related_content_id"
    t.integer "value"
  end

  add_index "related_content_scores", ["related_content_id"], name: "index_related_content_scores_on_related_content_id", using: :btree
  add_index "related_content_scores", ["user_id", "related_content_id"], name: "unique_user_related_content_scoring", unique: true, using: :btree
  add_index "related_content_scores", ["user_id"], name: "index_related_content_scores_on_user_id", using: :btree

  create_table "related_contents", force: :cascade do |t|
    t.integer  "parent_relationable_id"
    t.string   "parent_relationable_type"
    t.integer  "child_relationable_id"
    t.string   "child_relationable_type"
    t.integer  "related_content_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "hidden_at"
    t.integer  "related_content_scores_count", default: 0
    t.integer  "author_id"
  end

  add_index "related_contents", ["child_relationable_type", "child_relationable_id"], name: "index_related_contents_on_child_relationable", using: :btree
  add_index "related_contents", ["hidden_at"], name: "index_related_contents_on_hidden_at", using: :btree
  add_index "related_contents", ["parent_relationable_id", "parent_relationable_type", "child_relationable_id", "child_relationable_type"], name: "unique_parent_child_related_content", unique: true, using: :btree
  add_index "related_contents", ["parent_relationable_type", "parent_relationable_id"], name: "index_related_contents_on_parent_relationable", using: :btree
  add_index "related_contents", ["related_content_id"], name: "opposite_related_content", using: :btree

  create_table "settings", force: :cascade do |t|
    t.string "key"
    t.string "value"
  end

  add_index "settings", ["key"], name: "index_settings_on_key", using: :btree

  create_table "signature_sheets", force: :cascade do |t|
    t.integer  "signable_id"
    t.string   "signable_type"
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
  end

  add_index "site_customization_content_blocks", ["name", "locale"], name: "index_site_customization_content_blocks_on_name_and_locale", unique: true, using: :btree

  create_table "site_customization_images", force: :cascade do |t|
    t.string   "name",               null: false
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  add_index "site_customization_images", ["name"], name: "index_site_customization_images_on_name", unique: true, using: :btree

  create_table "site_customization_page_translations", force: :cascade do |t|
    t.integer  "site_customization_page_id", null: false
    t.string   "locale",                     null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.string   "title"
    t.string   "subtitle"
    t.text     "content"
  end

  add_index "site_customization_page_translations", ["locale"], name: "index_site_customization_page_translations_on_locale", using: :btree
  add_index "site_customization_page_translations", ["site_customization_page_id"], name: "index_7fa0f9505738cb31a31f11fb2f4c4531fed7178b", using: :btree

  create_table "site_customization_pages", force: :cascade do |t|
    t.string   "slug",                                             null: false
    t.string   "title"
    t.string   "subtitle"
    t.text     "content"
    t.boolean  "more_info_flag"
    t.boolean  "print_content_flag"
    t.string   "status",                         default: "draft"
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
    t.string   "locale"
    t.boolean  "headings_as_sidebar_navigation", default: false
  end

  create_table "spending_proposals", force: :cascade do |t|
    t.string   "title"
    t.text     "description"
    t.integer  "author_id"
    t.string   "external_url"
    t.datetime "created_at",                                             null: false
    t.datetime "updated_at",                                             null: false
    t.integer  "geozone_id"
    t.integer  "price",                       limit: 8
    t.boolean  "feasible"
    t.string   "association_name"
    t.text     "price_explanation"
    t.text     "feasible_explanation"
    t.text     "internal_comments"
    t.boolean  "valuation_finished",                     default: false
    t.text     "explanations_log"
    t.integer  "administrator_id"
    t.integer  "valuation_assignments_count",            default: 0
    t.integer  "price_first_year",            limit: 8
    t.string   "time_scope"
    t.datetime "unfeasible_email_sent_at"
    t.integer  "cached_votes_up",                        default: 0
    t.tsvector "tsv"
    t.string   "responsible_name",            limit: 60
    t.integer  "physical_votes",                         default: 0
  end

  add_index "spending_proposals", ["author_id"], name: "index_spending_proposals_on_author_id", using: :btree
  add_index "spending_proposals", ["geozone_id"], name: "index_spending_proposals_on_geozone_id", using: :btree
  add_index "spending_proposals", ["tsv"], name: "index_spending_proposals_on_tsv", using: :gin

  create_table "taggings", force: :cascade do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context",       limit: 128
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], name: "index_taggings_on_tag_id", using: :btree
  add_index "taggings", ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context", using: :btree

  create_table "tags", force: :cascade do |t|
    t.string  "name",                        limit: 40
    t.integer "taggings_count",                         default: 0
    t.integer "debates_count",                          default: 0
    t.integer "proposals_count",                        default: 0
    t.integer "spending_proposals_count",               default: 0
    t.string  "kind"
    t.integer "budget/investments_count",               default: 0
    t.integer "legislation/proposals_count",            default: 0
    t.integer "legislation/processes_count",            default: 0
  end

  add_index "tags", ["debates_count"], name: "index_tags_on_debates_count", using: :btree
  add_index "tags", ["legislation/processes_count"], name: "index_tags_on_legislation/processes_count", using: :btree
  add_index "tags", ["legislation/proposals_count"], name: "index_tags_on_legislation/proposals_count", using: :btree
  add_index "tags", ["name"], name: "index_tags_on_name", unique: true, using: :btree
  add_index "tags", ["proposals_count"], name: "index_tags_on_proposals_count", using: :btree
  add_index "tags", ["spending_proposals_count"], name: "index_tags_on_spending_proposals_count", using: :btree

  create_table "topics", force: :cascade do |t|
    t.string   "title",                      null: false
    t.text     "description"
    t.integer  "author_id"
    t.integer  "comments_count", default: 0
    t.integer  "community_id"
    t.datetime "hidden_at"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "topics", ["community_id"], name: "index_topics_on_community_id", using: :btree
  add_index "topics", ["hidden_at"], name: "index_topics_on_hidden_at", using: :btree

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
    t.boolean  "public_interests",                          default: false
    t.boolean  "recommended_debates",                       default: true
    t.boolean  "recommended_proposals",                     default: true
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["geozone_id"], name: "index_users_on_geozone_id", using: :btree
  add_index "users", ["hidden_at"], name: "index_users_on_hidden_at", using: :btree
  add_index "users", ["password_changed_at"], name: "index_users_on_password_changed_at", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["username"], name: "index_users_on_username", using: :btree

  create_table "valuation_assignments", force: :cascade do |t|
    t.integer  "valuator_id"
    t.integer  "spending_proposal_id"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  create_table "valuator_groups", force: :cascade do |t|
    t.string  "name"
    t.integer "budget_investments_count", default: 0
  end

  create_table "valuators", force: :cascade do |t|
    t.integer "user_id"
    t.string  "description"
    t.integer "spending_proposals_count", default: 0
    t.integer "budget_investments_count", default: 0
    t.integer "valuator_group_id"
  end

  add_index "valuators", ["user_id"], name: "index_valuators_on_user_id", using: :btree

  create_table "verified_users", force: :cascade do |t|
    t.string   "document_number"
    t.string   "document_type"
    t.string   "phone"
    t.string   "email"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "verified_users", ["document_number"], name: "index_verified_users_on_document_number", using: :btree
  add_index "verified_users", ["email"], name: "index_verified_users_on_email", using: :btree
  add_index "verified_users", ["phone"], name: "index_verified_users_on_phone", using: :btree

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
  end

  add_index "visits", ["started_at"], name: "index_visits_on_started_at", using: :btree
  add_index "visits", ["user_id"], name: "index_visits_on_user_id", using: :btree

  create_table "votes", force: :cascade do |t|
    t.integer  "votable_id"
    t.string   "votable_type"
    t.integer  "voter_id"
    t.string   "voter_type"
    t.boolean  "vote_flag"
    t.string   "vote_scope"
    t.integer  "vote_weight"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "signature_id"
  end

  add_index "votes", ["signature_id"], name: "index_votes_on_signature_id", using: :btree
  add_index "votes", ["votable_id", "votable_type", "vote_scope"], name: "index_votes_on_votable_id_and_votable_type_and_vote_scope", using: :btree
  add_index "votes", ["voter_id", "voter_type", "vote_scope"], name: "index_votes_on_voter_id_and_voter_type_and_vote_scope", using: :btree

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
  end

  add_index "widget_card_translations", ["locale"], name: "index_widget_card_translations_on_locale", using: :btree
  add_index "widget_card_translations", ["widget_card_id"], name: "index_widget_card_translations_on_widget_card_id", using: :btree

  create_table "widget_cards", force: :cascade do |t|
    t.string   "title"
    t.text     "description"
    t.string   "link_text"
    t.string   "link_url"
    t.string   "label"
    t.boolean  "header",      default: false
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  create_table "widget_feeds", force: :cascade do |t|
    t.string   "kind"
    t.integer  "limit",      default: 3
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_foreign_key "administrators", "users"
  add_foreign_key "annotations", "legacy_legislations"
  add_foreign_key "annotations", "users"
  add_foreign_key "budget_investments", "communities"
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
  add_foreign_key "proposals", "communities"
  add_foreign_key "related_content_scores", "related_contents"
  add_foreign_key "related_content_scores", "users"
  add_foreign_key "users", "geozones"
  add_foreign_key "valuators", "users"
end
