#!/usr/bin/env ruby

# file: apphtml_layer.rb

require 'uri'
require 'json'
require 'c32'
require 'kramdown'

class AppHtmlLayer
  using ColouredText

  def initialize(app, filepath: '.', headings: false, debug: false)
    @app, @filepath, @headings, @debug = app, filepath, headings, debug
  end

  def lookup(s)

    if s == '/' then
      
      fp = File.join(@filepath, 'index.html')      
      return (File.exists?(fp) ? File.read(fp) : default_index() )

    end
   
    return [s.to_s, 'text/plain'] if s =~ /^\/\w+\.\w+/

    uri = URI(s)

    a = uri.path.split('/')
    a.shift
    name, *args = a

    if uri.query then

      h = URI.decode_www_form(uri.query).inject({}) do |r,x|
        r.merge!(x[0].to_sym => x[1])
      end

      puts ('h: ' + h.inspect).debug if @debug
      args = h[:arg] ? [h[:arg]] : h

    end  

    if @app.respond_to? name.to_sym then

      begin
        
        method = @app.method(name.to_sym)
        
        if method.arity > 0 and  args.length <= 0 then
          
          r = "
          <form action='#{name}'>
            <input type='text' name='arg'/>
            <input type='submit'/>
          </form>"
        else
          
          puts ('args: ' + args.inspect).debug if @debug
          r = args.is_a?(Array) ? method.call(*args) :  method.call(args)
          
        end

        fp = File.join(@filepath, File.basename(name) + '.html')

        content = if File.exists?(fp) then        
          render_html(fp, r)
        else

          if @headings then
            markdown = "
# #{name.capitalize}          

<div>
#{r}
</div>
"

            Kramdown::Document.new(markdown).to_html
          else
            
            r
          end


        end

      rescue
        content = ($!).inspect
      end
      
      puts ('content: ' + content.inspect).debug if @debug

      case content.class.to_s
      when "String"
        media = content.lstrip[0] == '<' ? 'html' : 'plain'
        [content, 'text/' + media]
      when "Hash"
        [content.to_json,'application/json']
      else
        [content.to_s, 'text/plain']
      end
    end

  end
  
  def default_index()
    
    a = (@app.public_methods - Object.public_methods).sort
    s = a.map {|x| "* [%s](%s)" % [x,x]}.join("\n")

    markdown = "
<html>
  <head>
  <title>#{@app.class.to_s}</title>
  <style>
h1 {color: green}
h2 {color: orange}
div {height: 60%; overflow-y: auto; width: 200px; float: left}
  </style>
  </head>
<body markdown='1'>

# #{@app.class.to_s} Index

## Public Methods

<div markdown='1'>
#{s}
</div>
<iframe name='i1'></iframe>
<div style='clear: both' />
<hr/>
</body>
</html>    
    "    
    #markdown = s
    doc = Rexle.new(Kramdown::Document.new(markdown).to_html)
    
    doc.root.xpath('body/div/ul/li/a') do |link|
      link.attributes[:target] = 'i1'
    end
    
    [doc.xml(pretty: true), 'text/html']    
  end
  
  def render_html(fp, s)
    
    doc = Rexle.new(File.read fp)
    e = doc.root.element('//[@class="output"]')    
    e.text = s
    
    doc.xml pretty: true    
    
  end

end

