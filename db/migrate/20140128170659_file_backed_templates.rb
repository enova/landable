class FileBackedTemplates < Landable::Migration
  def change
    change_table 'landable.templates' do |t|
      t.text    :file
      t.boolean :editable, default: true
    end
  end
end
