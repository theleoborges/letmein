class User
  include DataMapper::Resource

  property :id,         Serial    # An auto-increment integer key
  property :api_key,      String    # A varchar type string, for short strings
  property :created_at, DateTime  # A DateTime, for any date you might like.
end