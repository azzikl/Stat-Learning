options(httr_oob_default=TRUE)

library(rjson)

#здесь должна быть часть с авторизацией но ее пока нет
# url = "https://oauth.yandex.ru/authorize?response_type=token&client_id=df2d2b2c7c424c3cb149c7df7a54d0ba"


#запрос к апи метрики для создания набора данных по расходам директа

token = 'AQAAAAASPqTJAAQNg45_fE-XjkAsmvekC5YfsA8'
metric1 = 'ym:ad:clicks' #клики
metric2 = 'ym:ad:<currency>AdCost' #стоимость 
dimension1 = 'ym:ad:directOrder' #кампании яндекс директ
# dimension2 = 'ym:ad:directBannerGroup' #Группа объявлений Яндекс.Директа
dimension3 = 'ym:ad:directSearchPhrase' #Поисковая фраза последнего перехода по объявлению Яндекс.Директа
login_direct = 'medtehno-com-ua' #доступ к кабинету директа (chief_login) из запроса 'https://api-metrika.yandex.ru/management/v1/clients?counters=29844129&oauth_token=AQAAAAASPqTJAAQNg45_fE-XjkAsmvekC5YfsA8'
ids = '29844129' #id счетчика из метрики

request = paste('https://api-metrika.yandex.ru/stat/v1/data?ids=',ids,'&metrics=',metric1,',',metric2,
                '&dimensions=',dimension1,',',dimension3,'&date1=yesterday&date2=yesterday','&direct_client_logins=',
                login_direct,'&oauth_token=',token,sep = '')

data = fromJSON(file = request) 

#разбираем json в dataframe

campaigns = sapply(data$data, function (x) { return (x$dimensions[[1]]$name) } ) 
keywords = sapply(data$data, function (x) { return (x$dimensions[[2]]$name) } ) 
# groups = sapply(data$data, function (x) { return (x$dimensions[[3]]$name) } ) 
clicks = sapply(data$data, function (x) { return (x$metrics[[1]]) } ) 
cost = sapply(data$data, function (x) { return (x$metrics[[2]]) } ) 

direct_adcost <- data.frame ('ga:adClicks' = clicks,
                             'ga:adCost' = round(cost - (16.67 * cost/100), digits = 2), #вычет НДС
                             'ga:campaign' = campaigns,
                             'ga:keyword' = keywords,
                              stringsAsFactors=FALSE,
                              check.names = FALSE
)
direct_adcost = cbind('ga:source' = 'yandex', direct_adcost)
direct_adcost = cbind('ga:medium' = 'cpc', direct_adcost)
direct_adcost = cbind('ga:date' = format(as.Date(Sys.Date()-1),"%Y%m%d"), direct_adcost)

library(googlesheets)
gs_auth()
write.csv(direct_adcost,'for_py1.csv')
gs_upload('for_py1.csv')


