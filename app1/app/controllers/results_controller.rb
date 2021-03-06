class ResultsController < ApplicationController
  before_action :set_result, only: [:show, :edit, :update, :destroy]

  # GET /results
  # GET /results.json
  load_and_authorize_resource :except => [:last_update]

  @@newest_updated_at ||= Result.first.updated_at.to_i
  @@newest_id ||= Result.first.id

  def index
    # @results = Result.where get_query_hash
    @results = @results.order('updated_at DESC').where get_query_hash
  end

  def last_update
    client_updated_at = params[:last_update]
    t_client = DateTime.strptime(client_updated_at, "%Y-%m-%d %H:%M:%S").to_i
    refresh = t_client < @@newest_updated_at
    #@result.newer_than params[:last_update]
    respond_to do |format|
        format.json { render json: { :refresh => refresh, :newest_id => @@newest_id} }
      end
  end

  # GET /results/1
  # GET /results/1.json
  def show
  end

  # GET /results/new
  def new
    # @result = Result.new
  end

  # GET /results/1/edit
  def edit
  end

  # POST /results
  # POST /results.json
  def create
    # @result = Result.new(result_params)

    respond_to do |format|
      if @result.save
        @@newest_updated_at = @result.updated_at.to_i     ### update when there is an updated Result
        @@newest_id = @result.id
        format.html { redirect_to @result, notice: 'Result was successfully created.' }
        format.json { render :show, status: :created, location: @result }
      else
        format.html { render :new }
        format.json { render json: @result.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /results/1
  # PATCH/PUT /results/1.json
  def update
    respond_to do |format|
      if @result.update(result_params)
        @@newest_updated_at = @result.updated_at.to_i     ### update when there is an updated Result
        @@newest_id = @result.id
        format.html { redirect_to @result, notice: 'Result was successfully updated.' }
        format.json { render :show, status: :ok, location: @result }
      else
        format.html { render :edit }
        format.json { render json: @result.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /results/1
  # DELETE /results/1.json
  def destroy
    @result.destroy
    respond_to do |format|
      format.html { redirect_to results_url, notice: 'Result was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use .where get_query_hashbacks to share common setup or constraints between actions.
    def set_result
      # @result = Result.find(params[:id])
    end

    # Never trust parameters from the scary internet, only.where get_query_hashow the white list through.
    def result_params
      params.require(:result).permit(:user_id, :patient_id, :business_id, :device_id, :consumable_id, :value, :result_datetime, :notes)
    end
end
