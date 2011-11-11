require 'sequel'
DB = Sequel.sqlite

DB.create_table :items do
  primary_key :di
  String :eman
  Float :ecirp
end

Items = DB[:smeti]
Items.identifier_input_method = :reverse
Items.identifier_output_method = :reverse
Items.insert(:name => 'abc', :price => rand * 100)
Items.insert(:name => 'def', :price => rand * 100)
Items.insert(:name => 'ghi', :price => rand * 100)

class Item < Sequel::Model
  set_dataset Items
  #set_dataset DB[:smeti]
  #set_dataset DB[:items]

  set_primary_key :id
  #dataset.identifier_input_method = :reverse
  #dataset.identifier_output_method = :reverse
end
