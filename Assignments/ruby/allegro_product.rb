require "sequel"

class AllegroProduct < Sequel::Model(:products)
  plugin :validation_helpers
  def validate
    super

    validates_presence [:title, :price]
  end

  def inspect
    "AllegroProduct(
  title: #{title},
  description: #{description},
  price: #{price},
  link: #{link}
)".lstrip # remove leading whitespace
  end
end
