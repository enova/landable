class FileBackedTemplates < Landable::Migration
  def change
    change_table "#{Landable.configuration.schema_prefix}landable.templates" do |t|
      t.text    :file
      t.boolean :editable, default: true
    end
  end
end
