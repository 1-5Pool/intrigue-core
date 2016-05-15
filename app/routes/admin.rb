class IntrigueApp < Sinatra::Base
  namespace '/v1' do
    namespace '/admin' do

      get '/?' do
        erb :"admin/index"
      end

      # TODO - kill this
      # Get rid of all existing task runs
      get '/clear/?' do

        # Clear the default queue
        Sidekiq::Queue.new.clear

        # Clear the retries
        rs = Sidekiq::RetrySet.new
        rs.size
        rs.clear

        # Clear the dead jobs
        ds = Sidekiq::DeadSet.new
        ds.size
        ds.clear

        Intrigue::Model::Entity.current_project.destroy
        Intrigue::Model::TaskResult.current_project.destroy
        Intrigue::Model::ScanResult.current_project.destroy

        # Beam me up, scotty!
        redirect '/v1'
      end

      # get config
      get '/config/?' do
        erb :"admin/config"
      end

      # save the config
      post '/config' do

        # Update our config if one of the fields have been changed. Note that we use ***
        # as a way to mask out the full details in the view. If we have one that doesn't lead with ***
        # go ahead and update it
        params.each {|k,v| $intrigue_config.config["intrigue_global_module_config"][k]["value"] = v unless v =~ /^\*\*\*/ }
        $intrigue_config.save

        redirect '/v1/admin/config'
      end

      get '/project_config' do
        erb :"admin/project_config"
      end

      # save the config
      post '/project_config' do
        project_name = "#{params["project_name"]}"

        # set the current session variable
        session["project_name"] = project_name
        response.set_cookie "project_name", :value => project_name

        redirect '/v1/'
      end

    end
  end
end
