require 'test_helper'

class ConfigTemplateIntegrationTest < ActionDispatch::IntegrationTest

  test "index page" do
    assert_index_page(config_templates_path,"Provisioning Templates","New Template")
  end
end
