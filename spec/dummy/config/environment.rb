# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Dummy::Application.initialize!

## Explicitly remove AR transactions during tests ##
if Rails.env.test?
  # Force the loading of AR stuff
  ActiveRecord::Base.connection.execute('SELECT 1')

  # Remove transactions
  ActiveRecord::ConnectionAdapters::Mysql2Adapter.class_eval do
    def begin_db_transaction
    end

    def commit_db_transaction
    end
  end
end
