class HomeController < ApplicationController
  def index
    Visit.create!(ip_address: request.remote_ip)
    @total_visits = Visit.count
    @recent_visits = Visit.order(created_at: :desc).limit(5)
  end
end
