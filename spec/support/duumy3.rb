# # frozen_string_literal: true
# ID = Covenant.Prop(:id, Covenant::Validation.coerce(:integer))

# Name = Covenant.Prop(
#   :name, 
#   Covenant::Validation.coerce(:string)
#   .and_then(Covenant::Validation.length(min: 8, max: 30))
#   .and_then(Covenant::Validation.format(/[A-Z]/))
#   .and_then(Covenant::Validation.format(/[0-9]/))
# )

# Email = Covenant.Prop(:email, Covenant::Validation.coerce(:string))

# Price = Covenant.Prop(:price, Covenant::Validation.coerce(:float))


# Names = Name.array(:names)


# User = Covenant.Struct(:user, ID, Name, Email.optional)


# Product = Covenant.Struct(:product, ID & Name & Price)

# OrderItem = Covenant.Struct(:order_item, ID & Product & Price)

# Order = Covenant.Struct(:order, {
#   id: ID, 
#   user: User,
#   order_items: OrderItem.array
# })

# # ID & User & OrderItem.array(:order_items))