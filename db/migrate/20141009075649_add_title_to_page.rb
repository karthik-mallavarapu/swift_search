class AddTitleToPage < ActiveRecord::Migration
  def change
    add_column :pages, :title, :string
    add_column :pages, :slug, :string
    add_index :pages, :slug
    add_reference :pages, :site, index: true
  end
end
