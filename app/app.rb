ENV['RACK_ENV'] ||= 'development'

require 'sinatra/base'
require 'data_mapper'
require 'pry'
require_relative 'models/user.rb'
require_relative 'models/peep.rb'
require_relative 'models/data_mapper_setup.rb'

class Chitter < Sinatra::Base

   use Rack::MethodOverride

  enable :sessions
  set :session_secret, 'super secret'

  get '/' do
    'Hello Chitter!'
  end

  get '/log_in' do
    erb :log_in
  end

  post '/existing_user' do
    user = User.authenticate(params[:user_name], params[:password])
      if user
        session[:user_id] = user.id
        redirect '/peep_board'
      else
        redirect '/log_in'
      end
  end

  get '/sign_up' do
    erb :sign_up
  end

  post '/new_user' do
    @user = User.new(name: params[:name],
             user_name: params[:user_name],
             email: params[:email],
             password: params[:password],
             confirm_password: params[:confirm_password])
    if @user.save
      session[:user_id] = @user.id
      redirect '/new_peep'
    else
      redirect '/sign_up'
    end
  end

  get '/peep_board' do
    @peeps = Peep.all
    # binding.pry
    erb :peep_board
  end

  get '/new_peep' do
    erb :new_peep
  end

  post '/peeps' do
    @peeps = Peep.create(peep: params[:peep])
    redirect '/peep_board'
  end

  get '/log_out' do
    erb :log_out
  end

  helpers do
   def current_user
     @current_user ||= User.get(session[:user_id])
   end
  end


  # start the server if ruby file executed directly
  run! if app_file == $0
end
