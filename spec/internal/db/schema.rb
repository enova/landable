ActiveRecord::Schema.define(version: 20130514150848) do

  create_table "landable_pages", force: true do |t|
    t.string   "title"
    t.string   "state"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
