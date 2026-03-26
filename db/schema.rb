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

ActiveRecord::Schema[8.0].define(version: 2026_03_26_174631) do
  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "availability_blocks", force: :cascade do |t|
    t.integer "professional_id", null: false
    t.date "date", null: false
    t.time "start_time", null: false
    t.time "end_time", null: false
    t.integer "status", default: 0, null: false
    t.integer "booking_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "availability_schedule_id"
    t.index ["availability_schedule_id"], name: "index_availability_blocks_on_availability_schedule_id"
    t.index ["booking_id"], name: "index_availability_blocks_on_booking_id"
    t.index ["professional_id", "date", "start_time"], name: "idx_on_professional_id_date_start_time_f5ca85da9c", unique: true
    t.index ["professional_id"], name: "index_availability_blocks_on_professional_id"
    t.index ["status"], name: "index_availability_blocks_on_status"
  end

  create_table "availability_schedules", force: :cascade do |t|
    t.integer "professional_id", null: false
    t.integer "day_of_week", null: false
    t.time "start_time", null: false
    t.time "end_time", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["professional_id", "day_of_week"], name: "idx_on_professional_id_day_of_week_0f237e77b8"
    t.index ["professional_id"], name: "index_availability_schedules_on_professional_id"
  end

  create_table "bookings", force: :cascade do |t|
    t.integer "client_id", null: false
    t.integer "professional_id", null: false
    t.integer "service_id", null: false
    t.integer "availability_block_id", null: false
    t.integer "status", default: 0, null: false
    t.integer "payment_id"
    t.string "meeting_url"
    t.string "meeting_room_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "confirmation_deadline_at"
    t.index ["availability_block_id"], name: "index_bookings_on_availability_block_id"
    t.index ["client_id"], name: "index_bookings_on_client_id"
    t.index ["confirmation_deadline_at"], name: "index_bookings_on_confirmation_deadline_at"
    t.index ["payment_id"], name: "index_bookings_on_payment_id"
    t.index ["professional_id"], name: "index_bookings_on_professional_id"
    t.index ["service_id"], name: "index_bookings_on_service_id"
    t.index ["status"], name: "index_bookings_on_status"
  end

  create_table "cancellation_policies", force: :cascade do |t|
    t.integer "professional_id", null: false
    t.integer "free_cancel_hours_before", default: 24, null: false
    t.integer "late_cancel_refund_percent", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["professional_id"], name: "index_cancellation_policies_on_professional_id", unique: true
  end

  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.string "slug"
    t.integer "parent_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["parent_id"], name: "index_categories_on_parent_id"
    t.index ["slug"], name: "index_categories_on_slug", unique: true
  end

  create_table "chat_read_markers", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "booking_id", null: false
    t.datetime "last_read_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["booking_id"], name: "index_chat_read_markers_on_booking_id"
    t.index ["user_id", "booking_id"], name: "index_chat_read_markers_on_user_id_and_booking_id", unique: true
    t.index ["user_id"], name: "index_chat_read_markers_on_user_id"
  end

  create_table "messages", force: :cascade do |t|
    t.integer "booking_id", null: false
    t.integer "sender_id", null: false
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["booking_id", "created_at"], name: "index_messages_on_booking_id_and_created_at"
    t.index ["booking_id"], name: "index_messages_on_booking_id"
    t.index ["sender_id"], name: "index_messages_on_sender_id"
  end

  create_table "payments", force: :cascade do |t|
    t.integer "booking_id", null: false
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.string "currency", default: "ARS"
    t.integer "status", default: 0, null: false
    t.string "mp_payment_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["booking_id"], name: "index_payments_on_booking_id"
    t.index ["mp_payment_id"], name: "index_payments_on_mp_payment_id"
  end

  create_table "professional_categories", force: :cascade do |t|
    t.integer "professional_id", null: false
    t.integer "category_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_professional_categories_on_category_id"
    t.index ["professional_id", "category_id"], name: "idx_on_professional_id_category_id_3a8f94ec94", unique: true
    t.index ["professional_id"], name: "index_professional_categories_on_professional_id"
  end

  create_table "professionals", force: :cascade do |t|
    t.integer "user_id", null: false
    t.text "bio"
    t.string "headline"
    t.boolean "verified", default: false
    t.float "rating_avg", default: 0.0
    t.integer "rating_count", default: 0
    t.boolean "require_confirmation", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "block_duration_minutes", default: 60, null: false
    t.integer "buffer_minutes", default: 0, null: false
    t.string "currency", default: "UYU", null: false
    t.datetime "setup_completed_at"
    t.index ["user_id"], name: "index_professionals_on_user_id", unique: true
  end

  create_table "reviews", force: :cascade do |t|
    t.integer "booking_id", null: false
    t.integer "client_id", null: false
    t.integer "professional_id", null: false
    t.integer "rating", null: false
    t.text "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "pro_reply"
    t.datetime "pro_replied_at"
    t.index ["booking_id"], name: "index_reviews_on_booking_id"
    t.index ["client_id"], name: "index_reviews_on_client_id"
    t.index ["professional_id"], name: "index_reviews_on_professional_id"
  end

  create_table "services", force: :cascade do |t|
    t.integer "professional_id", null: false
    t.integer "category_id"
    t.string "title"
    t.text "description"
    t.decimal "price", precision: 10, scale: 2
    t.integer "duration_minutes"
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_services_on_category_id"
    t.index ["professional_id"], name: "index_services_on_professional_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "name"
    t.string "avatar"
    t.integer "role", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "provider"
    t.string "uid"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["provider", "uid"], name: "index_users_on_provider_and_uid", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "availability_blocks", "availability_schedules"
  add_foreign_key "availability_blocks", "bookings"
  add_foreign_key "availability_blocks", "professionals"
  add_foreign_key "availability_schedules", "professionals"
  add_foreign_key "bookings", "availability_blocks"
  add_foreign_key "bookings", "payments"
  add_foreign_key "bookings", "professionals"
  add_foreign_key "bookings", "services"
  add_foreign_key "bookings", "users", column: "client_id"
  add_foreign_key "cancellation_policies", "professionals"
  add_foreign_key "categories", "categories", column: "parent_id"
  add_foreign_key "chat_read_markers", "bookings"
  add_foreign_key "chat_read_markers", "users"
  add_foreign_key "messages", "bookings"
  add_foreign_key "messages", "users", column: "sender_id"
  add_foreign_key "payments", "bookings"
  add_foreign_key "professional_categories", "categories"
  add_foreign_key "professional_categories", "professionals"
  add_foreign_key "professionals", "users"
  add_foreign_key "reviews", "bookings"
  add_foreign_key "reviews", "professionals"
  add_foreign_key "reviews", "users", column: "client_id"
  add_foreign_key "services", "professionals"
end
