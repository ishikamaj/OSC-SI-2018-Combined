require "sinatra/base"

class App < Sinatra::Base
  set :erb, :escape_html => true

  def title
    "My App"
  end
  
  get "/" do
     erb :file_number

  end
  
  get "/file_number" do
   @number = params[:file_number]
   @output = %x(du -x -h -a -S ~| sort -h -r | head -n "#{@number}").split("\n")
   @modified = []
   @output.each do |x|
        a = x.index("\t") + 1
        b = x.length -  1
        c = x[a , b]
        @modified.push(%x{date -r "#{c}"})
    end
    erb :index
  end
  
  get "/find_file" do
    erb :find_file
  end
  
  get "/data" do
    @output = %x(du -x -h -a -S "#{params[:file].to_s.strip}"| sort -h -r | head -n 10).split("\n")
    @modified = []
    @output.each do |x|
        a = x.index("\t") + 1
        b = x.length -  1
        c = x[a , b]
        @modified.push(%x{date -r "#{c}"})
    end
    erb :index
  end
 
 
 
 
  get "/usage" do
    @path = Pathname.new("~jnicklas/home.json").expand_path 
    data = @path.read
    a = JSON.parse(data)
    a = a["quotas"]
    b = a.select {|x| x["user"] == "#{params[:user].to_s.strip}"}
    if !b.empty? 
    b = b[0]
    @user = b["user"]
    @file_limit = b["file_limit"]
    @block_limit = b["block_limit"]
    @total_block_usage = b["total_block_usage"]
    @total_file_usage = b["total_file_usage"]
    @blckcalc = ((@total_block_usage.to_f / @block_limit) * 100).round(2)
    @filecalc = ((@total_file_usage.to_f / @file_limit) * 100).round(2)
    else
    begin
    raise "No user process find for user #{params[:user].to_s.strip}"
    rescue => e
    @output = []
    @filecalc = 0
    @blckcalc = 0
    @error = e.message
    end
    end
    erb :usage
  end
  
  
end
