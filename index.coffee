ddg = require('ddg')
Telegram = require 'telegram-bot'

tg = new Telegram(process.env.TELEGRAM_BOT_TOKEN)
options = {
        "useragent": "My duckduckgo app"
        "no_redirects": "1"
        "no_html": "0"
}
tg.on 'message', (msg) ->
  console.log msg
  return unless msg.text
  msg.text = msg.text.replace('@instantAnswerBot','').replace('!','')
  ddg.query(msg.text, options, (err, data)->
    if err
      console.log err
      tg.sendMessage
        text: "I am rebooting right now, Please try after sometime"
        reply_to_message_id: msg.message_id
        chat_id: msg.chat.id
    else  
      #get abstract text or definition
      abstract = if data.AbstractText then "Instant Answer: \n"+ data.AbstractText else ""

      #fetch image url
      image = ""
      if data.Image
        image = "Image: " + data.Image
      else if data.RelatedTopics.length isnt 0 and data.RelatedTopics[0].Icon
        image = "Image: " + data.RelatedTopics[0].Icon.URL

      #fetch definitions and related results
      relatedTopics = data.RelatedTopics
      result_conent = ""

      #fetch only 5 results to avoid very big message
      i = 0
      while i < 5
        topic = relatedTopics[i]
        if topic and topic.FirstURL and topic.Text
          result_conent = result_conent + '\n ' + topic.FirstURL + '\n ' + topic.Text
        i++

      #final message
      reply = if result_conent then abstract + "\n\n"+ image+ "\n\n"+ "Related Results:"+ result_conent else "Bummer, Please try something else"

      #send reply
      tg.sendMessage
        text: reply
        reply_to_message_id: msg.message_id
        chat_id: msg.chat.id

  )

tg.start()
