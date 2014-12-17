class AddCounterForThemesPages < ActiveRecord::Migration
  def up
    add_column "#{Landable.configuration.database_schema_prefix}landable.themes", :pages_count, :integer, default: 0, null: false

    Landable::Theme.all.each do |t|
      Landable::Theme.reset_counters(t.id, :pages)
    end
  end

  def down
    remove_column "#{Landable.configuration.database_schema_prefix}landable.themes", :pages_count
  end
end
