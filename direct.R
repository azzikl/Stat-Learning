library(jsonlite)
library(httr)


param = list(
  CampaignIDS = 10257080,
  StartDate = '2017-02-11',
  locale = '2017-02-13'
  
)
#нужено подтведить доступ у яндекса
body = list(
  method = 'GetSummaryStat',
  param = param,
  token =  'AQAAAAASPqTJAAQPWWYzJSKujEmcggo1uE5LUOE'
)
url = 'https://api.direct.yandex.ru/v4/json/'
r = POST(url = url, body = body, encode = 'json' )
content(r)

