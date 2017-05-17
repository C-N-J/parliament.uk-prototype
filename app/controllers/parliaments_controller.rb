class ParliamentsController < ApplicationController
  def index
    @parliaments = parliament_request.parliaments.get.sort_by(:start_date)
  end

  def current
    id = params[:id]

    @parliament = parliament_request.parliaments.current.get.first
    # require 'pry'; binding.pry
    if @parliament # something
       render nothing: true, status: 400
    else
      redirect_to parliament_path(@parliament.graph_id)
    end

  end
end
