#
# Remove submitted jobs
#

namespace :quorum do
  desc "Remove submitted jobs (options: TIME=\"6 weeks\" -- Default 1 week)."
  task :delete_jobs => :environment do
    time = ENV['TIME'] || '1 week'
    puts "Jobs deleted: #{Quorum::Job.delete_jobs(time)}"
  end
end
