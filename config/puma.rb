# Change to match your CPU core count
workers 2

# Min and Max threads per worker
threads 1, 16

app_dir = File.expand_path("../..", __FILE__)

# Default to production
rails_env = ENV['RAILS_ENV'] || "production"
environment rails_env

if ENV.fetch('RAILS_ENV') == 'production'
    worker_timeout 600
end

# Set up socket location
bind 'tcp://localhost:3000'

# Logging
stdout_redirect "#{app_dir}/log/puma.log"

# Set master PID and state locations
pidfile "/tmp/puma.pid"
state_path "/tmp/puma.state"
activate_control_app
#daemonize true
on_worker_boot do
    require "active_record"
    ActiveRecord::Base.connection.disconnect! rescue ActiveRecord::ConnectionNotEstablished
    ActiveRecord::Base.establish_connection(YAML.load_file("#{app_dir}/config/database.yml")[rails_env])