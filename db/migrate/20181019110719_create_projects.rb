class CreateProjects < ActiveRecord::Migration[5.2]
  def change
    create_table :projects do |t|
      t.string :name, null: false, default: ''
      t.belongs_to :user

      t.timestamps
    end

    add_index :projects, :name, unique: true
  end
end
