require 'active_support'
require 'active_support/core_ext'
require 'erb'
require_relative './session'
require 'active_support/inflector'
require 'byebug'

class ControllerBase
  attr_reader :req, :res, :params

  # Setup the controller
  def initialize(req, res)
    @req = req
    @res = res
  end

  # Helper method to alias @already_built_response
  def already_built_response?
    return true if @already_built_response
    false
  end

  # Set the response status code and header
  def redirect_to(url)
    if already_built_response?
      raise "You cannot render twice!"
    else
      res.set_header('Location', url)
      res.status = 302
      @already_built_response = true
    end
  end

  # Populate the response with content.
  # Set the response's content type to the given type.
  # Raise an error if the developer tries to double render.
  def render_content(content, content_type)    
    if already_built_response?
      raise "You cannot render twice!"
    else
      res['Content-Type'] = content_type
      res.write(content)
      @already_built_response = true
    end
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    path = File.dirname(__FILE__)
    path = path.split("/")
    path = path[0...-1]
    path << "views"
    path << self.class.to_s.underscore
    path << template_name.to_s
    path = path.join("/")

    filename = path + ".html.erb"
    read_file = File.read(filename)
    content = ERB.new(read_file).result(binding)
    

    render_content(content, 'text/html')
  end

  # method exposing a `Session` object
  def session
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
  end

end

