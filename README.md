# Introducing the AppHtml_layer gem


    require 'apphtml_layer'


    class Fun

      def initialize()
      end

      def go()
        'go 123'
      end

      def hello(name)
        'hello ' + name
      end

      def food(apples: 0, grapes: 0)
        {apples: apples.to_i, grapes: grapes.to_i}
      end

    end

    ah = AppHtml.new(Fun.new, filepath: '/home/james/tmp/fun', headings: false, debug: true)
    ah.lookup '/go'
    #=> ["go 123", "text/plain"] 

    ah.lookup '/hello/James'
    #=> ["hello James", "text/plain"] 

    ah.lookup '/hello?arg=James'
    #=> ["hello James", "text/plain"] 

    ah.lookup '/food?apples=3'
    => ['{"apples":3,"grapes":0}', "application/json"] 

The AppHtmlLayer gem makes it more convenient to prepare a working prototype or an HTML application for a web server. An HTML file can be associated with each public method and used in the output.

## Resources

* apphtml_layer https://rubygems.org/gems/apphtml_layer

apphtml apphttp app webserver http apphtmllayerIntroducing the AppHtml_layer gem


    require 'apphtml'


    class Fun

      def initialize()
      end

      def go()
        'go 123'
      end

      def hello(name)
        'hello ' + name
      end

      def food(apples: 0, grapes: 0)
        {apples: apples.to_i, grapes: grapes.to_i}
      end

    end

    ah = AppHtml.new(Fun.new, filepath: '/home/james/tmp/fun', headings: false, debug: true)
    ah.lookup '/go'
    #=> ["go 123", "text/plain"] 

    ah.lookup '/hello/James'
    #=> ["hello James", "text/plain"] 

    ah.lookup '/hello?arg=James'
    #=> ["hello James", "text/plain"] 

    ah.lookup '/food?apples=3'
    => ['{"apples":3,"grapes":0}', "application/json"] 

The AppHtmlLayer gem makes it more convenient to prepare a working prototype or an HTML application for a web server. An HTML file can be associated with each public method and used in the output.

## Resources

* apphtml_layer https://rubygems.org/gems/apphtml_layer

apphtml apphttp app webserver http apphtmllayer
