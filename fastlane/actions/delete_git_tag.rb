module Fastlane
  module Actions
    module SharedValues
      DELETE_GIT_TAG_CUSTOM_VALUE = :DELETE_GIT_TAG_CUSTOM_VALUE
    end

    class DeleteGitTagAction < Action
      def self.run(params)
        # 获取输入参数
        # tag 标签
        tagName = params[:tag]
        # 是否删除本地tag标签 DL->deleteLocal
        isDelLocalTag = params[:isDL]
        # 是否删除远程tag标签 DR->deleteRemote
        isDelRemoteTag = params[:isDR]
        
        # 定义命令数组，要执行的命令加入数组中
        cmds = []
        
        # 是否删除本地标签 git tag -d xxx
        if isDelLocalTag
            cmds << "git tag -d #{tagName}"
        end
        
        # 删除远程标签 git push origin :xxx
        if isDelRemoteTag
            cmds << "git push origin :#{tagName}"
        end
        
        # 执行数组命令
        result = Actions.sh(cmds.join('&'))
        UI.message("delete_git_tag 执行完毕 🚀")
        return result
        
      end
      
      #####################################################
      # @!group Documentation
      #####################################################
      
      def self.description
        # A short description with <= 80 characters of what this action does
        "删除 tag 标签"
      end

      def self.details
        # Optional:
        # this is your chance to provide a more detailed description of this action
        "删除 tag 标签\N 使用方式：\n delete_git_tag(tag: tagName, isDL:true, isDR: true) \n或者 \ndelete_git_tag(tag: tagName)"
      end

      def self.available_options
        # Define all options your action supports.

        # Below a few examples
        [
          FastlaneCore::ConfigItem.new(key: :tag,
                                       description: "tag标签",
                                       verify_block: proc do |value|
                                          UI.user_error!("tag 不能为空") unless (value and not value.empty?)
                                       end),
          FastlaneCore::ConfigItem.new(key: :isDL,
                                       description: "是否删除本地标签",
                                       is_string: false,
                                       default_value: true),
                                       
            FastlaneCore::ConfigItem.new(key: :isDR,
                                        description: "是否删除远程标签",
                                        is_string: false,
                                        default_value: true)
        ]
      end

      def self.output
        # Define the shared values you are going to provide
        # Example
        #[
        #  ['DELETE_GIT_TAG_CUSTOM_VALUE', 'A description of what this value contains']
        #]
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
      end

      def self.authors
        # So no one will ever forget your contribution to fastlane :) You are awesome btw!
        ["kangpp@163.com"]
      end

      def self.is_supported?(platform)
        # you can do things like
        #
        #  true
        #
        #  platform == :ios
        #
        #  [:ios, :mac].include?(platform)
        #

        platform == :ios
      end
    end
  end
end
