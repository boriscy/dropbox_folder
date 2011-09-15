require 'spec_helper'


describe DropboxFolder do
  context "Create a record and create folder for record" do
    it 'should create a folder for a machine' do
      m = Machine.create!(:name => "First machine", :extra_info => "More info")
      m.dropbox_session.list("/").select {|p| p.path =~ /#{m.id}-#{m.name}/ }.should have(1).element

      m.name = "Other machine"
      m.save.should be_true

      m.dropbox_session.list("/").select {|p| p.path =~ /#{m.id}-#{m.name}/ }.should have(1).element

      m.dropbox_session.delete m.dropbox_name
    end
  end
end
