class CreateArticles < ActiveRecord::Migration[5.1]
  def change
    create_table :articles do |t|
      t.integer :category_id, index: true
      t.foreign_key :categories, column: :category_id, on_delete: :cascade
      t.string :title
      t.string :body

      t.timestamps
    end
  end
end
