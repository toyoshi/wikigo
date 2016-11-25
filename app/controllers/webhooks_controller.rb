class WebhooksController < ApplicationController
  before_action :set_webhook, only: [:show, :edit, :update, :destroy]

  # GET /webhooks
  # GET /webhooks.json
  def index
    @webhooks = Webhook.all
  end

  # GET /webhooks/new
  def new
    @webhook = Webhook.new
  end

  # GET /webhooks/1/edit
  def edit
  end

  # POST /webhooks
  def create
    @webhook = Webhook.new(webhook_params)

    respond_to do |format|
      if @webhook.save
        format.html { redirect_to webhooks_path, notice: 'Webhook was successfully created.' }
      else
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /webhooks/1
  def update
    respond_to do |format|
      if @webhook.update(webhook_params)
        format.html { redirect_to webhooks_path, notice: 'Webhook was successfully updated.' }
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /webhooks/1
  def destroy
    @webhook.destroy
    respond_to do |format|
      format.html { redirect_to webhooks_url, notice: 'Webhook was successfully destroyed.' }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_webhook
      @webhook = Webhook.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def webhook_params
      params.require(:webhook).permit(:title, :url)
    end
end
