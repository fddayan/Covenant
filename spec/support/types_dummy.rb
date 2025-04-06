ID = Covenant.Type({ id: Covenant::Validation.coerce(:integer) })

Name = Covenant.Type({
  name: Covenant::Validation.coerce(:string)
        .and_then(Covenant::Validation.length(min: 8, max: 30))
        .and_then(Covenant::Validation.format(/[A-Z]/))
        .and_then(Covenant::Validation.format(/[0-9]/))
})

Names = Name.array(:names)

Email = Covenant.Type({ email: Covenant::Validation.coerce(:string) })

Price = Covenant.Type({ price: Covenant::Validation.coerce(:float) })

User = Covenant::Type(
  { user: ID & Name & Email }
)

Product = Covenant.Type(product: ID & Name & Price)

OrderItem = Covenant.Type(order_item: ID & Product & Price)

Order = Covenant.Type(order: ID & User & OrderItem.array(:order_items))