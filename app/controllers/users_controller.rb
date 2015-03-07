class UsersController < ApplicationController
  skip_before_filter :verify_authenticity_token
  # 注册用户
  def create
    # params = params.to_hash
    Rails.logger.info(params)
    # if User.find_by(user_name: params["params"]["user_name"]).present?
    #   return render json: {errorcode: 1, message: '用户名已被占用.'}
    # end
    #
    # if User.find_by(phone_no: params["params"]["phone_no"]).present?
    #   return render json: {errorcode: 1, message: '手机号已被占用.'}
    # end


    user = User.new(user_name: params["params"]["user_name"], phone_no: params["params"]["phone_no"],
                    icon_path: params[:face], password: params["params"]["password"])
    # user.build_whos_user_device(params[:params])
    user.save
    render :json => {user_name: user.user_name, phone_no: user.phone_no,
                     icon_path: user.icon_path.url(:thumb), user_id: user.id,
                     errorcode: 0, message: '注册成功'
           }

  end

  def login
    user = User.auth(params["params"]["phone_no"], params["params"]["password"])
    if user
      # user.whos_user_device.update_attributes(params[:params])
      render :json => {user_name: user.user_name, phone_no: user.phone_no,
                       icon_path: user.icon_path.url(:thumb), status: user.status, user_id: user.id,
                       errorcode: 0, message: '登录成功'}
    else
      render json: {errorcode: 1, message: '用户名或密码错误'}
    end

  end

  def add_friend
    user = User.find(params[:id])
    friend = User.find_by(user_name: params[:user_name])
    user.friends << friend

    render json: {user_name: user.user_name, phone_no: user.phone_no,
                  icon_path: user.icon_path.url(:thumb), status: user.status, id: user.id}

  end

  def get_friend
    user = User.find(params[:id])
    friends = user.friends
    render json: {friends: users_json(friends)}

  end

  def send_message
    user = User.find(params[:id])
    reveice = User.find(params[:reveice_id])
    WhosCustomMessage.create(user: user, reveice: reveice, content: params[:content], path: params[:path],
                             message_type: params[:type], address: params[:address], lat: params[:lat], lng: params[:lng])
    render json: {message: 'ok', errorcode: '', status: 200}

  end

  def messages
    user = User.find params[:id]
    messages = user.whos_custom_messages
    render json: {messages: messages_json(messages)}
  end

  def show
    render json: {message: 'ok'}
  end


  def set_device

  end

  private

  def messages_json(messages)
    jsons = []
    messages.each do |message|
      jsons << {content: messages.conente, from_user_id: messages.from_user_id,
                from_user_name: message.from_user.user_name, create_time: message.created_at}
    end
    jsons
  end


  def users_json(users)
    jsons = []
    users.each do |user|
      jsons << {user_name: user.user_name, phone_no: user.phone_no,
                icon_path: user.icon_path.url(:thumb), status: user.status, id: user.id}
    end
    jsons
  end


end
