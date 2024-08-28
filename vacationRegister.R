vacRegUI = function(id){
  ns = NS(id)
  div(class = "flex justify-center items-center bg-white",
    div(class = "bg-white p-4 rounded-lg w-full max-w-md",
        p(class = "text-4xl font-bold mb-4 text-center", "휴가 신청하기"),
        dateInput(ns("register_date"), "휴가 일자", min = Sys.Date()),
        selectInput(ns("type"), "종류", choices = c("연차", "반차(오전)", "반차(오후)","병가")),
        actionButton(ns("submit"), "제출")
    )
  )
    # calendar UI로 대체
    # DTOutput(ns("vac_list"))

}

vacRegServer = function(id, conn, user_dt, db_sync) {
  moduleServer(id, function(input, output, session) {
    ns = session$ns
    output$vac_list = renderDT({
      user_dt()[order(-vac_date),.(ID=user_id, 이름 = name, 휴가일자 = vac_date, 휴가유형 = vac_type, 신청일자 = reg_date)]
    })
    # TODO: 남은 휴가 일수 보여주기.
      # 1) cred에서 유저 근무시작일, 사용 휴가 수 고려해 휴가 수 계산.
      # 2) 계산한 값 output으로 보여주기
      # 3) 사용 가능한 휴가 없으면 경고 메시지 / 동일한 휴가 일 신청도 안됨.
    
    work_start_date = user_dt()[1, work_start_date] |> as.Date()
    work_start_date_year = as.character(work_start_date) |> substr(1,4)
    work_start_date_month = as.character(work_start_date) |> substr(6,7)
    work_year2_date = work_start_date + 365
    work_year2_last_date = sprintf("%s-12-31", as.character(work_year2_date) |> substr(1,4)) |> as.Date()
    used_vac_days = user_dt()[,unique(vac_date)]
    
    working_days = difftime(Sys.Date(), work_start_date, units = "days") |> as.integer()
    
    # 근무 1년 미만: 월마다 휴가 1개씩 발생
    rv = reactiveValues()
    if(Sys.Date() < work_year2_date){
      used_vac_dt = user_dt()[year(vac_date) == work_start_date_year, .(vac_date, vac_type)]
      no_of_used_vac = used_vac_dt[,ifelse(vac_type %in% c("연차"), 1, 0.5)] |> sum()
      rv$left_vac_day = working_days %/% 30 - no_of_used_vac
    } else {
      # 근무 1년 이후: 연차 15개 지급
      if(Sys.Date() >= work_year2_date & Sys.Date() <= work_year2_last_date){
        # 단 입사 월 고려해서: 2년차 때는 15- 근무 해온 월
        used_vac_dt = user_dt()[year(vac_date) == year(work_year2_date) & 
          vac_date >= work_year2_date,  .(vac_date, vac_type)]
        no_of_used_vac = used_vac_dt[,ifelse(vac_type %in% c("연차"), 1, 0.5)] |> sum()
        rv$left_vac_day = 15 - work_start_date_month - no_of_used_vac + 1
        # 3년 때부터 15개 지급
      } else if (Sys.Date() > work_year2_last_date) {
        used_vac_dt = user_dt()[year(vac_date) == year(Sys.Date()), .(vac_date, vac_type)]
        no_of_used_vac = used_vac_dt[,ifelse(vac_type %in% c("연차"), 1, 0.5)] |> sum()
        rv$left_vac_day = 15 - no_of_used_vac
      }
    }

    output$left_vac = renderUI({
      h3(sprintf("남은 휴가일수: %s일",rv$left_vac_day))
    })

    observeEvent(input$submit, {
      reg_date = as.character(input$register_date)
      vac_reg_list = list(
        user_dt()[,unique(user_id)],
        reg_date,
        input$type,
        as.character(Sys.Date())
      )
      if(rv$left_vac_day <= 0){
        myAlert(type="error", text = "남아있는 휴가가 없습니다!")
      }
      if(reg_date %in% used_vac_days){
        myAlert(type="error", text = "신청한 일자에 이미 휴가가 등록되어 있습니다!")
      } else {
        sql = "INSERT INTO vacations (user_id, vac_date, vac_type, reg_date) values (?, ?, ?, ?)"
        dbExecute(conn, sql, vac_reg_list)
        db_sync$trigger()
        myAlert(type="success", text = "휴가 신청이 완료되었습니다.")
        Sys.sleep(1.5)
        shinyjs::refresh()
        # updateTabsetPanel(session, "menus", "home")
        # shiny::updateNavbarPage(session, "tabs", "home")
      }
    })
  })
}