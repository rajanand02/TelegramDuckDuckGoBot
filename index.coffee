ddg = require('ddg')
Telegram = require 'telegram-bot'

tg = new Telegram(process.env.TELEGRAM_BOT_TOKEN)
options = {
        "useragent": "My duckduckgo app",
        "no_redirects": "1",
        "no_html": "0",
}
tg.on 'message', (msg) ->
  return unless msg.text
  ddg.query(msg.text, options, (err, data)->
    results = data.RelatedTopics
    result_conent = ""
    abstract = if data.AbstractText then data.AbstractText else ""
    for result in results
      if result.FirstURL and result.Text
        result_conent =  result_conent + "\n " + result.FirstURL + "\n " + result.Text
    reply = if result_conent then abstract + "\n "+ result_conent else "Bummer, Please try something else"
    tg.sendMessage
      text: reply
      reply_to_message_id: msg.message_id
      chat_id: msg.chat.id

  )

tg.start()
