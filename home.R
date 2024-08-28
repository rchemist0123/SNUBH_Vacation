homeUI = function(id){
  ns = NS(id)

  uiOutput(ns("homeText"))

}

homeServer = function(id){
  moduleServer(id, function(input, output, session){
    output$homeText = renderUI({
      "데이터융합팀 휴가관리 페이지"
    })
  })
}