require 'cleverbot'

module Lita
  module Handlers
    class Cleverbot < Handler

      on :unhandled_message, :chat
      config :api_key, type: String
      config :api_user, type: String

      def self.cleverbot
        @cleverbot ||= ::Cleverbot.new(Lita.config.handlers.cleverbot.api_user, Lita.config.handlers.cleverbot.api_key)
      end

      def chat(payload)
        message = payload[:message]
        reply(message) if should_reply?(message)
      end

      private

      def reply(message)
        message.reply build_response(message)
      end

      def should_reply?(message)
        !sent_by_robot?(message) && ( command?(message) || robot_mentioned?(message) )
      end

      def command?(message)
        message.command?
      end

      def sent_by_robot?(message)
        message.user.mention_name == robot.mention_name
      end

      def robot_mentioned?(message)
        message.body =~ /#{aliases.join('|')}/i
      end

      def build_response(message)
        bot_message = message.body.sub(/#{aliases.join('|')}/i, '').strip
        self.class.cleverbot.say(bot_message)
      end

      def aliases
        [robot.mention_name, robot.alias].map{|a| a unless a == ''}.compact
      end

      Lita.register_handler(self)
    end
  end
end
