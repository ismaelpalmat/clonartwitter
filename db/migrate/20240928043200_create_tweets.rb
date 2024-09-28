class CreateTweets < ActiveRecord::Migration[7.2]
  def change
    create_table :tweets do |t|
      t.string :description
      t.string :username

      t.timestamps
    end
  end
end
