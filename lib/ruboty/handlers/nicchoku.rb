module Ruboty
  module Handlers
    class Nicchoku < Base
      NAMESPACE = "nicchoku"
      MINE_REGEXP = "わたく?し|ワタク?シ|あたし|アタシ|私|ボク|ぼく|僕|オレ|おれ|俺|じぶん|自分|おいどん|わし"
      LOCALE_SUFFIX = "です|でごわす|じゃけぇ|やき"
      on(/日直チェック|check nicchoku/,
         description: '日直が登録されていなければ呼びかけます',
         name: 'check'
        )

      on(
        /(#{MINE_REGEXP})が日直(#{LOCALE_SUFFIX})/,
        description: "言った人が日直になります",
        name: "stand_up",
        all: true
      )

      on(
        /日直は(#{MINE_REGEXP})(#{LOCALE_SUFFIX})/,
        description: "言った人が日直になります",
        name: "stand_up",
        all: true
      )

      on(
        /(#{MINE_REGEXP})が日直(#{LOCALE_SUFFIX})/,
        description: "言った人が日直になります",
        name: "stand_up"
      )

      on(
        /日直は(#{MINE_REGEXP})(#{LOCALE_SUFFIX})/,
        description: "言った人が日直になります",
        name: "stand_up"
      )

      on(
        /(?<someone>[^#{MINE_REGEXP}]+)が日直(#{LOCALE_SUFFIX})/,
        description: "だれかを日直に登録します",
        name: "recommend",
        all: true
      )

      on(
        /.*日直(さん|の方|の人)/,
        description: "<日直さん>にメッセージを振ります",
        name: "resolve",
        all: true
      )

      def check(message)
        if registered.nil?
          message.reply(ENV['RUBOTY_NICCHOKU_CHECK_PHRASE'] || '今日の日直さんはどなたですか？')
        end
      end

      def stand_up(message)
        register(message.original[:from_name] || message.original[:from])
        infomation(message)
      end

      def recommend(message)
        register(message[:someone].gsub(/^(#{robot.name})[ -_:]/,''))
        infomation(message)
      end

      def infomation(message)
        message.reply("#{registered}を日直に登録しました")
      end

      def resolve(message)
        return if (message.original[:from_name] || '').gsub('(bot)','') == robot.name

        if registered
          message.reply("#{registered}: #{message.body}", type: :privmsg)
        else
          message.reply("日直が登録されていません")
        end
      end

      private

      def register(someone)
        robot.brain.data[NAMESPACE] = {name: someone, date: Date.today}
      end

      def registered
        data = robot.brain.data[NAMESPACE]
        return nil if data.nil? || data[:date] < Date.today
        data[:name]
      end
    end
  end
end
