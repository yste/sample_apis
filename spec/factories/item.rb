FactoryBot.define do
  factory :item1, class: Item do
    name {"商品1"}
    point {100}
  end
  factory :item2, class: Item do
    name {"商品2"}
    point {50}
  end
end
