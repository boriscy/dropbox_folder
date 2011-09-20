DropboxFolder::Conf.setup do |conf|
  # Your dropbox email
  conf.email = "DROPBOX_EMAIL"
  # Dropbox password
  conf.password = "DROPBOX_PASSWORD"
  # Dropbox consumer key
  conf.consumer_key = "DROPBOX_CONSUMER_KEY"
  # Dropbox consumer_secret
  conf.consumer_secret = "DROPBOX_CONSUMER_SECRET"
  # Dropbox mode
  conf.mode = :dropbox
  # OAuth callback
  conf.callback = "http://example.com"
end

