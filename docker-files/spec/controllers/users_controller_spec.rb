require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  describe 'GET #new' do
   before { get :new }

   it 'レスポンスコードが200であること' do 
     # レスポンスコードは数字でも指定可能(:okでも同じ意味)
     expect(response).to have_http_status(:ok)
   end

   it 'newテンプレートをレンダリングすること' do
     # rails-controller-testingのGemをインストールすることで使用可能(render_template)
     expect(response).to render_template :new
   end

   it '新しいuserオブジェクトがビューに渡されること' do
     expect(assigns(:user)).to be_a_new User
   end
  end

  describe 'POST #create' do
    before do
      @referer = 'http://localhost'
      @request.env['HTTP_REFERER'] = @referer
    end

    context '正しいユーザー情報が渡ってきた場合' do
      let(:params) do
        { user: {
            name: 'user',
            password: 'password',
            password_confirmation: 'password',
          }
        }
      end

      it 'ユーザーが一人増えていること' do
        expect { post :create, params: params }.to change(User, :count).by(1)
      end

      it 'マイページにリダイレクトされること' do
        expect(post :create, params: params).to redirect_to(mypage_path)
      end

      context 'パラメータに正しいユーザー名、確認パスワードが入力されていない場合' do
        before do
          post(:create, params: {
            user: {
              name: 'ユーザー1',
              password: 'password',
              password_confirmation: 'invalid_password'
            }
          })
        end

        it 'リファラーにリダイレクトされること' do
          expect(response).to redirect_to(@referer)
        end

        it 'ユーザー名のエラーメッセージが含まれている場合' do
          expect(flash[:error_messages]).to include 'ユーザー名は小文字英数字で入力してください'
        end

        it 'パスワード確認のエラーメッセージが含まれていること' do
          expect(flash[:error_messages]).to include 'パスワード（確認）とパスワードの入力が一致しません'
        end
      end
    end
  end

end
