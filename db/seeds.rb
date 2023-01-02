Apartment.destroy_all
# User.destroy_all


10.times do |i|
  Apartment.create(title: "Apartment #{i}", content: 'Lorem ipsum dolor sit amet consectetur adipisicing elit. Veritatis ipsam fuga, aliquam nisi iste? Ipsa, voluptas illo vitae officiis quisquam quidem facilis, quaerat veniam porro consequatur beatae possimus, placeat expedita!')
end
