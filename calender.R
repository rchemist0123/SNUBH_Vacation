calendarUI = function (id) {
  ns = NS(id)
  div(class="w-full flex justify-center",
    div(class="md:w-2/3 overflow-x-auto shadow-md sm:rounded-lg",
      calendarOutput(ns("calendar"))
  )
  )
}

colors = data.frame(
  pastel = c("#ffb3ba","#ffdfba","#ffffba","#baffc9","#bae1ff"),
  real = c("#FF0000","#ff8000","#fff200","#06fd0e", "#00ccff")
)

calendarServer = function (id, user_dt){
  moduleServer(id, function(input, output, session){
    output$calendar = renderCalendar({
      a = user_dt() |> as.data.table()
      color = data.table(name = unique(a$name),
                        color = colors[1:length(unique(a$name)), "pastel"],
                        border = colors[1:length(unique(a$name)), "real"]
                      )
      a[color, on="name", `:=`(backgroundColor = i.color, border = i.border)]
      a[, color := "black"]
      a[, borderColor := border]
      a[, title := vac_type]
      a[, category := "allday"]
      a[, recurrenceRule := NA]
      setnames(a, "vac_date", "start")
      a[, end := start]

      # a[, end := ifelse(type == "반차(오후)", sprintf("%s 18:00:00", start),
      #             ifelse(type == "반차(오전)", sprintf("%s 13:00:00",start), start))]
      
      toastui::calendar(a, navigation = T, defaultDate = Sys.Date(),
                        narrowWeekend=T, isReadOnly = T)
    })

    # observeEvent(input$calendar_delete,{
    #   str(input$calendar_delete)
    #   cal_proxy_delete("calendar", input$my_calendar_delete)
    # })

  })
}