require 'epoch_api'

Capistrano::Configuration.instance(:must_exist).load do
  set :epoch_send_notification, false
  set :epoch_with_migrations, ''

  namespace :epoch do
    task :trigger_notification do
      set :epoch_send_notification, true if !dry_run
    end

    task :configure_for_migrations do
      set :epoch_with_migrations, ' (with migrations)'
    end

    task :notify_deploy_started do
      return unless epoch_send_notification
      environment_string = env
      environment_string = "#{stage} (#{env})" if self.respond_to?(:stage)
      location           = "#{deployment_name} to #{environment_string}"

      on_rollback do
        send_options.merge! color: failed_message_color
        send "#{human} cancelled deployment of #{location}.", send_options
      end

      send "#{human} is deploying #{location}#{fetch(:epoch_with_migrations, '')}.", send_options
    end

    task :notify_deploy_finished do
      return unless epoch_send_notification
      send_options.merge! color: success_message_color

      environment_string = env
      environment_string = "#{stage} (#{env})" if self.respond_to?(:stage)
      location           = "#{deployment_name} to #{environment_string}"

      send "#{human} finished deploying #{location}#{fetch(:epoch_with_migrations, '')}.", send_options)
    end

    def send_options
      return @send_options if defined?(@send_options)
      @send_options = {}
      @send_options.merge! notify: message_notification
      @send_options.merge! color: message_color
      @send_options
    end

    def send message, options
      if fetch(:epoch_client, nil).nil?
        set :epoch_client, EpochApi::Client.new epoch_token
      end

      begin
        epoch_client.message epoch_room_token, deploy_user, message, options
      rescue => e
        puts e.message
        puts e.backtrace
      end
    end

    def deployment_name
      if fetch(:branch, nil)
        name  = "#{application}/#{branch}"
        name += " (revision #{real_revision[0..7]})" if real_revision
        name
      else
        application
      end
    end

    def message_color
      fetch :epoch_color, nil
    end

    def success_message_color
      fetch :epoch_success_color, 'green'
    end

    def failed_message_color
      fetch :epoch_failed_color, 'red'
    end

    def message_notification
      fetch :epoch_announce, false
    end

    def deploy_user
      fetch :epoch_deploy_user, 'Deploy'
    end

    def human
      user = ENV['epoch_USER']
      unless user
        user = 'Someone'
        if    (user = %x{git config user.name}.strip) != "" then user
        elsif (user = ENV['USER']) != ""                    then user
        fetch :epoch_human, user
       end
     end
    end

    def env
      fetch :epoch_env, fetch(:rack_env, fetch(:rails_env, "production"))
    end
  end

  before 'deploy'            , 'epoch:trigger_notification'
  before 'deploy:migrations' , 'epoch:trigger_notification'  , 'epoch:configure_for_migrations'
  before 'deploy:update_code', 'epoch:notify_deploy_started'
  after  'deploy'            , 'epoch:notify_deploy_finished'
  after  'deploy:migrations' , 'epoch:notify_deploy_finished'
end
