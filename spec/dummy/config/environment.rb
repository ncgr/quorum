# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Dummy::Application.initialize!

## Explicitly remove MySQL AR transactions during tests ##
if Rails.env.test?
  # Force the loading of AR stuff
  ActiveRecord::Base.connection.execute('SELECT 1')

  if ENV['DB'] == 'mysql'
    # Remove transactions
    ActiveRecord::ConnectionAdapters::Mysql2Adapter.class_eval do
      def begin_db_transaction
      end

      def commit_db_transaction
      end
    end
  end

  if ENV['DB'] == 'postgresql'
    # Remove transactions
    ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.class_eval do
      def begin_db_transaction
      end

      def commit_db_transaction
      end
    end
  end
end
