module Users
  class V1 < Grape::API
    # /v1/users
    resource 'users' do
      # GET /v1/users
      desc 'ユーザー一覧取得'
      get '/', jbuilder:'v1/users/index' do
        @users = User.page(params[:page])
      end

      # POST /v1/users
      desc 'ユーザー登録'
      params do
        requires :email, type: String, desc: 'メールアドレス'
        optional :name, type: String, desc: '名前'
        requires :password, type: String, desc: 'パスワード'
        requires :password_confirmation, type: String, desc: 'パスワード確認用'
      end
      post '/', jbuilder: 'v1/users/me' do
        st_params = strong_params(params).permit(:email, :password, :password_confirmation, :name)
        @user = User.new(email: st_params[:email],
                 password: st_params[:password],
                 password_confirmation: st_params[:password_confirmation],
                 name: st_params[:name].presence,
                 address: SecureRandom.hex,
                 thx_balance: User::INIT_THX)
        @user.save!
      end

      # GET /v1/users/search?q={検索キーワード}
      desc 'ユーザー検索'
      params do
        requires :q, type: String, desc: '検索クエリ'
      end
      get 'search', jbuilder:'v1/users/index' do
        st_params = strong_params(params).permit(:q)
        @users = if st_params[:q].blank?
                   nil
                 else
                   User.where('email LIKE(?) OR name LIKE(?)', "%#{st_params[:q]}%", "%#{st_params[:q]}%").page(params[:page])
                 end
      end
    end
  end
end
