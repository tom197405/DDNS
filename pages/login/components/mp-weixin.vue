<template>
  <view class="container">
    <view class="wechatapp">
      <view class="header">
        <open-data class="avatar" type="userAvatarUrl"></open-data>
      </view>
    </view>
    <view class="auth-title">申请获取以下权限</view>
    <view v-if="isProfile">
        <view class="auth-subtitle">获得您微信绑定的手机号码</view>
        <view class="login-btn">
          <button class="button btn-success" open-type="getPhoneNumber" @getphonenumber="getPhoneNumber">授权手机号</button>
        </view>
    </view>
    <view v-if="!isProfile">
        <view class="auth-subtitle">获得你的公开信息（昵称、头像等）</view>
        <view class="login-btn">
          <button class="button btn-normal" @click.stop="getUserProfile">授权登录</button>
        </view>
    </view>
    <view class="no-login-btn">
      <button class="button btn-normal" @click="handleCancel">暂不登录</button>
    </view>
  </view>
</template>

<!-- 注册页面 -->
<template>
	<view class="bottom-side-otherLogin" @click="getWeChatCode" v-if="isWeixin">
		<text>其他社交账号登录</text>
		<image src="https://xuezhifu-resource.oss-cn-hangzhou.aliyuncs.com/newxuefu/mwx/wx.png"></image>
	</view>
</template>
<script>
	export default {
		data() {
			return {
				isWeixin: false,
			};
		},
		onLoad() {
			this.isWeixin = this.isWechat()
			if(this.isWeixin){
				this.checkWeChatCode()//通过微信官方接口获取code之后，会重新刷新设置的回调地址【redirect_uri】
			}
		},
		onShow() {
		},
		mounted() {
 
		},
		methods: {
			/*微信登录相关  start*/
			//方法：用来判断是否是微信内置的浏览器
			isWechat() {
			        return String(navigator.userAgent.toLowerCase().match(/MicroMessenger/i)) === "micromessenger";
			},
			//方法:用来提取code
			getUrlCode(name) {
				return decodeURIComponent((new RegExp('[?|&]' + name + '=' + '([^&;]+?)(&|#|;|$)').exec(location.href) || [, ''])[1]
					.replace(/\+/g, '%20')) || null
			},
			//检查浏览器地址栏中微信接口返回的code
			checkWeChatCode() {
				let code = this.getUrlCode('code')
				uni.showToast({
					title:`微信code=${code}`
				})
				if (code) {
					
					this.getOpenidAndUserinfo(code)
				}
			},
			//请求微信接口，用来获取code
			getWeChatCode() {
				let local = encodeURIComponent(window.location.href); //获取当前页面地址作为回调地址
				let appid = 'wxd0685311ac9c1654'
				
				//通过微信官方接口获取code之后，会重新刷新设置的回调地址【redirect_uri】
				window.location.href =
					"https://open.weixin.qq.com/connect/oauth2/authorize?appid=" +
					appid + 
					"&redirect_uri=" +
					local +
					"&response_type=code&scope=snsapi_userinfo&state=1#wechat_redirect";
			},
			//把code传递给后台接口，静默登录
			getOpenidAndUserinfo(code) {
				this.$http({
					url:'api/login',
					data:{
						code:code
					}
				}).then((res) => {
					console.log(res)
					if (res.code != 0) {
						uni.showToast({
							title: res.msg,
							duration: 3000,
							icon: 'none'
						});
						return
					}else{
						this.afterLogin(res)
					}
				})
			},
			/*微信登录相关  end*/
			afterLogin(res){
				let user = res.data.user
				uni.setStorageSync('token', res.data.token);
				let u = {
					avatar: user.avatar ? user.avatar : this.avatar,
					mobile: user.mobile,
					nickname: user.nickname ? user.nickname : '土肥圆'
				}
				uni.setStorage({
					key: 'u',
					data: u,
					success: () => {
						
						let url = uni.getStorageSync('redirect')
						uni.reLaunch({
							url: url ? url : '/pages/index'
						})
					}
				});
			},
		},
 
	}
</script>

<script>
  import store from '@/store'
  import * as UserApi from '@/api/user'
  export default {

    data() {
      return {
        // 微信小程序登录凭证 (code)
        // 提交到后端，用于换取openid
        code: '',
        needPhone: false,
        isProfile: false
      }
    },

    created() {
      // 获取code
      this.getCode()
      
      // 获取配置
      this.getUserSetting()
    },

    methods: {

      // 获取code
      // https://developers.weixin.qq.com/miniprogram/dev/api/open-api/login/wx.login.html
      getCode() {
        return new Promise((resolve, reject) => {
          uni.login({
            provider: 'weixin',
            success: res => {
              console.log('getCode res = ', res)
              resolve(res.code)
            },
            fail: reject
          })
        })
      },
      
      getUserSetting() {
        const app = this
        return new Promise((resolve, reject) => {
            UserApi.setting()
            .then(result => {
                app.needPhone = result.data.loginNeedPhone === 'true' ? true : false
            })
            .catch(err => {
              // empty
            })
        })
      },

      // 获取微信用户信息
      getUserProfile() {
        const app = this
        wx.canIUse('getUserProfile') && wx.getUserProfile({
          lang: 'zh_CN',
          desc: '获取用户相关信息',
          success({ userInfo }) {
            console.log('userInfo == ', userInfo)
            if (app.needPhone) {
                app.isProfile = true
            }
            // 授权成功事件
            userInfo.type = "profile"
            app.onAuthSuccess(userInfo)
          },
          fail() {
            console.log('用户拒绝了授权')
          }
        })
      },
      
      // 获取微信绑定的手机号
      getPhoneNumber(e) {
          if (e.detail.errMsg == "getPhoneNumber:ok") {
             this.onAuthSuccess({"type": "phone", "encryptedData": e.detail.encryptedData, "iv": e.detail.iv, "sessionKey": e.detail.iv})
          }
      },
      
      // 授权成功事件
      // 这里分为两个逻辑:
      // 1.将code和userInfo提交到后端，如果存在该用户 则实现自动登录，无需再填写手机号
      // 2.如果不存在该用户, 则显示注册页面, 需填写手机号
      async onAuthSuccess(userInfo) {
        const app = this
        // 提交到后端
        store.dispatch('MpWxLogin', { code: await app.getCode(), userInfo })
          .then(result => {
            if (!app.needPhone || userInfo.type == "phone") {
                // 显示登录成功
                app.$toast(result.message)
                // 跳转回原页面
                setTimeout(() => {
                  app.onNavigateBack()
                }, 1000)
            } else {
                store.dispatch('Logout')
            }
          })
          .catch(() => {
            // 将oauth提交给父级
            app.onEmitSuccess(userInfo)
          })
      },

      // 将oauth提交给父级
      // 这里要重新获取code, 因为上一次获取的code不能复用(会报错)
      async onEmitSuccess(userInfo) {
        const app = this
        app.$emit('success', {
          oauth: 'MP-WEIXIN', // 第三方登录类型: MP-WEIXIN
          code: await app.getCode(), // 微信登录的code, 用于换取openid
          userInfo // 微信用户信息
        })
      },

      /**
       * 暂不登录
       */
      handleCancel() {
        // 跳转回原页面
        this.onNavigateBack()
      },

      /**
       * 授权成功 跳转回原页面
       */
      onNavigateBack(delta = 1) {
        uni.navigateBack({
          delta: Number(delta)
        })
      }
    }
  }
</script>

<style lang="scss" scoped>
  .container {
    padding: 0 60rpx;
    font-size: 32rpx;
    background: #fff;
    min-height: 100vh;
  }

  .wechatapp {
    padding: 80rpx 0 48rpx;
    border-bottom: 1rpx solid #e3e3e3;
    margin-bottom: 72rpx;
    text-align: center;

    .header {
      width: 190rpx;
      height: 190rpx;
      border: 4rpx solid #fff;
      margin: 0 auto 0;
      border-radius: 50%;
      overflow: hidden;
      box-shadow: 2rpx 0 10rpx rgba(50, 50, 50, 0.3);
    }
  }

  .auth-title {
    color: #585858;
    font-size: 34rpx;
    margin-bottom: 40rpx;
  }

  .auth-subtitle {
    color: #888;
    margin-bottom: 88rpx;
    font-size: 28rpx;
  }

  .login-btn {
    padding: 0 20rpx;

    .button {
      height: 88rpx;
      line-height: 88rpx;
      background: #04be01;
      color: #fff;
      font-size: 30rpx;
      border-radius: 12rpx;
      text-align: center;
    }
  }


  .no-login-btn {
    margin-top: 24rpx;
    padding: 0 20rpx;

    .button {
      height: 88rpx;
      line-height: 88rpx;
      background: #dfdfdf;
      color: #fff;
      font-size: 30rpx;
      border-radius: 12rpx;
      text-align: center;
    }
  }
</style>
