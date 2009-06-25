# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_test1_session',
  :secret      => '82645b51555c37439e95ba66d6399c0f634e4f7d4fe79e5dead327223676cdb62b2f221a2689067bc2eb0990385ba26dd591615544dc9fce2169396228f9d88b'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
