require 'spec_helper'

def stub_dropbox_methods(model)
  model.stub!(
    :login_and_authorize_dropbox => true, 
    :dropbox_folder_session => stub(
      :create_folder => true, 
      :rename => true
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
        puts "-" * 70
        m.save.should be_true
        m.get_dropbox_folder_name.should == "machines/#{m.id} Another machine"
        m.should be_dropbox_name_changed
      end
    end
  end
  #context "Create a record and create folder for record" do
  #  before do
  #    class Machine
  #      has_dropbox_folder

  #      def to_s
  #        "#{id}_#{name}"
  #      end
  #    end
  #  end
  #  it 'should create a folder for a machine' do

  #    m = Machine.create!(:name => "First machine", :extra_info => "More info")
  #    m.dropbox_session.list("/").select {|p| p.path =~ /#{m.id}-#{m.name}/ }.should have(1).element

  #    m.name = "Other machine"
  #    m.save.should be_true

  #    m.dropbox_session.list("/").select {|p| p.path =~ /#{m.id}-#{m.name}/ }.should have(1).element

  #    m.dropbox_session.delete m.dropbox_name
  #  end
  #end
end
