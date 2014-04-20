require 'spec_helper'

describe WallpapersController do
  describe 'GET #index' do
    context 'when signed out' do
      it 'succeeds' do
        get :index
        expect(response).to be_success
      end
    end
  end

  describe 'GET #show' do
    let(:wallpaper) { FactoryGirl.create :wallpaper }

    context 'when signed out' do
      it 'succeeds' do
        get :show, id: wallpaper.id
        expect(response).to be_success
      end
    end
  end

  describe 'GET #new' do
    context 'when signed out' do
      it 'redirects to sign in page' do
        get :new
        expect(response).to redirect_to new_user_session_path
      end
    end

    context 'when signed in' do
      let!(:user) { signed_in_user }

      it 'succeeds' do
        get :new
        expect(response).to be_success
      end
    end
  end

  describe 'POST #create' do
    context 'when signed out' do
      it 'redirects to sign in page' do
        post :create
        expect(response).to redirect_to new_user_session_path
      end
    end

    context 'when signed in' do
      let(:user) { signed_in_user }
      let(:wallpaper) { FactoryGirl.create :wallpaper, user: user }
    end
  end

  describe 'PATCH #update' do
    let(:user)             { FactoryGirl.create :user }
    let(:my_wallpaper)     { FactoryGirl.create :wallpaper, user: user }
    let(:not_my_wallpaper) { FactoryGirl.create :wallpaper }

    context 'when signed out' do
      it 'redirects to sign in page' do
        patch :update, id: not_my_wallpaper.id
        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe 'DELETE #destroy' do
    let(:other_user) { FactoryGirl.create :user }
    let(:not_my_wallpaper) { FactoryGirl.create :wallpaper, user: other_user }

    context 'when signed out' do
      it 'redirects to sign in page' do
        delete :destroy, id: not_my_wallpaper.id
        expect(response).to redirect_to new_user_session_path
      end
    end

    context 'when signed in' do
      let!(:user) { signed_in_user }

      context 'not my wallpaper' do
        before { delete :destroy, id: not_my_wallpaper.id }

        it { should respond_with 401 }
      end

      context 'my wallpaper' do
        let!(:my_wallpaper) { FactoryGirl.create :wallpaper, user: user }

        it 'destroys the wallpaper' do
          expect { delete :destroy, id: my_wallpaper.id }.to change(Wallpaper, :count).by(-1)
        end

        it 'redirects to index' do
          delete :destroy, id: my_wallpaper.id
          expect(response).to redirect_to wallpapers_path
        end
      end
    end
  end
end