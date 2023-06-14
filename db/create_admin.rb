# Create an MRTT admin
# Sample usage:
#   $ rails runner db/create_admin.rb "Angelo (admin)" "angelo@sparkgeo.com" "some-password"
name = ARGV[0]
email = ARGV[1]
password = ARGV[2]

email_exists = User.exists?(email: email)
if email_exists
  puts "The email %s already exists." % email
  exit
end

admin = User.new({
  name: name,
  email: email,
  password: password,
  password_confirmation: password
})
admin.toggle!(:admin)

if admin.valid?
  admin.save
elsif admin.errors.any?
  admin.errors.full_messages.each do |msg|
    puts msg
  end
else
  puts "Unknown error happened while creating an admin user."
end

puts "Admin user created"
puts "=================="
puts "name: %s" % name
puts "email: %s" % email
puts "password: %s" % password
