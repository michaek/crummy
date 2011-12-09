# encoding: utf-8

module Crummy
  class StandardRenderer
    include ActionView::Helpers::UrlHelper
    include ActionView::Helpers::TagHelper unless self.included_modules.include?(ActionView::Helpers::TagHelper)

    # Render the list of crumbs as either html or xml
    #
    # Takes 3 options:
    # The output format. Can either be xml or html. Default :html
    #   :format => (:html|:xml) 
    # The separator text. It does not assume you want spaces on either side so you must specify. Default +&raquo;+ for :html and +crumb+ for xml
    #   :separator => string  
    # Render links in the output. Default +true+
    #   :link => boolean        
    # 
    #   Examples:
    #   render_crumbs                         #=> <a href="/">Home</a> &raquo; <a href="/businesses">Businesses</a>
    #   render_crumbs :separator => ' | '     #=> <a href="/">Home</a> | <a href="/businesses">Businesses</a>
    #   render_crumbs :format => :xml         #=> <crumb href="/">Home</crumb><crumb href="/businesses">Businesses</crumb>
    #   render_crumbs :format => :html_list   #=> <ul class="" id=""><li class=""><a href="/">Home</a></li><li class=""><a href="/">Businesses</a></li></ul>
    #   
    # With :format => :html_list you can specify additional params: active_li_class, li_class, ul_class, ul_id
    # The only argument is for the separator text. It does not assume you want spaces on either side so you must specify. Defaults to +&raquo;+
    #
    #   render_crumbs(" . ")  #=> <a href="/">Home</a> . <a href="/businesses">Businesses</a>
    #
    def render_crumbs(crumbs, options = {})
      return '' if options[:skip_if_blank] && crumbs.count < 1

      default_options = {
        :format => :html,
        :active_li_class => "",
        :li_class => "",
        :ul_class => "",
        :ul_id => "",
        :links => true
      }
      
      # Add some sensible defaults for Bootstrap
      if options[:format] == :bootstrap
        default_options.merge!({
          :separator => "/",
          :active_li_class => "active",
          :ul_class => "breadcrumb"
        })
      end
      
      options = default_options.merge(options)

      # Hmm. More defaults.
      if options[:separator].nil?
        options[:separator] = " &raquo; " if options[:format] == :html 
        options[:separator] = "crumb" if options[:format] == :xml 
        options[:separator] = "" if options[:format] == :html_list 
      end

      case options[:format]
      when :html
        crumb_string = crumbs.collect do |crumb|
          crumb_to_html crumb, options[:links]
        end * options[:separator]
        crumb_string
      when :html_list, :bootstrap

        crumb_string = crumbs.collect do |crumb|
          if options[:format] == :html_list
            crumb_to_html_list crumb, options[:links], options[:li_class], options[:active_li_class]
          else
            crumb_to_bootstrap crumb, options[:links], options[:li_class], options[:active_li_class], options[:separator]
          end
        end.join

        crumb_string = "<ul class=\"#{options[:ul_class]}\" id=\"#{options[:ul_id]}\">" + crumb_string + "</ul>"
        crumb_string
      when :xml
        crumbs.collect do |crumb|
          crumb_to_xml crumb, options[:links], options[:separator]
        end * ''
      else
        raise ArgumentError, "Unknown breadcrumb output format"
      end
    end

    private

    def crumb_to_html(crumb, links)
      name, url = crumb
      url && links ? link_to(name, url) : name
    end
    
    def crumb_to_bootstrap(crumb, links, li_class, active_li_class, separator)
      name, url = crumb
      url && links ? "<li class=\"#{li_class}\"><a href=\"#{url}\">#{name}</a><span class=\"divider\">#{separator}</span></li>" : "<li class=\"#{active_li_class}\">#{name}</li>"
    end

    def crumb_to_html_list(crumb, links, li_class, active_li_class)
      name, url = crumb
      url && links ? "<li class=\"#{li_class}\"><a href=\"#{url}\">#{name}</a></li>" : "<li class=\"#{active_li_class}\"><span>#{name}</span></li>"
    end

    def crumb_to_xml(crumb, links, separator)
      name, url = crumb
      url && links ? "<#{separator} href=\"#{url}\">#{name}</#{separator}>" : "<#{separator}>#{name}</#{separator}>"
    end
  end
end
