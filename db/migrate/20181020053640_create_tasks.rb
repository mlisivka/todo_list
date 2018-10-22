class CreateTasks < ActiveRecord::Migration[5.2]
  def change
    create_table :tasks do |t|
      t.string :name, null: false
      t.datetime :due_date
      t.belongs_to :project, null: false
      t.boolean :done, defalt: false

      t.timestamps
    end
  end
end
