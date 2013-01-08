require "sinatra"
require "dm-core"
require "dm-timestamps"
require "dm-migrations"
require "dm-validations"
require "rack-flash"


configure :development do
  DataMapper.setup(:default, "mysql://root:root@localhost:3306/knol_dev")
  DataMapper::Logger.new($stdout, :debug)
end

configure :production do
  DataMapper.setup(:default, "mysql://#{ENV['OPENSHIFT_MYSQL_DB_USERNAME']}:#{ENV['OPENSHIFT_MYSQL_DB_PASSWORD']}@#{ENV['OPENSHIFT_MYSQL_DB_HOST']}:#{ENV['OPENSHIFT_MYSQL_DB_PORT']}/knol")
end

class Entry
  include DataMapper::Resource

  property :id, Serial
  property :serial, String, length: 140
  property :name, String, length: 256
  property :created_at, DateTime
  property :updated_at, DateTime

  validates_presence_of :serial

end

DataMapper.auto_upgrade!

before do
  $DEBUG = false
end


class App < Sinatra::Base

  set :logging, true

  use Rack::Flash

  enable :sessions

  get "/" do
    @entry = Entry.new
    @entries = Entry.all
    erb :index
  end

  post "/" do
    @entry = Entry.new(params[:entry])
    if @entry.save
      flash[:notice] = "Entry added successfully"
      redirect "/"
    else
      @entries = Entry.all
      erb :index
    end
  end

  get "/delete/:id" do
    @entry = Entry.first(params[:id])
    if @entry.destroy
      flash[:notice] = "Deleted"
    else
      flash[:alert] = "Failed to Delete"
    end
    redirect "/"
end


end


helpers do

  def action
    request.path
  end

  def authenticated?
    !current_user.nil?
  end

  def current_user
    @current_user ||= User.get(session[:user_id])
  end

end
