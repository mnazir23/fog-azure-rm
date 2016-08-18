require File.expand_path '../../test_helper', __dir__

# Test class for Check for Public Ip Request
class TestCheckForPublicIp < Minitest::Test
  def setup
    @service = Fog::Network::AzureRM.new(credentials)
    client = @service.instance_variable_get(:@network_client)
    @public_ips = client.public_ipaddresses
    @promise = Concurrent::Promise.execute do
    end
  end

  def test_check_for_public_ip_success
    @public_ips.stub :get, @promise do
      assert @service.check_for_public_ip('fog-test-rg', 'fog-test-public-ip')
    end
  end

  def test_check_for_public_ip_failure
    response = proc { raise MsRestAzure::AzureOperationError.new(nil, nil, 'error' => { 'message' => 'mocked exception', 'code' => 'ResourceNotFound' }) }
    @public_ips.stub :get, response do
      assert !@service.check_for_public_ip('fog-test-rg', 'fog-test-public-ip')
    end
  end

  def test_check_for_public_ip_exception
    response = proc { raise MsRestAzure::AzureOperationError.new(nil, nil, 'error' => { 'message' => 'mocked exception', 'code' => 'ResourceGroupNotFound' }) }
    @public_ips.stub :get, response do
      assert_raises(Fog::AzureRm::OperationError) { @service.check_for_public_ip('fog-test-rg', 'fog-test-public-ip') }
    end
  end
end
