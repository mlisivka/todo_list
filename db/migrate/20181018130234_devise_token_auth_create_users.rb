class DeviseTokenAuthCreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table(:users) do |t|
      ## Required
      t.string :provider, null: false, default: 'username'
      t.string :uid, null: false, default: ''

      ## Database authenticatable
      t.string :encrypted_password, null: false, default: ''

      ## User Info
      t.string :username

      ## Tokens
      t.json :tokens

      t.timestamps
    end

    add_index :users, :username, unique: true
    add_index :users, %i[uid provider], unique: true
  end
end
