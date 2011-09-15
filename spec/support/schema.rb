require 'active_record'

ActiveRecord::Base.establish_connection(
  :adapter => 'sqlite3',
  :database => ':memory:'
)

class Machine < ActiveRecord::Base
  has_dropbox_folder :id, :name
end

module Schema
  def self.create
    ActiveRecord::Base.silence do
      ActiveRecord::Migration.verbose = false

      ActiveRecord::Schema.define do
        create_table :machines, :force => true do |t|
          t.string :name
          t.string :extra_info
          t.text :data
          t.timestamps
        end
      end
    end
  end
end
