library(shiny)

# Define UI for random distribution application 
shinyUI(fluidPage(
    titlePanel("Fantasy H2H Projection"),    
    fluidRow(
        column(4, wellPanel(
            dateRangeInput('dateRange',
                           label = '1. Date range input: (yyyy-mm-dd)',
                           start = Sys.Date() - 1, end = Sys.Date() + 6))
        ),
        column(4, wellPanel(
            fileInput('file1', '2. Upload matchups csv file:',
                      accept=c('.csv')),
            helpText(a("See file sample", href = "https://drive.google.com/open?id=0B-S1w3z_-BvCbmJDalBjVFNnUVU")))
        ),
        column(4, wellPanel(
            fileInput('file2', '3. Upload "Out list" csv file:',
                      accept=c('.csv')),
            helpText(a("See file sample", href = "https://drive.google.com/open?id=0B-S1w3z_-BvCX3FwR09jMjdsZWc")))
        )
    ),
    fluidRow(
        tabsetPanel(type = "tabs", 
                    tabPanel("Player List", 
                             dataTableOutput("contents")),
                    tabPanel("Projected", 
                             dataTableOutput("projected")),
                    tabPanel("Plot",
                             fluidRow(
                                 column(3, selectInput("selectItem", "Select stats:",
                                             choices = c("FG" = "cumFG",
                                                         "FT" = "cumFT",
                                                         "ThrPM" = "cumThrPM",
                                                         "PTS" = "cumPTS",
                                                         "REB" = "cumREB",
                                                         "AST" = "cumAST",
                                                         "STL" = "cumSTL",
                                                         "BLK" = "cumBLK",
                                                         "TO" = "cumTO"))),
                                 column(3,
                                        selectInput("inSelect2", "Select Fantasy Teams:",
                                                    multiple = TRUE,
                                                    c("label 1" = "option1",
                                                      "label 2" = "option2")))
                            ),
                            fluidRow(
                                column(11,
                                       plotOutput("projectedPlot"))    
                            )
                    ),
                    tabPanel("Detail", 
                             selectInput("inSelect", "Select Fantasy Team:",
                                         choices = c("label 1" = "option1",
                                                     "label 2" = "option2")),
                             dataTableOutput("detail"))
        )
    )
))