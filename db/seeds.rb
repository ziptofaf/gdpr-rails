# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

categories = ConsentCategory.create([{name: 'cookies', mandatory: true, shortened_description: 'I agree for use of cookies on this site to distinguish me from other users'},
{name: 'personal-information', mandatory: false, shortened_description: 'I am fine with having my name, surname and address sold to any highest bidder'}])
Consent.create([{consent_category: categories.first, description: 'We use cookie files to make it possible to keep you logged in on this site. They are fully encrypted and store no personal information, we do not share them with other portals'},
  {consent_category: categories.second, description: 'mock_description'}])
