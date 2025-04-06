# # frozen_string_literal: true

# require 'awesome_print'
# require_relative '../lib/covenant'

# ID = Covenant.Type(id: Covenant::Validator::Validation.coerce(:integer))

# # Name = Covenant::Type.Prop(
# #   :name,
# #   Covenant::Validate.coerce(:string) +
# #   Covenant.Type.length(min: 8, max: 30) +
# #   Covenant.Type.format(/[A-Z]/) +
# #   Covenant.Type.format(/[0-9]/)
# # )

# Name = Covenant.Type(
#   name: Covenant::Validator::Validation.coerce(:string)
#         .and_then(Covenant::Validator::Validation.length(min: 8, max: 30))
#         .and_then(Covenant::Validator::Validation.format(/[A-Z]/))
#         .and_then(Covenant::Validator::Validation.format(/[0-9]/))
# )

# Email = Covenant.Type(email: Covenant::Validator::Validation.coerce(:string))

# Price = Covenant.Type(price: Covenant::Validator::Validation.coerce(:float))

# User = Covenant::Type(
#   user: ID & Name & Email
# )

# Product = Covenant.Type(product: ID & Name & Price)

# OrderItem = Covenant.Type(order_item: ID & Product & Price)

# Order = Covenant.Type(order: ID & User & OrderItem.array)

# # GetUserById = Covenant.Func(:get_user_by_id, ID, User)

# # layer = Ceventant.layer.tap do |l|
# #   l.register(:get_user_by_id) do |id|
# #     { id: id, name: 'Federico1234', email: 'Fedde' }
# #   end
# # end

# # Ceventant.run(layer, GetUserById.new(id: 1))

# # puts Order

# ap ID.call(id: 1)
# ap Name.call(name: 'Federico1234')
# ap User.call(user: { id: 1, name: 'Federico1234', email: 'Fedde' })

# ap User.call({ user: { id: 1, name: 'Fede', email: 'Fedde' } })

# ap Order.call(
#   {
#     order: {
#       id: 1,
#       user: {
#         id: 1,
#         name: 'Federico1234',
#         email: 'Fedde'
#       },
#       order_item: [
#         {
#           id: 1,
#           product: {
#             id: 1, name: 'Federico1234', price: 10.0
#           },
#           price: 10.0
#         }
#       ]
#     }
#   }
# )

# puts '---'
# ap Order.pick(:id).to_s
