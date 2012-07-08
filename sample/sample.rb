# -*- coding: utf-8 -*-
require 'tupper'
class Sample < Sinatra::Base
  enable :sessions

  get '/' do
    tupper = Tupper.new session
    erb :form, locals: { tupper: tupper }
  end

  post '/upload' do
    tupper = Tupper.new session
    tupper.upload params[:dummy_file]
    redirect '/', 302
  end

  post '/cleanup' do
    tupper = Tupper.new session
    tupper.cleanup
    redirect '/', 302
  end

  get '/show_size' do
    tupper = Tupper.new session
    unless tupper.has_uploaded_file?
      redirect '/', 302
    end
    "uploaded file is [#{tupper.uploaded_file}] (size:#{File.size(tupper.uploaded_file)})"
  end
end
