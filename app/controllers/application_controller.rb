class ApplicationController < ActionController::Base
  default_form_builder(GOVUKDesignSystemFormBuilder::FormBuilder)

  def homepage
    render "/homepage"
  end
end
