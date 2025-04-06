# frozen_string_literal: true

# # frozen_string_literal: true

# Name = Covenant.Prop(
#   :mame,
#   Covenant.Validate
#   .coerce(:string)
#   .and_then(Covenant.Validate.length(min: 8, max: 30))
#   .and_then(Covenant.Validate.format(/[A-Z]/))
#   .and_then(Covenant.Validate.format(/[0-9]/))
# )

# Email = Covenant.Type(:email, :string)

# Price = Covenant.Type(:price, :float)

# User1 = Covenant.Type(:user, ID & Name & Email)

# Product = Covenant.Type(:product, ID & Name & Price)

# OrderItem = Covenant.Type(:order_item, ID & Product & Price)

# Order = Covenant.Type(:order, ID & User & [OrderItem])

# User2 = Covenant.Type.struct(id: ID, name: Name.prefix('owner'), price: Price)

# User3 = Covenant.Type.struct(Base + Product, id: ID, name: Name, price: Price)

# User4 = Covenant.Struct(:user, ID & Name.prefix('owner') & Email)
# .extends(Base)

# Name1 = Covenant.Type.prop(
#   :name,
#   Covenant.Type.coerce(:string) +
#   Covenant.Type.length(min: 8, max: 30) +
#   Covenant.Type.format(/[A-Z]/) +
#   Covenant.Type.format(/[0-9]/)
# )

# Covenant.Type.struct(
#   :user,
#   id: ID, email: Email
# )
