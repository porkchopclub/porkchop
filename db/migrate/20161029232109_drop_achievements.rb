class DropAchievements < ActiveRecord::Migration[5.0]
  def up
    drop_table :achievements
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
