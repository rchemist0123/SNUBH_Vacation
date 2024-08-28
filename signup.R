signupUI = function(id) {
  ns = NS(id)
  showModal(
    modalDialog(
      div(class = "flex justify-center items-center bg-white",
        div(class = "bg-white p-4 rounded-lg w-full max-w-md",
            h2(class = "text-2xl font-bold mb-4 text-center", "연구원 등록"),
            div(class = "mb-4", textInput(ns("new_id"), "ID")),
            div(class = "mb-4", passwordInput(ns("new_pw"), "Password")),
            div(class = "mb-4", textInput(ns("new_name"), "이름")),
            div(class = "mb-4", dateInput(ns("work_start_date"), "근무 시작일", max= Sys.Date())),
            actionButton(ns("signup"), "Sign Up", class = "w-full bg-blue-500 text-white font-bold py-2 px-4 rounded hover:bg-blue-700")
        )
      ),
      # title = "연구원 등록",
      # textInput(ns("new_id"), "ID"),
      # passwordInput(ns("new_pw"), "Password"),
      # textInput(ns("new_name"), "이름"),
      # dateInput(ns("work_start_date"), "근무 시작일"),
      # actionButton(ns("signup"),"Sign Up"),
      easyClose = TRUE,
      size = "s",
    )
  )
}

signupServer = function(id, conn, user_dt, db_sync) {
  moduleServer(id, function(input, output, session) {
    ns = session$ns
    iv = InputValidator$new()
    iv$add_rule("new_id", sv_required(message = "아이디를 입력해주세요."))
    iv$add_rule("new_pw", sv_required(message = "비밀번호를 입력해주세요."))
    iv$add_rule("new_name", sv_required(message = "이름은 필수입니다."))

    observeEvent(input$signup, {
      new_user_info_list = list(
        input$new_id,
        sodium::password_store(input$new_pw),
        input$new_name,
        as.character(input$work_start_date),
        "user"
      )
      if(iv$is_valid()){
        if(input$new_id %in% user_dt$user_id){
          showNotification(
            "이미 등록된 연구원입니다!",
            type="error"
          )
        } else {
          sql = "INSERT INTO users values (?, ?, ?, ?, ?)"
          dbExecute(conn, sql, new_user_info_list)
          dbDisconnect(conn)
          db_sync$trigger()
          showNotification(
            "연구원 등록이 완료되었습니다!",
            type="message"
          )
          Sys.sleep(1)
          shinyjs::refresh()
        }
      } else {
        iv$enable()
      }
    })
  })
}