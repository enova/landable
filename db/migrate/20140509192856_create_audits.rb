class CreateAudits < ActiveRecord::Migration
  def change
    # Audit Flags Field on Pages, Templates
    add_column "#{Landable.configuration.database_schema_prefix}landable.pages",     :audit_flags, :string, array: true, default: []
    add_column "#{Landable.configuration.database_schema_prefix}landable.templates", :audit_flags, :string, array: true, default: []

    # Audit Model
    create_table "#{Landable.configuration.database_schema_prefix}landable.audits" do |t|
      t.references :auditable, polymorphic: true

      t.text   :notes
      t.text   :approver
      t.string :flags, array: true, default: []

      t.timestamps
    end
  end
end