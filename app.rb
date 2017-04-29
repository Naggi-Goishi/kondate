require 'line/bot'
require 'sinatra/base'
require 'sinatra/activerecord'
require 'mechanize'
require_relative './app_helper'
require_relative './models/base'

class KondateChan < Sinatra::Base
  include AppHelper

  set :database_file, "./config/database.yml"

  get 'ingredient/import' do
    Ingredient.import
    'success'
  end

  post '/callback' do
    body = request.body.read
    events = get_events(request, body)
    validate_signature(request, body)

    puts 'recieved a message ....... '
    Reply.new(client, events).send

    "OK"
  end

end
