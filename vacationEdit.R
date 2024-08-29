vacEditUI = function(id){
  "휴가 변경"
  ns = NS(id)
  div(class="w-full flex flex-col items-center",
    h2(class="text-4xl font-bold mb-4", "휴가 현황"),
    div(class="w-2/3 px-4 py-8 flex flex-col items-center",
      div(class ="mb-4",
        # actionButton("update","변경", class = "bg-blue-500 hover:bg-blue-700 text-white hover:text-white font-bold py-2 px-4 rounded"),
        # actionButton("update","삭제", class = "bg-red-500 hover:bg-red-700 text-white hover:text-white font-bold py-2 px-4 rounded"),
      ),
      div(class="w-full",
        DTOutput(ns("table"))
      )
    )
  )
}

vacEditServer = function(id, conn, user_dt, db_sync) {
  moduleServer(id, function (input, output, session) {
    # 신청한 휴가 목록 불러오기
    # DT로 보여주기
    dt = reactiveVal(user_dt()[order(-vac_date)][vac_date > Sys.Date(),.(No = rowid(user_id), ID=user_id, 이름 = name, 휴가일자 = vac_date, 휴가유형 = vac_type, 신청일자 = reg_date)])
    output$table = renderDT({
      data = dt()
      data$buttons = paste0(
        '<button class="update bg-blue-500 hover:bg-blue-700 text-white font-bold py-1 px-2 rounded mr-1" data-id="', data$id, '">변경</button>',
      '<button class="delete bg-red-500 hover:bg-red-700 text-white font-bold py-1 px-2 rounded" data-id="', data$id, '">삭제</button>'
      )
      datatable(
        data, 
        selection = "none", 
        escape = FALSE, 
        options = list(
          columnDefs = list(
            list(targets = which(names(data) =="buttons") -1, orderdable = F)
          )
          ),
          callback = JS("
            table.on('click', 'button.update', function(){
              let data = table.row($(this).parents('tr)).data();
              Shiny.setInputValue('update_button', data[0]);
            });
            table.on('click', 'button.delete', function(){
              let data = table.row($(this).parents('tr)).data();
              Shiny.setInputValue('delete_button', data[0]);
            });
          
          ")
      )
    })
    observeEvent(input$update_button,{
      print("hi")
    })
    # output$table = renderDT({
    #   table_html = tags$table(class = "min-w-full divide-y divide-gray-200",
    #   tags$thead(class = "bg-gray-50",
    #     tags$tr(
    #       lapply(c(names(dt()), "수정"), \(name) {
    #         tags$th(class = "px-6 py-3 text-left text-lg font-medium text-gray-500 uppercase tracking-wider", name)
    #       })
    #     )
    #   ),
    #   tags$tbody(class = "bg-white divide-y divide-gray-200",
    #     lapply(1:nrow(dt()), \(i) {
    #       tags$tr(class = if(i %% 2 == 0) "bg-gray-50" else "bg-white",
    #         lapply(dt()[i,], \(value) {
    #           tags$td(class = "px-6 py-4 whitespace-nowrap text-md text-gray-500", value)
    #         }),
    #         tags$td(class = "px-6 py-4 whitespace-nowrap text-right text-md font-medium",
    #           actionButton(paste0("update_", dt()$No[i]), "수정", 
    #                        class = "text-indigo-600 hover:text-indigo-900 mr-2"),
    #           actionButton(paste0("delete_", dt()$No[i]), "삭제", 
    #                        class = "text-red-600 hover:text-red-900")
    #         )
    #       )
    #     })
    #   )
    # )
    #  table_html
    # })

    # 휴가 수정 하기
    # 문제: input ID 찾아서 활용 필요..
    # observeEvent(input[[paste0("update_",dt()$No)]], {
    #   print(input[[paste0("update_", dt()$No)]])
    #   # rn = as.numeric(sub("update_","", input[[paste0("update_", dt()$id)]]))
    #   # print(rn)
    #   # print(dt()[rn])
    #   # update modal 띄우기
    # })
    # observeEvent(input$delete_row, {
    #   dt[input$delete_row] |> print()
    # })

  })
}