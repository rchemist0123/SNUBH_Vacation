vacEditUI = function(id){
  
  ns = NS(id)
  h2("휴가 변경")
  div(class="container mx-auto px-4 py-8",
    h2(class="text-4xl font-bold mb-4", "휴가 수정"),
    div(class="flex justify-center",
      div(class="table-container bg-white shadow-md rounded-lg overflow-hidden md:w-1/2",
        uiOutput(ns("table"))
      )
    )
  )
  # actionButton(ns("update"),"수정/변경")
}

vacEditServer = function(id, conn, user_dt, db_sync) {
  moduleServer(id, function (input, output, session) {
    # 신청한 휴가 목록 불러오기
    # DT로 보여주기
    dt = reactiveVal(user_dt()[order(-vac_date)][vac_date > Sys.Date(),.(No = rowid(user_id), ID=user_id, 이름 = name, 휴가일자 = vac_date, 휴가유형 = vac_type, 신청일자 = reg_date)])
    output$table = renderUI({
      table_html = tags$table(class = "w-full divide-y divide-gray-200",
        tags$thead(class = "bg-gray-50",
          tags$tr(
            lapply(c(names(dt()), "수정"), \(name) {
              tags$th(class = "px-6 py-3 text-left text-lg font-medium text-gray-500 uppercase tracking-wider", name)
            })
          )
        ),
        tags$tbody(class = "bg-white divide-y divide-gray-200",
          lapply(1:nrow(dt()), \(i) {
            tags$tr(class = if(i %% 2 == 0) "bg-gray-50" else "bg-white",
              lapply(dt()[i,], \(value) {
                tags$td(class = "px-6 py-4 whitespace-nowrap text-md text-gray-500", value)
              }),
              tags$td(class = "px-6 py-4 whitespace-nowrap text-md text-md font-medium",
                actionButton(paste0("update_", dt()$No[i]), "수정", 
                            class = "text-indigo-600 hover:text-indigo-900 mr-2"),
                actionButton(paste0("delete_", dt()$No[i]), "삭제", 
                            class = "text-red-600 hover:text-red-900")
              )
            )
          })
        )
    )
     table_html
    })

    # 휴가 수정 하기
    # observeEvent(input[[paste0("update_",dt()$No)]], {
    #   print(input[[paste0("update_", dt()$No)]])
    #   # rn = as.numeric(sub("update_","", input[[paste0("update_", dt()$id)]]))
    #   # print(rn)
    #   # print(dt()[rn])
    #   # update modal 띄우기
    # })
    observeEvent(input$delete_row, {
      dt[input$delete_row] |> print()
    })

  })
}