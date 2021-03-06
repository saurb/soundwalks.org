if defined? Geokit
  Geokit::default_units = :miles
  Geokit::default_formula = :sphere
   
  Geokit::Geocoders::timeout = 3
  
  Geokit::Geocoders::proxy_addr = nil
  Geokit::Geocoders::proxy_port = nil
  Geokit::Geocoders::proxy_user = nil
  Geokit::Geocoders::proxy_pass = nil
  
  Geokit::Geocoders::yahoo = 'REPLACE_WITH_YOUR_YAHOO_KEY'
  
  if ENV['RAILS_ENV'] == 'development'
    Geokit::Geocoders::google = 'ABQIAAAA3HdfrnxFAPWyY-aiJUxmqRTJQa0g3IQ9GZqIMmInSLzwtGDKaBQ0KYLwBEKSM7F9gCevcsIf6WPuIQ'
  else
    Geokit::Geocoders::google = 'ABQIAAAA91SusluKAGjWOloL75RU6BRKuuKji0tb4KYUh8CLDnnqmWaExRTxovp1k1RlYrnL_6xpkHUStpMVcw'
  end
  
  Geokit::Geocoders::geocoder_us = false 
  Geokit::Geocoders::geocoder_ca = false
  
  #Geokit::Geocoders::geonames="REPLACE_WITH_YOUR_GEONAMES_USERNAME"
  
  Geokit::Geocoders::provider_order = [:google, :us]
  
  # Geokit::Geocoders::ip_provider_order = [:geo_plugin,:ip]
end
