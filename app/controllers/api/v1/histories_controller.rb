module Api::V1
  class HistoriesController < ApplicationController
    before_action :authenticate_api_v1_user!

    def index
    end
  end
end
