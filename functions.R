makeReactiveTrigger = function() {
  rv = shiny::reactiveValues(a=0)
  list(
    depend = function() {
      rv$a
      invisible()
    },
    trigger = function() {
      rv$a = isolate(rv$a + 1)
    }
  )
}

myAlert = function(type, text) {
  if (type == "success") {
    shinyalert(
      title = "성공!",
      text = text,
      timer = 2000,
      type = type
    )
  } else if (type == "warning") {
    shinyalert(
      title = "경고!",
      text = text,
      timer = 2000,
      type = type
    )
  } else if (type == "error") {
    shinyalert(
      title = "에러!",
      text = text,
      timer = 2000,
      type = type
    )
  }
}