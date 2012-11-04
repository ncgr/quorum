#
# Remove submitted jobs
#

namespace :quorum do
  desc "Remove submitted jobs. Defaults to 1.week."
  task :delete_jobs => :environment do
    "Jobs deleted: " + Quorum::Job.delete_jobs()
  end
end
