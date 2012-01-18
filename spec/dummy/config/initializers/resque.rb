if Rails.env.test?
  Resque.inline = true
  Resque.redis  = 'localhost:9736'
end
