#   Copyright 2017 Zendesk, Inc
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.


require 'net/http'
require 'json'
require 'io/console'
require 'optparse'
require 'yaml'

def url(endpoint)
  URI("https://#{SUBDOMAIN}.zendesk.com/api/v2/#{endpoint}")
end

def get(endpoint)
  uri = url(endpoint)
  Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
    request = Net::HTTP::Get.new(uri)
    request.basic_auth EMAIL, PASSWORD
    response = http.request request
  end
end

def put(endpoint, body)
  # puts("put(#{endpoint}, #{body}")
  uri = url(endpoint)
  Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
    request = Net::HTTP::Put.new(uri)
    request.basic_auth EMAIL, PASSWORD
    request.body = body
    request.content_type = "application/json"
    response = http.request request
  end
end
   
def categories
  response = raw_categories
  response["categories"].collect do |x|
    "#{x["id"]} -> #{x["name"]}"
  end
end

def sections
  response = raw_sections
  response["sections"].collect do |section|
      response = get('help_center/en-us/sections.json').body
  response = JSON.parse(response)

  end
end

def category_sections(category_id)
  response = raw_category_sections(category_id)
  response["sections"].collect do |section|
    "* #{section["id"]} -> #{section["name"]}"
  end
end

def raw_categories
  response = get('help_center/en-us/categories.json').body
  response = JSON.parse(response)
end

def raw_sections
  response = get('help_center/en-us/sections.json').body
  response = JSON.parse(response)
end

def raw_category_sections(category_id)
  response = get( "help_center/en-us/categories/#{category_id}/sections.json").body
  response = JSON.parse(response)
end

def raw_articles(section_id)
  articles = get("help_center/en-us/sections/#{section_id}/articles.json").body
  articles = JSON.parse(articles)
end

def articles(section_id)
  articles = raw_articles(section_id)
  articles["articles"].collect do |article|
    label_names = "[#{article['label_names'].join(', ')}]"
    [article['id'], article['title'], label_names].join("\t")
  end
end

def article(article_id)
  article = JSON.parse(get("help_center/en-us/articles/#{article_id}.json").body)['article']
  label_names = "[#{article['label_names'].join(', ')}]"
  [article['id'], article['title'], label_names]
end

def dump
  categories = raw_categories
  categories["categories"].each do |cat|
    cat_id = cat["id"]
    sections = raw_category_sections(cat_id)
    puts "\n#{cat_id} -> #{cat["name"]} has #{sections.length} sections"
    sections["sections"].each do |section|
      section_id = section["id"]
      r = raw_articles(section_id)
      puts "\n#{" " * 4}#{section["id"]} -> #{section["name"]} has #{r.length} articles"
      r["articles"].each do |article|
        label_names = "[#{article['label_names'].join(', ')}]"
        puts "#{" " * 8}#{article["id"]} -> #{article["name"]} #{label_names}"
      end
    end
  end
end

def add_answer_bot_label_to_category(cat_id, label)
  sections = raw_category_sections(cat_id)["sections"]
  sections.each do |section|
    section_id = section["id"]
    puts "calling add_answer_bot_label_to_section(#{section_id})"
    add_answer_bot_label_to_section(section_id, label)
  end
end

def add_answer_bot_label_to_section(section_id, label)
  index = 0
  articles = raw_articles(section_id)["articles"]
  add_answer_bot_label_to_articles(articles, label)
end

def add_answer_bot_label_to_articles(articles, label)
  index = 0
  articles.each do |article|
    article_id = article["id"]
    sleep 3 if (index%7) == 0
    id, title, label_names = article(article_id)
    next if id.nil?
    # Input `label` can contain more than one comma-separated label
    x = label.split(',').uniq
    label_names = (label_names + x).uniq
    data = "{\"article\": {\"label_names\": #{label_names}}}"
    response = put("help_center/articles/#{id}.json", data)
    puts "unable to update #{id}, #{title}, #{label_names}" unless response.is_a?(Net::HTTPSuccess)
    puts "* #{article["id"]}: #{article["title"]}"
    index+=1
  end
end

# Get a catorgy and return the id and name.
def one_category(category_id)
  response = get("help_center/en-us/categories/#{category_id}.json").body
  response = JSON.parse(response)
  category = response["category"]
  "#{category["id"]}: #{category["name"]}"
end

# Get a section and return the id and name.
def one_section(section_id)
  response = get("help_center/en-us/sections/#{section_id}.json").body
  response = JSON.parse(response)
  section = response["section"]
  "#{section["id"]}: #{section["name"]}"
end

# Show the common label prompt and return the response.
def prompt_label
  puts "Alright, add which label(s)? example: answer-bot or answer-bot,cow,moose"
  gets.chomp
end

# Read a YAML file with Zendesk credentials.  The credentials
# area applied in `get` and `put'.
configFile = nil
opt_parser = OptionParser.new do |opts|
  opts.banner = "Usage: bulk_add_label.rb [options]"
  opts.on('-c', "--config=FILE", "YAML configuration file") do |file|
    configFile = file 
  end
  opts.on("-h", "--help", "Prints this help") do
    puts opts
    exit
  end
end
opt_parser.parse!()

if configFile.nil?
  puts("Error: --config is required.  Use `ruby build_add_labels.rb -h` for more info.")
  exit
end

text = File.open(configFile).read
args = YAML.load(text)

SUBDOMAIN = args['domain']
EMAIL = args['email']
PASSWORD = args['password']

loop do
  puts "\nPlease choose one of the following options"
  puts "1. List Categories"
  puts "2. List Sections in a Category"
  puts "3. List Articles in a Section"
  puts "4. Choose Category and add answer-bot label to the articles in that category (long)"
  puts "5. Choose Section and add answer-bot label to the articles in that section"
  puts "6. Dump (long)"
  puts "7. Exit"

  input = gets.chomp.to_i

  case input
    when 1
      puts categories
    when 2
      puts "Alrighty, give me the category_id"
      category_id = gets.chomp.to_i
      puts one_category(category_id)
      puts category_sections(category_id)
    when 3
      puts "Alright, give me the section_id"
      section_id = gets.chomp
      puts articles(section_id)
    when 4
      puts "Alrighty, give me the category_id"
      category_id = gets.chomp.to_i
      puts one_category(category_id)
      label = prompt_label
      add_answer_bot_label_to_category(category_id, label)
    when 5
      puts "Alright, give me the section_id"
      section_id = gets.chomp.to_i
      puts one_section(section_id)
      label = prompt_label
      add_answer_bot_label_to_section(section_id, label)
    when 6
      dump
    when 7
      exit
  end
end
