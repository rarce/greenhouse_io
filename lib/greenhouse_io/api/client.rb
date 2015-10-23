module GreenhouseIo
  class Client
    include HTTMultiParty
    include GreenhouseIo::API

    PERMITTED_OPTIONS = [:page, :per_page]

    attr_accessor :api_token, :rate_limit, :rate_limit_remaining, :pagination_link
    base_uri 'https://harvest.greenhouse.io/v1'

    def initialize(api_token = nil)
      @api_token = api_token || GreenhouseIo.configuration.api_token
    end

    def offices(id = nil, options = {})
      get_from_harvest_api "/offices#{path_id(id)}", options
    end

    def departments(id = nil, options = {})
      get_from_harvest_api "/departments#{path_id(id)}", options
    end

    def candidates(id = nil, options = {})
      get_from_harvest_api "/candidates#{path_id(id)}", options
    end

    def activity_feed(id, options = {})
      get_from_harvest_api "/candidates/#{id}/activity_feed", options
    end

    def applications(id = nil, options = {})
      get_from_harvest_api "/applications#{path_id(id)}", options
    end

    def scorecards(id, options = {})
      get_from_harvest_api "/applications/#{id}/scorecards", options
    end

    def scheduled_interviews(id, options = {})
      get_from_harvest_api "/applications/#{id}/scheduled_interviews", options
    end

    def jobs(id = nil, options = {})
      get_from_harvest_api "/jobs#{path_id(id)}", options
    end

    def stages(id, options = {})
      get_from_harvest_api "/jobs/#{id}/stages", options
    end

    def job_posts(options = {})
      get_from_harvest_api "/job_posts", options
    end

    def job_post(id, options = {})
      get_from_harvest_api "/jobs/#{id}/job_post", options
    end

    def users(id = nil, options = {})
      get_from_harvest_api "/users#{path_id(id)}", options
    end

    def sources(id = nil, options = {})
      get_from_harvest_api "/sources#{path_id(id)}", options
    end

    def offers(id, options = {})
      get_from_harvest_api "/applications/#{id}/offers", options
    end

    def rejection_reasons(id = nil, options = {})
      get_from_harvest_api "/rejection_reasons#{path_id(id)}", options
    end

    def email_templates(id = nil, options = {})
      get_from_harvest_api "/email_templates#{path_id(id)}", options
    end

    def last_page?
      pagination_link.match(/next/).nil?
    end

    private

    def path_id(id = nil)
      "/#{id}" unless id.nil?
    end

    def permitted_options(options)
      options.select { |key, value| PERMITTED_OPTIONS.include? key }
    end

    def get_from_harvest_api(url, options = {})
      response = get_response(url, query: permitted_options(options), basic_auth: basic_auth)
      set_rate_limits(response.headers)
      set_pagination_link(response.headers)
      if response.code == 200
        parse_json(response)
      else
        raise GreenhouseIo::Error.new(response.code)
      end
    end

    def set_rate_limits(headers)
      self.rate_limit = headers['x-ratelimit-limit'].to_i
      self.rate_limit_remaining = headers['x-ratelimit-remaining'].to_i
    end

    def set_pagination_link(headers)
      self.pagination_link = headers['Link']
    end
  end
end
