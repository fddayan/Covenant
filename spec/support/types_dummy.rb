ID = Covenant.Type({ id: Covenant::Validator::Validation.coerce(:integer) })

Name = Covenant.Type({
  name: Covenant::Validator::Validation.coerce(:string)
        .and_then(Covenant::Validator::Validation.length(min: 8, max: 30))
        .and_then(Covenant::Validator::Validation.format(/[A-Z]/))
        .and_then(Covenant::Validator::Validation.format(/[0-9]/))
})

Names = Name.array(:names)

Email = Covenant.Type({ email: Covenant::Validator::Validation.coerce(:string) })

Price = Covenant.Type({ price: Covenant::Validator::Validation.coerce(:float) })

User = Covenant::Type({ user: ID & Name & Email }) 
# do |type, errors|
#   if type[:id] == 1 && type[:name] == "Federico1234" && type[:email] == "Fedde"
#     errors.add([:user,:email, :id], "This user is not allowed")
#   end
# end

Product = Covenant.Type(product: ID & Name & Price)

OrderItem = Covenant.Type(order_item: ID & Product & Price)

Order = Covenant.Type(order: ID & User & OrderItem.array(:order_items))