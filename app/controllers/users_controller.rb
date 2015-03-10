class UsersController < ApplicationController
  skip_before_filter :verify_authenticity_token

  def index
    case request.subdomain
      when 'm'
        redirect_to mobile_users_path
      else
        render :layout => false
    end

  end

  def mobile

  end

  # 注册用户
  def create
    attrs = conver_params(params["params"])
    user = User.new(attrs)
    user.icon_path = params["face"]
    if user.save!
      render :json => {data: {user_name: user.user_name, phone_no: user.phone_no,
                              icon_path: user.icon, uid: user.id, status: user.status
             }, errorcode: 0, message: '注册成功'
             }

    else
      render json: {errorcode: 1, message: '手机号已被占用.'}
    end

  end

  def update_user
    attrs = conver_params(params["params"])
    user = User.find_by(id: attrs["uid"])
    if user.blank?
      return render json: {errorcode: 1, message: '错误的请求.'}
    end

    user.user_name = attrs["user_name"]
    user.icon_path = params["face"] if params["face"]
    if user.save
      render :json => {data: {user_name: user.user_name, phone_no: user.phone_no,
                              icon_path: user.icon, uid: user.id, status: user.status
             }, errorcode: 0, message: '修改成功'
             }
    else
      render json: {errorcode: 1, message: '修改失败.'}
    end

  end

  def login
    attrs = conver_params(params[:params])
    user = User.auth(attrs['phone_no'], attrs['password'])
    if user
      user.update_columns(status: 1)
      render :json => {data: {user_name: user.user_name, phone_no: user.phone_no,
                              icon_path: user.icon, uid: user.id, status: user.status
             }, errorcode: 0, message: '登录成功'}
    else
      render json: {errorcode: 1, message: '用户名或密码错误'}
    end

  end


  def logout
    attrs = conver_params(params[:params])
    user = User.find_by(id: attrs["uid"])
    error!('注销失败') if user.blank?
    user.update_columns(status: 0)
    render json: {data: [], errorcode: 0, message: '注销成功'}
  end

  def add_friend
    attrs = conver_params(params[:params])
    user = User.find(attrs["uid"])
    friend = User.find_by(user_name: attrs["user_name"])
    if friend
      return render json: {errorcode: 1, message: '不能加自已为好友'} if user == friend
      user.friends << friend

      render json: {data: {user_name: friend.user_name, phone_no: friend.phone_no,
                           icon_path: friend.icon, uid: friend.id, time: friend.recent_time.to_i.to_s
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

  def black_manage
    attrs = conver_params(params[:params])
    user = User.find_by(id: attrs["uid"])
    friend = User.find_by(id: attrs['fuid'])
    return render json: {errorcode: 1, message: '错误的请求!'} if user.blank? or friend.blank?
    return render json: {errorcode: 1, message: '你们还不是好友'} if !user.friends.include?(friend)
    is_black = attrs["is_black"].to_i == 0 ? false : true
    who_friend = WhosFriend.find_by(user: user, friend: friend)
    who_friend.black = is_black
    who_friend.save
    render json: {data: {time: Time.now().to_i.to_s, status: attrs['fuid']}, errorcode: 0, message: '好友管理成功'}

  end

  def update_friend_remark
    attrs = conver_params(params[:params])
    user = User.find_by(id: attrs["uid"])
    friend = User.find_by(id: attrs['fuid'])
    return render json: {errorcode: 1, message: '错误的请求!'} if user.blank? or friend.blank?
    return render json: {errorcode: 1, message: '你们还不是好友'} if !user.friends.include?(friend)
    who_friend = WhosFriend.find_by(user: user, friend: friend)
    who_friend.remark = attrs["remark"]
    who_friend.save
    render json: {data: {fuid: friend.id, remark: attrs["remark"]}, errorcode: 0, message: '编辑好友备注信息成功'}
  end


  def set_device
    attrs = conver_params(params[:params])
    user = User.find_by(id: attrs['uid'])
    error!('非法请求') if user.blank?
    device = user.whos_user_device || user.build_whos_user_device
    device.system = attrs['system']
    device.model = attrs['model']
    device.imei = attrs['imei']
    device.devicetoken = attrs['devicetoken']
    device.currentversion = attrs['currentversion']
    device.lng = attrs['lng']
    device.lat = attrs['lat']
    device.status = attrs['status']
    device.registration_id = attrs["registration_id"]
    device.production = attrs["production"]
    device.save
    render json: {data: [], errorcode: 0, message: '设置成功'}
  end


  def send_message
    attrs = params[:params]
    user = User.find_by(id: attrs['uid'])
    friends = User.where(id: attrs["fuid"].split(','))
    error!('非法请求') if user.blank?
    to_friends = user.friends & friends
    # reveice = User.find(params[:reveice_id])
    to_friends.each do |f|
      WhosCustomMessage.create(user: user, reveice: f, content: attrs["content"], path: attrs["path"],
                               message_type: attrs["type"], address: attrs["address"],
                               lat: attrs["lat"], lng: attrs["lng"])
    end

    render json: {data: {time: Time.now.to_i.to_s}, message: '消息发送成功', errorcode: 0}

  end

  def messages
    user = User.find params[:id]
    messages = user.whos_custom_messages
    render json: {messages: messages_json(messages)}
  end

  def show
    render json: {message: 'ok'}
  end


  private

  def error!(message)
    return render json: {errorcode: 1, message: message}
  end

  def messages_json(messages)
    jsons = []
    messages.each do |message|
      jsons << {content: messages.conente, from_user_id: messages.from_user_id,
                from_user_name: message.from_user.user_name, create_time: message.created_at.to_i.to_s}
    end
    jsons
  end


  def friends_josn(friends)
    jsons = []
    friends.each do |friend|
      jsons << {user_name: friend.friend.user_name, remark: friend.remark || '', icon_path: friend.friend.icon,
                time: friend.recent_time.to_i.to_s, uid: friend.friend_id, black: friend.black ? 1 : 0}
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
