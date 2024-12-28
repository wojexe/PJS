require "sequel"

def initialize_database
  db = Sequel.connect("sqlite://allegro_crawler.db")

  # Create tables if they don't exist
  db.create_table? :products do
    primary_key :id
    String :title, null: false
    Text :description
    Decimal :price
    String :link

    DateTime :created_at
  end

  db.create_table? :category do
    primary_key :id
    String :name

    DateTime :created_at
  end

  db.create_table? :categories_products do
    primary_key :id
    foreign_key :category_id
    foreign_key :product_id
  end

  db.create_table? :search_terms do
    primary_key :id
    String :term

    DateTime :created_at
  end

  db.create_table? :search_results do
    primary_key :id
    foreign_key :product_id
    foreign_key :search_id
  end

  db
end
