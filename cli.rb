# Source: https://gist.github.com/1476463

# coding: utf-8
require 'sinatra'
# require 'sinatra/streaming'

set server: 'thin', connections: []

get '/' do
  # erb :chat, locals: { user: params[:user].gsub(/\W/, '') }
  puts "CONNS/: #{settings.connections.inspect}"
  erb :cli
end

get '/stream', provides: 'text/event-stream' do
  # stream :keep_open do |out|
  #   puts "CONNS/st: #{settings.connections.inspect}"
  #   settings.connections << out
  #   out.callback { settings.connections.delete(out) }
  # end
  stream(:keep_open) { |out| settings.connections << out }
end

post '/' do
  @cmd = params[:cmd]
  settings.connections.each do |out|
    out << "data: #{ `#{ @cmd }`.sub(/\n/, '!newline!') }\n\n"
  end
  #204 # response without entity body
end

__END__

@@ layout
<html>
  <head> 
    <title>CLI with Sinatra</title> 
    <meta charset="utf-8" />
    <script src="http://ajax.googleapis.com/ajax/libs/jquery/1/jquery.min.js"></script> 
  </head> 
  <body><%= yield %></body>
</html>

@@ cli

<pre><%= "chat.rb\ncli.rb\n" %></pre>

<textarea id='cli' style="height: 300px; width: 600px;" wrap="hard"></textarea>

<script>
  // reading
  var es = new EventSource('/stream');
  es.onmessage = function(e) { $('#cli').append(e.data.replace(/!newline!/,'\n') + "\n") };

  // writing
  $("form").live("submit", function(e) {
    $.post('/', { cmd: $('#cmd').val() });
    $('#cmd').val('');
    $('#cmd').focus();
    e.preventDefault();
  });
</script>

<form>
  <input id='cmd' placeholder='$' />
</form>