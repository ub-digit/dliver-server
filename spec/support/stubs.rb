module Requests
  module StubRequests
    def global_stubs

      # Solr Mocking
      stub_request(:post, "http://localhost:8983/solr/dliver/update?wt=ruby").
         with(:headers => {'Content-Type'=>'text/xml'}).
         to_return(:status => 200, :body => "", :headers => {})

      stub_request(:post, "http://localhost:8983/solr/dliver/update?wt=ruby").
        with(:body => "<commit/>",
        :headers => {'Content-Type'=>'text/xml'}).
        to_return(:status => 200, :body => "", :headers => {})

      stub_request(:post, "http://localhost:8983/solr/dliver/update?wt=ruby").
        with(:body => "<optimize/>",
        :headers => {'Content-Type'=>'text/xml'}).
        to_return(:status => 200, :body => "", :headers => {})

    end
  end
end
