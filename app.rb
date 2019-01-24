require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/cross_origin'
require 'pry'

require 'json'

configure do
  enable :cross_origin
end

before do
  response.headers["Access-Control-Allow-Headers"] = "Authorization, Content-Type, Accept, X-User-Email, X-Auth-Token"
  response.headers['Access-Control-Allow-Origin'] = 'http://localhost:3000'
  response.headers["Access-Control-Allow-Methods"] = "POST", "OPTIONS", "PUT", "DELETE", "GET"
  content_type :json
end

options "*" do
  200
end

def rating_questions
  JSON.parse(File.read('db.json'))['ratingQuestions']
end

def write_json(updated_rating_questions)
  File.open('db.json','w') do |file|
    file.write(JSON.pretty_generate({ratingQuestions: updated_rating_questions}))
  end
end

get '/ratingQuestions' do
  content_type :json
  rating_questions.to_json
end

post '/ratingQuestions' do
  json_params = JSON.parse(request.body.read)
  question = {
    "title": json_params["title"],
    "id": rating_questions.any? ? rating_questions.last["id"]+1 : 1
  }
  updated_rating_questions = rating_questions << question
  write_json(updated_rating_questions)
  question.to_json
end

put '/ratingQuestions/:id' do
  json_params = JSON.parse(request.body.read)
  updated_rating_questions = rating_questions.each { |q| q["title"] = json_params["title"] if q["id"] == params["id"].to_i }
  write_json(updated_rating_questions)
end

delete '/ratingQuestions/:id' do
  target_id = params["id"].to_i
  updated_rating_questions = rating_questions.reject { |question| question["id"] == target_id}
  write_json(updated_rating_questions)
end
