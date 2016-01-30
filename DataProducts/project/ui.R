library(shiny)

# begin shiny UI
shinyUI(navbarPage("Car Consumption",
     # create first tab
     tabPanel("Documentation",
              h3("Car Consumption Prediction"),
              p("The prediction is based on a multivariate linear regression with the ",
                "following model:"),
              strong("mpg ~ wt + cyl + am + hp"),
              br(),br(),
              p("where:"),
              # ordered list
              tags$ul(
                tags$li(em("wt = "), "Weight expressed in lb/1000"),
                tags$li(em("cyl = "), "Number of cylinders"),
                tags$li(em("am = "), "Transmission (0 = automatic, 1 = manual)"),
                tags$li(em("hp = "), "Gross horsepower")
              ), br(),
              p("The result is:"),
              tags$ul(
                tags$li(em("mpg = "), "Miles/(US) gallon"),
                tags$li(em("lwr = "), "The lower value of the confidence interval"),
                tags$li(em("upr = "), "The upper value of the confidence interval")
              ),
              p("Just set the input parameters and click the ", em("Submit"), "button."),
              p("The data used to fit the model  was extracted from the 1974 Motor ",
                "Trend US magazine, and comprises fuel consumption and 10 aspects of",
                "automobile design and performance for 32 automobiles (1973–74 models)."),
              em("Source: Henderson and Velleman (1981), Building multiple regression models ",
                 "interactively. Biometrics, 37, 391–411.")
     ),
     # second tab
     tabPanel("Miles per Gallon Predictor",
              pageWithSidebar(
                # Application title
                headerPanel("Input parameters"),
                sidebarPanel(
                  numericInput('wt', 'Weight (lb/1000)', 3, min = 0, max = 6, step = 0.5),
                  radioButtons("cyl", "Number of cylinders", 
                                     choices = c("4" = "4", "6" = "6", "8" = "8"),  
                                                 selected = "4", inline = TRUE),
                  radioButtons("am", "Transmission", 
                                     choices = c("Automatic" = "0", "Manual" = "1"),  
                                     selected = "0", inline = TRUE),
                  sliderInput("hp", "Gross horsepower:", min = 50, max = 340, value = 145),
                  submitButton('Submit')
                ),
                mainPanel(
                  h3('Results of prediction'),
                  h4('You entered'),
                  strong('Weight:'),
                  textOutput("wtVal"),
                  strong('Number of cylinders:'),
                  textOutput("cylVal"),
                  strong('Transmission:'),
                  textOutput("amVal"),
                  strong('Gross horsepower:'),
                  textOutput("hpVal"),
                  h4('Which resulted in a prediction of '),
                  verbatimTextOutput("prediction")
                )
              )
     )
))