class UsersController < ApplicationController
  skip_before_filter :verify_authenticity_token
  # 注册用户
  def create
    attrs = conver_params(params["params"])
    user = User.new(attrs)
    user.icon_path = params["face"]
    if user.save!
      render :json => {data: {user_name: user.user_name, phone_no: user.phone_no,
                              icon_path: user.icon, user_id: user.id
             }, errorcode: 0, message: '注册成功'
             }

    else
      render json: {errorcode: 1, message: '手机号已被占用.'}
    end

  end

  def login
    attrs = conver_params(params[:params])
    user = User.auth(attrs['phone_no'], attrs['password'])
    if user
      render :json => {data: {user_name: user.user_name, phone_no: user.phone_no,
                              icon_path: user.icon, user_id: user.id
             }, errorcode: 0, message: '登录成功'}
    else
      render json: {errorcode: 1, message: '用户名或密码错误'}
    end

  end

  def add_friend
    attrs = conver_params(params[:params])
    user = User.find(attrs["uid"])
    friend = User.find_by(user_name: attrs["user_name"])
    if friend
      user.friends << friend

      render json: {data: {user_name: user.user_name, phone_no: user.phone_no,
                           icon_path: user.icon, user_id: user.id
             }, errorcode: 0, message: '关联好友成功'
             }
    else
      render json: {errorcode: 1, message: '用户不存在'}
    end

  end

  def get_friend
    attrs = conver_params(params[:params])
    user = User.find(attrs["uid"])
    friends = user.whos_friends
    render json: {data: friends_josn(friends), errorcode: 0, message: '获取好友列表'}
  end

  def all_friend
    attrs = conver_params(params[:params])
    user = User.find(attrs["uid"])
    friends = user.all_whos_friends
    render json: {data: friends_josn(friends), errorcode: 0, message: '获取好友列表'}
  end

  def blacklist
    attrs = conver_params(params[:params])
    user = User.find(attrs["uid"])
  end

  def update_friend_remark
    attrs = conver_params(params[:params])
    user = User.find(attrs["uid"])
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
                from_user_name: message.from_user.user_name, create_time: message.created_at.to_i}
    end
    jsons
  end


  def friends_josn(friends)
    jsons = []
    friends.each do |friend|
      jsons << {user_name: friend.friend.user_name, remark: friend.remark || '',
                recent_time: friend.recent_time.to_i, user_id: friend.friend_id, black: friend.black ? 1 : 0}
    end
    jsons
  end

  def users_json(users)
    jsons = []
    users.each do |user|
      jsons << {user_name: user.user_name, phone_no: user.phone_no,
                icon_path: user.icon, user_id: user.id}
    end
    jsons
  end


  def conver_params(str)
    JSON.parse(str)
  end


end
