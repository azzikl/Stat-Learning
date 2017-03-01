library(googleAnalyticsR)
library(googleAuthR)

ga_auth()

#функция которой нет в библиотеках, но есть код на гите https://github.com/MarkEdmondson1234/googleAuthR/issues/46 
#ньюанс в том, что не работает строка которая отвечает за проверку названий колонок, я ее удалил и теперь все ок
ga_custom_upload_file <- function(accountId,
                                  webPropertyId,
                                  customDataSourceId,
                                  upload){
  
  if(inherits(upload, "data.frame")){
    temp <- tempfile()
    on.exit(unlink(temp))
    write.csv(upload, file = temp, row.names = FALSE)
  } else if(inherits(upload, "character")){
    temp <- upload
  } else {
    stop("Unsupported upload, must be a file location or R data.frame, got:", class(upload))
  }
  
  url <- "https://www.googleapis.com/upload/analytics/v3/management/"
  cds <- gar_api_generator(url,
                           "POST",
                           path_args = list(
                             accounts = accountId,
                             webproperties = webPropertyId,
                             customDataSources = customDataSourceId,
                             uploads = ""
                           ),
                           pars_args = list(
                             uploadType = "media"
                           ))
  
  req <- cds(the_body = httr::upload_file(temp, type = "application/octet-stream"))
  
  if(req$status == 200){
    message("File uploaded")
  } else {
    message("Problem upload file")
  }
  
  httr::content(req, as = "raw")
}

accountId = 53573082  #ID аккаунта GA
webPropertyId = 'UA-53573082-1' #ID ресурса GA
customDataSourceId = 'X9Lii0fjSIWAp75jdFN41w' #ключ api набора импорта расходов (берется из web интерфейса)

#вызов функции
obj = ga_custom_upload_file(accountId,webPropertyId,customDataSourceId,direct_adcost)


# obj2 = ga_custom_upload(accountId, webPropertyId, customDataSourceId, obj$id)x