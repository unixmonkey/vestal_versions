require File.join(File.dirname(__FILE__), 'test_helper')

class OptionsTest < Test::Unit::TestCase
  context 'Configuration options' do
    setup do
      @options = {:dependent => :destroy}
      @configuration = {:class_name => 'MyCustomVersion'}

      VestalVersions::VersionConfiguration.options.clear
      @configuration.each{|k,v| VestalVersions::VersionConfiguration.send("#{k}=", v) }

      @prepared_options = User.prepare_versioned_options(@options.dup)
    end

    should 'have symbolized keys' do
      assert User.vestal_versions_options.keys.all?{|k| k.is_a?(Symbol) }
    end

    should 'combine class-level and global configuration options' do
      combined_keys = (@options.keys + @configuration.keys).map(&:to_sym).uniq
      combined_options = @configuration.symbolize_keys.merge(@options.symbolize_keys)
      assert_equal @prepared_options.slice(*combined_keys), combined_options
    end

    teardown do
      VestalVersions::VersionConfiguration.options.clear
      User.prepare_versioned_options({})
    end
  end

  context 'Given no options, configuration options' do
    setup do
      @prepared_options = User.prepare_versioned_options({})
    end

    should 'default to "VestalVersions::Version" for :class_name' do
      assert_equal 'VestalVersions::Version', @prepared_options[:class_name]
    end

    should 'default to :delete_all for :dependent' do
      assert_equal :delete_all, @prepared_options[:dependent]
    end

    should 'force the :as option value to :versioned' do
      assert_equal :versioned, @prepared_options[:as]
    end

    should 'default to [VestalVersions::Versions] for :extend' do
      assert_equal [VestalVersions::Versions], @prepared_options[:extend]
    end
  end
end
