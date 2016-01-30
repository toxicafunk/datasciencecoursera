library(shiny)
library(datasets)

# We only need a specific subset of mtcars
mpgData <- mtcars[,c(1,2,4,6,9)]

# We cast the "am" and "cyl" field to be factors. Since this doesn't
# rely on any user inputs we can do this once at startup and then use the
# value throughout the lifetime of the application
mpgData$am <- factor(mpgData$am)
mpgData$cyl <- factor(mpgData$cyl)

fit <- lm(mpg ~ wt + cyl + am + hp, mpgData)

# start shinyServer
shinyServer(
  # specify input/output function
  function(input, output) {
    output$wtVal <- renderText({input$wt})
    output$cylVal <- renderText({input$cyl})
    output$amVal <- renderText({ifelse(input$am == 0, "Automatic", "Manual")})
    output$hpVal <- renderText({input$hp})
    output$prediction <- renderPrint({
      predict(fit, newdata = data.frame(wt=input$wt, cyl=input$cyl, am=input$am, hp=input$hp), interval = ("prediction"))
    })
  }
)