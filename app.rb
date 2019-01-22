require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/cross_origin'
require 'pry'

require 'json'

configure do
  enable :cross_origin
end

before do
  response.headers["Allow"] = "GET, POST, OPTIONS"
  response.headers["Access-Control-Allow-Headers"] = "Authorization, Content-Type, Accept, X-User-Email, X-Auth-Token"
  response.headers['Access-Control-Allow-Origin'] = 'http://localhost:3000'
  content_type :json
end

options "*" do
  200
end

def rating_questions
  JSON.parse(File.read('db.json'))['ratingQuestions']
end

get '/ratingQuestions' do
  content_type :json
  rating_questions.to_json
end

post '/ratingQuestions' do
  # Instead of using the form params need to convert to json_params
  json_params = JSON.parse(request.body.read)

  question = {
    "title": json_params["title"],
    "id": rating_questions.last["id"]+1
  }

  updated_rating_questions = rating_questions << question

  File.open('db.json','w') do |file|
    file.write(JSON.pretty_generate({ratingQuestions: updated_rating_questions}))
  end

  # Need to return the new question at the end of the post request for React
  question.to_json
end

