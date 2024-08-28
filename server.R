
dbtrigger = makeReactiveTrigger()
# user_dt = reactiveVal({
#   dbGetQuery(pool, "SELECT * FROM users")
# })

cookie_expiry = 7

pool = DBI::dbConnect(RSQLite::SQLite(), dbname="db.db")

add_sessionid_to_db = function(user_id, sessionid, conn = pool) {
  tmp = data.frame(user_id = user_id, sessionid = sessionid, login_time = as.character(Sys.time()))
  dbWriteTable(conn, "sessionids", tmp, append = TRUE)
}

get_sessionids_from_db = function(conn = pool, expiry = cookie_expiry) {
  dt = dbReadTable(conn, "sessionids") |> setDT()
  dt[,login_time := sprintf("%s %s", as.IDate(login_time), as.ITime(login_time))] |> 
    _[login_time > (Sys.time() - 3600*24*expiry)]
}


function(input, output, session) {
  useShinyjs()
  # pool = DBI::dbConnect(RSQLite::SQLite(), dbname="db.db")
  sql = "SELECT * FROM users"
  user_all_dt = dbGetQuery(pool, sql) |> setDT()

  observeEvent(input$signup_btn, {
    signupUI(id = "signup")
  })

  observeEvent(dbtrigger$depend(), {
    print("updating")
  #   updated_user = DBI::dbReadTable(pool, "users")
  #   DBI::dbDisconnect(pool)
  #   user_dt = updated_user
  })
  
  credentials = shinyauthr::loginServer(
    id = "login",
    data = user_all_dt,
    user_col = user_id,
    pwd_col = password,
    sodium_hashed = TRUE,
    cookie_logins = TRUE,
    sessionid_col = sessionid,
    cookie_setter = add_sessionid_to_db,
    cookie_getter = get_sessionids_from_db,
    log_out = reactive(logout_init())
  )

  user_dt = reactive({
    req(credentials()$info)
    dbtrigger$depend()
    sql = "SELECT users.user_id, password, name, work_start_date, vac_id, vac_date, vac_type, reg_date
            FROM users left join vacations on users.user_id = vacations.user_id
            WHERE users.user_id = ?"
    dt = dbGetQuery(pool, sql, credentials()$info$user_id) |> setDT()
    dt
  })
  logout_init = shinyauthr::logoutServer(
    id = "logout",
    active = reactive(credentials()$user_auth)
  )

  signupServer(id = "signup", conn = pool, user_dt = user_all_dt, db_sync = dbtrigger)
  output$vac_tabs = renderUI({
    req(credentials()$user_auth)
      tagList(
        tabPanel("휴가 등록"),
        tabPanel("휴가 변경")
      )
  })
  hideTab("tabs", target="휴가 등록")
  hideTab("tabs", target="휴가 변경")
  observeEvent(credentials()$info,{
    showTab("tabs", target="휴가 등록")
    showTab("tabs", target="휴가 변경")
    vacRegServer("vac_reg", pool, user_dt = user_dt, db_sync = dbtrigger)
    calendarServer("vac_cal", user_dt = user_dt)
    homeServer("home")
    vacEditServer("vac_edit", pool, user_dt = user_dt, db_sync = dbtrigger)
  })

}