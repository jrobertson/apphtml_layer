#!/usr/bin/env ruby

# file: apphtml_layer.rb

require 'uri'
require 'c32'
require 'json'
require 'hpath'
require 'kramdown'


module HashPath

  refine Hash do

    def path(s)
      Hpath.get(self, s)
    end

  end

end

class AppHtmlLayer
  using HashPath
  using ColouredText
  
  attr_reader :apps

  def initialize(apps={}, filepath: '.', headings: false, debug: false)
    
    @apps = if apps.is_a? Hash
      apps
    else
      {apps.class.to_s.downcase.to_sym => apps}
    end
    
    @filepath, @headings, @debug = filepath, headings, debug
    
  end

  def lookup(s)

    if s[-1] == '/' then
      
      fp = File.join(@filepath, 'index.html')      
      
      if File.exists?(fp) then
        
        return File.read(fp)
        
      else
        
        app = path(s)
        
        if app then
          return default_index(app) 
        else
          return ['path not found', 'text/plain', '404']
        end
        
      end

    end
   
    return [s.to_s, 'text/plain'] if s =~ /^\/\w+\.\w+/

    a2 = s.split('/')
    basepath = a2[0..-2].join('/')
    uri = URI(a2[-1])

    name = a2[-1][-1] == '?' ? a2[-1] : uri.path
    puts 'name: ' + name.inspect if @debug

    if uri.query then

      h = URI.decode_www_form(uri.query).inject({}) do |r,x|
        r.merge!(x[0].to_sym => x[1])
      end

      puts ('h: ' + h.inspect).debug if @debug
      args = h[:arg] ? [h[:arg]] : h
      puts 'args: ' + args.inspect if @debug
      
    end  

    puts 's: ' + s.inspect if @debug
    app = path(basepath)
    puts 'app: ' + app.inspect if @debug
    
    if app and app.respond_to? name.to_sym then

      begin
        
        method = app.method(name.to_sym)
        
        if method.arity > 0 and  args.length <= 0 then
          
          r = "
          <form action='#{name}'>
            <input type='text' name='arg'/>
            <input type='submit'/>
          </form>"
        else
          
          puts ('args: ' + args.inspect).debug if @debug
          
          r = case args
          when Array
            method.call(*args) 
          when Hash
            args.empty? ? method.call : method.call(args)
          else
            method.call
          end
          
        end
        
        puts ('name' + name.inspect) if @debug
        
        fp = File.join(@filepath, File.basename(name) + '.html')
        puts 'fp: ' + fp.inspect if @debug
        
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
  
  private
  
  def default_index(app)
    
    a = (app.public_methods - Object.public_methods).sort
    s = a.map {|x| "* [%s](%s)" % [x,x]}.join("\n")

    markdown = "
<html>
  <head>
  <title>#{app.class.to_s}</title>
  <style>
h1 {color: green}
h2 {color: orange}
div {height: 60%; overflow-y: auto; width: 200px; float: left}
  </style>
  </head>
<body markdown='1'>

# #{app.class.to_s} Index

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
  
  def path(s)
    
    if @apps.length < 2 then      
      @apps.path("/%s/%s" % [@apps.keys.first, s])
    else
      @apps.path(s)
    end
    
  end
  
  def render_html(fp, s)
    
    doc = Rexle.new(File.read fp)
    e = doc.root.element('//[@class="output"]')    
    e.text = s
    
    doc.xml pretty: true    
    
  end

end
