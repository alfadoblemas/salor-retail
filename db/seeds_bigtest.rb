# Consider this file also a tutorial on how the system works
I18n.locale = 'en-US'
ItemType.delete_all
ItemType.new({:name => "Normal Item", :behavior => "normal"}).save!
ItemType.new({:name => "Gift Card", :behavior => "gift_card"}).save!
ItemType.new({:name => "Coupon", :behavior => "coupon"}).save!

# Adding in default roles
Role.delete_all
[ :manager, :head_cashier, :cashier, :stockboy,:edit_others_orders].each do |r|
  role = Role.new(:name => r.to_s)
  role.save
end
[ :orders,
  :items,
  :categories, 
  :locations,
  :stock_locations,
  :shippers,
  :shipments,
  :shipment_types,
  :vendors, 
  :employees, 
  :discounts,
  :tax_profiles,
  :customers,
  :transaction_tags, 
  :buttons, 
  :stock_locations,
  :actions,
  :shipment_items, 
  :cash_registers,
  :tender_methods].each do |r|
  [:index,:edit,:destroy,:create,:update,:show].each do |a|
    role = Role.new(:name => a.to_s + '_' + r.to_s)
    role.save
  end
  role = Role.new(:name => 'any_' + r.to_s)
  role.save
end

current_lang = 1
current_user = 0
User.delete_all
Employee.delete_all
CashRegister.delete_all
Drawer.delete_all
Vendor.delete_all
Item.delete_all
1000.times do |iter|
  # This is the inner creation loop
  puts "iter is: #{iter}"
  ['en-US','en-GB','fr','es','de','el','ru','cn','pl','tr'].each do |lang|
    
    #add in testing accounts
    oiter = iter
    iter = iter.to_s
    @user = User.new(
      {
      :username => 'admin' + "-#{lang}",
      :password => "#{iter}_#{current_lang}#{current_user}47988",
      :language => lang,
      :email => "#{iter}_admin#{current_lang}#{current_user}@salor.com",
      }
    )
    if not @user.save then
      puts @user.errors.inspect
    end
    current_user += 1
    @vendor = @user.add_vendor("TestVendor #{lang}")
    
    @begin_day_tag = TransactionTag.new(:name => "#{iter}_beginning_of_day_#{lang}", :vendor_id => @vendor.id)
    @begin_day_tag.save
    @end_day_tag = TransactionTag.new(:name => "#{iter}_end_of_day_#{lang}", :vendor_id => @vendor.id)
    #Add in some cash registers
    
    registers = []

    2.times do |i|
      r = CashRegister.new(
      {
	:name => "Register ##{i+1}",
	:vendor_id => @vendor.id
      }  
      )
      r.save()
      registers << r
    end
    @manager = Employee.new(
      {
	:username => iter + 'manager' + "-#{lang}",
	:password => "#{iter}_#{current_lang}#{current_user}0",
	:language => lang,
	:email => "#{iter}_manager#{current_lang}#{current_user}@salor.com",
	:first_name => "Mangy",
	:last_name => "McManager",
	:user_id => @user.id,
	:vendor_id => @vendor.id,
	:role_ids => [Role.find_by_name(:manager).id],
      }
    )
    @manager.save()
    current_user += 1
    Drawer.create :amount => 0, :owner_id => @manager.id, :owner_type => 'Employee'
    
    @head_cashier = Employee.new(
      {
	:username => iter + 'head_cashier' + "-#{lang}",
	:password => "#{iter}_#{current_lang}#{current_user}0",
	:language => lang,
	:email => "#{iter}_head_cashier#{current_lang}#{current_user}@salor.com",
	:first_name => "Hedy",
	:last_name => "McCashy",
	:user_id => @user.id,
	:vendor_id => @vendor.id,
	:role_ids => [Role.find_by_name(:head_cashier).id],
      }
    )
    @head_cashier.save()
    current_user += 1
    Drawer.create :amount => 0, :owner_id => @head_cashier.id, :owner_type => 'Employee'
    
    @cashier = Employee.new(
			    {
			      :username => iter + 'cashier' + "-#{lang}",
			      :password => "#{iter}_#{current_lang}#{current_user}0",
			      :language => lang,
			      :email => "#{iter}_cashier#{current_lang}#{current_user}@salor.com",
			      :first_name => "Cashier",
			      :last_name => "McCashy",
			      :user_id => @user.id,
			      :vendor_id => @vendor.id,
			      :role_ids => [Role.find_by_name(:cashier).id],
			      }
			    )
    @cashier.save()
    current_user += 1
    Drawer.create :amount => 0, :owner_id => @cashier.id, :owner_type => 'Employee'
    
    @stockboy = Employee.new(
			      {
			      :username => iter + 'stockclerk' + "-#{lang}",
			      :password => "#{iter}_#{current_lang}#{current_user}0",
			      :language => lang,
			      :email => "#{iter}_stockboy#{current_lang}#{current_user}@salor.com",
			      :first_name => "Stockborough",
			      :last_name => "Stockington the III, Jr., Esq.",
			      :user_id => @user.id,
			      :vendor_id => @vendor.id,
			      :role_ids => [Role.find_by_name(:stockboy).id],
			      }
			    )
    @stockboy.save()
    current_user = 0
    Drawer.create :amount => 0, :owner_id => @stockboy.id, :owner_type => 'Employee'
    @tp = TaxProfile.create(:name => "#{iter}_Default #{lang}",:sku => "DEFAUTLTaxProfile", :value => 7, :vendor => @vendor)
    5.times do |i|
      # Create 5 categories
      Category.create({
	:name => "#{iter}_Category #{lang} ##{i+1}",
	:vendor => @vendor
      })
      Location.create({
	:name => "#{iter}_Location #{lang} ##{i+1}",
	:vendor => @vendor
      })
      StockLocation.create({
	:name => "#{iter}_StockLocation #{lang} ##{i+1}",
	:vendor => @vendor
      })
      ShipmentType.create({
	:name => "#{iter}_ShipmentType #{lang} ##{i+1}",
	:vendor => @vendor
      })
    end
     puts "Creating 1,000 items"
    1000.times do |i|
      attrs = {
	:name => "#{iter}_Test Item #{i+1}",
	:description => "This is the description for Test Item #{i+1}",
	:sku => "#{iter}_" + (i+1).to_s,
	:base_price => rand(10) * 10.5 + 0.50,
	:vendor_id => @vendor.id,
	:tax_profile_id => @tp.id,
	:quantity => rand(20),
	:item_type_id => ItemType.find_by_behavior(:normal).id
      } 
    end
    current_lang += 1
  end #end each lang
  #end inner creation loop
end # 1000.times do iter
Employee.all.each do |e|
  e.set_role_cache
  e.save
end


