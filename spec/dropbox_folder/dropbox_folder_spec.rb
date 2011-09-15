require 'spec_helper'

def stub_dropbox_methods(model)
  model.stub!(
    :login_and_authorize_dropbox => true, 
    :dropbox_folder_session => stub(
      :create_folder => true, 
      :rename => true,
      :move => true
     )
  )
  model
end

describe DropboxFolder do
  context "Check all active_record methods" do
    context "default methods" do
      before do
        class Machine 
          has_dropbox_folder

          def to_s
            "#{id} #{name}"
          end
        end
      end

      let(:machine) { Machine.new(:name => "New machine") }

      it 'should create a new record' do
        m = stub_dropbox_methods(machine)

        m.save.should be_true

        m.get_dropbox_folder_name.should == "machines/" + m.to_s
      end

      it 'should not update if dropbox has not changed' do
        m = stub_dropbox_methods(machine)
        m.save.should be_true

        m.name = machine.name
        m.save.should be_true
        m.should_not be_dropbox_name_changed

        m.name = "Another machine"
        m.save.should be_true
        m.get_dropbox_folder_name.should == "machines/#{m.id} Another machine"
        m.should be_dropbox_name_changed
      end
    end

    context "Defined methods" do
      before do
        class Machine
          has_dropbox_folder :my_method, :dropbox_folder => "machine"

          def my_method
            "MA#{id} #{name}"
          end

          def to_s
            name
          end
        end
      end

      let(:machine) { Machine.new(:name => "New machine") }

      it 'should use the new_method and defined folde' do
        m = stub_dropbox_methods(machine)
        m.save.should be_true

        m.get_dropbox_folder_name.should == "machine/MA#{m.id} #{m.name}"
      end
    end

    context "Using user defaults" do
      before do
        class User
          has_dropbox_folder

          def to_s
            "#{id} User"
          end
        end
      end
      
      let(:user) {User.new(:email => "my@example.com", :password => "secret")}

      it 'should not collide with conf attributes' do
        u = stub_dropbox_methods(user)
        u.save.should be_true
        DropboxFolder::Conf.email.should_not == u.email
        DropboxFolder::Conf.password.should_not == u.password
      end
    end
  end

  context "Create a record and create folder for record" do
    before do
      class Machine
        has_dropbox_folder

        def to_s
          "#{id}_#{name}"
        end
      end
    end

    it 'should create a folder for a machine' do

      m = Machine.create!(:name => "First machine", :extra_info => "More info")
      m.dropbox_folder_session.list("/machines").select {|p| p.path =~ /#{m.id}_#{m.name}/ }.should have(1).element

      m.name = "Other machine"
      m.save.should be_true

      m.dropbox_folder_session.list("/machines").select {|p| p.path =~ /#{m.id}_#{m.name}/ }.should have(1).element

      m.destroy.should be_true
      m.should be_destroyed
      m.dropbox_folder_session.list("/machines").select {|p| p.path =~ /#{m.id}_#{m.name}/ }.should have(0).elements
    end
  end
end
