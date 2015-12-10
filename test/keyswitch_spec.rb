require 'spec_helper'

describe Keyswitch do

  # TODO REPLACE
  let(:store) do
    store = Minitest::Mock.new
    store.expect :name, 'AuditTrail'
    store.expect :count, 10

    stored_audit = MiniTest::Mock.new
    stored_audit.expect :values, {}

    store.expect :create, stored_audit, [Hash]
    store
  end

end
