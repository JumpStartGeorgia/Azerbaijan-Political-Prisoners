require 'devise'

# This file was generated by the `rails generate rspec:install` command. Conventionally, all
# specs live under a `spec` directory, which RSpec adds to the `$LOAD_PATH`.
# The generated `.rspec` file contains `--require spec_helper` which will cause this
# file to always be loaded, without a need to explicitly require it in any files.
#
# Given that it is always loaded, you are encouraged to keep this file as
# light-weight as possible. Requiring heavyweight dependencies from this file
# will add to the boot time of your test suite on EVERY test run, even for an
# individual file that may not need all of that loaded. Instead, consider making
# a separate helper file that requires the additional dependencies and performs
# the additional setup, and require it from the spec files that actually need it.
#
# The `.rspec` file also contains a few flags that are not defaults but that
# users commonly want.
#
# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|
  # rspec-expectations config goes here. You can use an alternate
  # assertion/expectation library such as wrong or the stdlib/minitest
  # assertions if you prefer.
  config.expect_with :rspec do |expectations|
    # This option will default to `true` in RSpec 4. It makes the `description`
    # and `failure_message` of custom matchers include text for helper methods
    # defined using `chain`, e.g.:
    # be_bigger_than(2).and_smaller_than(4).description
    #   # => "be bigger than 2 and smaller than 4"
    # ...rather than:
    #   # => "be bigger than 2"
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  # rspec-mocks config goes here. You can use an alternate test double
  # library (such as bogus or mocha) by changing the `mock_with` option here.
  config.mock_with :rspec do |mocks|
    # Prevents you from mocking or stubbing a method that does not exist on
    # a real object. This is generally recommended, and will default to
    # `true` in RSpec 4.
    mocks.verify_partial_doubles = true
  end

  # The settings below are suggested to provide a good initial experience
  # with RSpec, but feel free to customize to your heart's content.
  #   # These two settings work together to allow you to limit a spec run
  #   # to individual examples or groups you care about by tagging them with
  #   # `:focus` metadata. When nothing is tagged with `:focus`, all examples
  #   # get run.
  #   config.filter_run :focus
  #   config.run_all_when_everything_filtered = true
  #
  #   # Limits the available syntax to the non-monkey patched syntax that is recommended.
  #   # For more details, see:
  #   #   - http://myronmars.to/n/dev-blog/2012/06/rspecs-new-expectation-syntax
  #   #   - http://teaisaweso.me/blog/2013/05/27/rspecs-new-message-expectation-syntax/
  #   #   - http://myronmars.to/n/dev-blog/2014/05/notable-changes-in-rspec-3#new__config_option_to_disable_rspeccore_monkey_patching
  #   config.disable_monkey_patching!
  #
  #   # Many RSpec users commonly either run the entire suite or an individual
  #   # file, and it's useful to allow more verbose output when running an
  #   # individual spec file.
  #   if config.files_to_run.one?
  #     # Use the documentation formatter for detailed output,
  #     # unless a formatter has already been configured
  #     # (e.g. via a command-line flag).
  #     config.default_formatter = 'doc'
  #   end
  #
  #   # Print the 10 slowest examples and example groups at the
  #   # end of the spec run, to help surface which specs are running
  #   # particularly slow.
  #   config.profile_examples = 10
  #
  #   # Run specs in random order to surface order dependencies. If you find an
  #   # order dependency and want to debug it, you can fix the order by providing
  #   # the seed, which is printed after each run.
  #   #     --seed 1234
  #   config.order = :random
  #
  #   # Seed global randomization in this process using the `--seed` CLI option.
  #   # Setting this allows you to use `--seed` to deterministically reproduce
  #   # test failures related to randomization by passing the same `--seed` value
  #   # as the one that triggered the failure.
  #   Kernel.srand config.seed
  config.include Devise::TestHelpers

  # Warden is used to stub authentication in feature specs: https://github.com/plataformatec/devise/wiki/How-To:-Test-with-Capybara
  config.include Warden::Test::Helpers
  Warden.test_mode!

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each, js: true) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  config.before(:suite) do
    begin
      DatabaseCleaner.start
      FactoryGirl.lint
    ensure
      DatabaseCleaner.clean
    end
  end

  config.before(:suite) do
    load "#{Rails.root}/db/seeds.rb"
  end

  # Makes controllers work with default locale
  # Taken from http://stackoverflow.com/a/19079076/3115911
  class ActionController::TestCase
    module Behavior
      def process_with_default_locale(action, http_method = 'GET', parameters = nil, session = nil, flash = nil)
        parameters = { locale: I18n.locale }.merge(parameters || {}) unless I18n.locale.nil?
        process_without_default_locale(action, http_method, parameters, session, flash)
      end
      alias_method_chain :process, :default_locale
    end
  end

  config.before(:each, type: :feature) do
    default_url_options[:locale] = I18n.default_locale
  end

  config.before(:each, type: :request) do
    default_url_options[:locale] = I18n.default_locale
  end

  # Makes routing specs work with default locale
  class ActionDispatch::Routing::RouteSet
    def default_url_options(_options = {})
      { locale: I18n.default_locale }
    end
  end

  # Helper function for Capybara to select options in multiple jQuery select2
  def select2_select_multiple(select_these, clickable_input)
    # This methods requires @javascript in the Scenario
    [select_these].flatten.each do |value|
      clickable_input.click
      found = false
      within('#select2-drop') do
        all('li.select2-result').each do |result|
          unless found
            if result.text == value
              result.click
              found = true
            end
          end
        end
      end
    end
  end

  def t(string, options = {})
    I18n.t(string, options)
  end
end
