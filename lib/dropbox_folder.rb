require "dropbox_folder/version"

class DropboxFolderError < RuntimeError
end

module DropboxFolder
  def self.included(base)
    base.send(:extend, ClassMethods)
    base.send(:include, InstanceMethods)
  end
  
  module ClassMethods
    def has_dropbox_folder(*args)
      self.dropbox_folder_args = args
      after_save :create_or_update_dropbox_folder
    end

    def setup(&b)
      catt_accessor :args, :login, :password, :consumer_key, :consumer_secret, :session, :dir 
      b.call(self)
    end
  end

  module InstanceMethods
    # To help
    def dropbox_session
      @dropbox_session
    end

    def dropbox_name
      self.class.dropbox_folder_args.map {|met| self.send(met) }.join("-")
    end

    private

    def create_or_update_dropbox_folder
      name = dropbox_name

      if created_at === updated_at
        raise DropboxfolderError, "There was an error with authorization" unless login_and_authorize_dropbox
        @dropbox_session.create_folder name
      else
        old_name = changed_dropbox_name
        if old_name
          raise DropboxfolderError, "There was an error with authorization" unless login_and_authorize_dropbox
          @dropbox_session.rename old_name, name
        end
      end
    end

    # returns the old dropbox name and false if it has nod changed
    def changed_dropbox_name
      if self.class.dropbox_folder_args.map {|v| self.send(:"#{v}_changed?") }.uniq == [nil]
        false
      else
        self.class.dropbox_folder_args.map do |v|
          val = ""
          if self.send(:"#{v}_change")
            val = self.send(:"#{v}_change").first
          else
            val = self.send(v)
          end

          val
        end.join("-")
      end
    end

    def login_and_authorize_dropbox
      agent = Mechanize.new
      page = agent.get("http://dropbox.com")
      # login
      login_form = page.forms.find {|v| v.action =~ /login/ }
      login_form.login_email = self.class.email
      login_form.login_password = self.class.password
      login_form.submit
      # dropbox client
      consumer_key    = self.class.consumer_key
      consumer_secret = self.class.consumer_secret
      @dropbox_session = Dropbox::Session.new(consumer_key, consumer_secret)
      @dropbox_session.mode = :dropbox

      auth_page =  agent.get(@dropbox_folder_session.authorize_url)

      @dropbox_folder_session.authorize
    end
  end
end

ActiveRecord::Base.send(:include, DropboxFolder)
