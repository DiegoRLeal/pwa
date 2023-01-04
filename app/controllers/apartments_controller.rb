class ApartmentsController < ApplicationController
  before_action :authenticate_user!

  def index
    @apartments = Apartment.all
  end
end
