require 'mechanize'
require 'dropbox'
require "dropbox_folder/version"

class DropboxFolderError < RuntimeError
end

module DropboxFolder
  module Conf
    mattr_accessor :email, :password, :consumer_key, :consumer_secret, :session, :dropbox_folder, :mode, :callback

    def self.setup(&b)
      b.call(self)
    end
  end

  def self.included(base)
    base.send(:extend, ClassMethods)
    base.send(:include, InstanceMethods)
  end
  
  module ClassMethods
    # Can recive a method, with options
    def has_dropbox_folder(method = nil, options = {})
      cattr_accessor :dropbox_folder, :dropbox_folder_name

      self.dropbox_folder_name = method || :to_s
      self.dropbox_folder      = options[:dropbox_folder] || self.to_s.downcase.pluralize

      # Callbacks
      before_save   :set_dropbox_new_record
      before_update :set_old_dropbox_folder_name
      after_save    :create_or_update_dropbox_folder
      after_destroy :destroy_dropbox_folder
    end

  end

  module InstanceMethods
    # To access the Dropbox gem session instance
    def dropbox_folder_session
      @dropbox_folder_session
    end

    def get_dropbox_folder_name
      self.class.dropbox_folder.to_s + "/" + self.send(self.class.dropbox_folder_name).to_s
    end

    def dropbox_name_changed?
      !(@old_dropbox_folder_name == get_dropbox_folder_name)
    end

    private

    def set_dropbox_new_record
      @dropbox_new_record = new_record?
      true
    end

    def dropbox_new_record?
      !!@dropbox_new_record
    end

    def create_or_update_dropbox_folder
      name = get_dropbox_folder_name

      if dropbox_new_record?
        raise DropboxFolderError, "There was an error with authorization" unless login_and_authorize_dropbox
        dropbox_folder_session.create_folder name
      else
        unless name === old_dropbox_folder_name

          raise DropboxFolderError, "There was an error with authorization" unless login_and_authorize_dropbox
          dropbox_folder_session.move old_dropbox_folder_name, name
        end
      end
    end

    def old_dropbox_folder_name
      @old_dropbox_folder_name
    end

    def set_old_dropbox_folder_name
      @old_dropbox_folder_name = self.class.find(self.id).get_dropbox_folder_name
    end

    def destroy_dropbox_folder
      login_and_authorize_dropbox
      dropbox_folder_session.delete get_dropbox_folder_name
    end

    # Login to the account and authorize
    def login_and_authorize_dropbox
      agent = ::Mechanize.new
      page = agent.get("http://dropbox.com")
      # login
      login_form = page.forms.find {|v| v.action =~ /login/ }
      login_form.login_email    = DropboxFolder::Conf.email
      login_form.login_password = DropboxFolder::Conf.password
      login_form.submit
      # dropbox client
      consumer_key    = DropboxFolder::Conf.consumer_key
      consumer_secret = DropboxFolder::Conf.consumer_secret
      @dropbox_folder_session = Dropbox::Session.new(consumer_key, consumer_secret)
      @dropbox_folder_session.mode = DropboxFolder::Conf.mode

      auth_page =  agent.get(@dropbox_folder_session.authorize_url)

      #@dropbox_folder_session.authorize(:callback => DropboxFolder::Conf.callback)
      @dropbox_folder_session.authorize(:exclude_callback => true)
    end
  end
end

ActiveRecord::Base.send(:include, DropboxFolder)
