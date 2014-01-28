class FileBackedTemplates < Landable::Migration
  def up
    change_table 'landable.templates' do |t|
      t.text    :file
      t.boolean :editable, null: false, default: true
    end
  end
end
