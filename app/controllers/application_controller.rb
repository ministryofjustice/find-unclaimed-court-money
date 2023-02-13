class ApplicationController < ActionController::Base
  default_form_builder(GOVUKDesignSystemFormBuilder::FormBuilder)

  def homepage
    render "/homepage"
  end

  def accessibility
    render "/accessibility"
  end
end
