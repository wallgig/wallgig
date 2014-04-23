module Account
  class SettingsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_settings

    def edit
    end

    def update
      respond_to do |format|
        if @settings.update(settings_params)
          format.html { redirect_to edit_account_settings_url, notice: 'Settings was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: 'edit' }
          format.json { render json: @settings.errors, status: :unprocessable_entity }
        end
      end
    end

    def update_screen_resolution
      width  = params.require(:width)
      height = params.require(:height)

      respond_to do |format|
        if @settings.update(screen_width: width, screen_height: height)
          format.html { redirect_to root_url }
          format.json { head :no_content }
        else
          format.html { render action: 'edit' }
          format.json { render json: @settings.errors, status: :unprocessable_entity }
        end
      end
    end

    private

    def set_settings
      @settings = current_settings
    end

    def settings_params
      params
        .require(:user_setting)
        .permit(
          :sfw, :sketchy, :nsfw,
          :per_page,
          :infinite_scroll,
          :new_window,
          :resolution_exactness,
          :screen_resolution_id,
          :invisible,
          aspect_ratios: []
        )
    end
  end
end
