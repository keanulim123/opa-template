library(shiny)
library(tidyverse)
library(haven)
library(here)
library(kableExtra)
library(readxl)
library(shinyjs)
#library(plotly)
library(shinyBS)
library(shinythemes)
library(ggplot2)

# not sure if this makes a difference
knitr::opts_knit$set(root.dir = here())
source("all_analysis.R")



nsims <- 1e4

# Before each deployment: copy and paste 'data' and 'rawdata' folders into 'shiny_app\'
# here() creates conflits with shiny deployment. Use source("all_analysis.R") intead
# source(here("code", "shiny_app", "all_analysis.R"))

#fluidPage is something must have
shinyUI(
  fluidPage(

    tags$head(
      tags$style(HTML(
        "
        .main-container{
        margin-right = 0px !important;
        max-width: 98% !important;
        }
        "
      ))
    ),
    theme = shinytheme("cerulean"),
    navbarPage("Open Policy Analysis for Project: Open Output Component",
               # Begin main policy estimate tab ----
               tabPanel(
                "Main Policy Estimate",
                sidebarPanel(
                  style = "width: 100%; max-height: 700px; overflow-y: scroll;",
                  fluidRow(column(
                    12,
                    align = "center",
                    tags$a(
                      img(
                        src = "bitss_just_logo_transparent.png",
                        width = "20%",
                        height = "auto"
                      ),
                      href = "https://bitss.org"
                    ),
                    tags$a(
                      img(
                        src = "cega_transparent.png",
                        width = "70%",
                        height = "auto"
                      ),
                      href = "https://cega.berkeley.edu"
                    )
                  )),
                  fluidRow(
                    style = "width: 100%; height: 100%; max-width: 400px;",
                    p(
                      "This visualization is one of three key components of an",
                      tags$a(href = "http://www.bitss.org/opa/projects/deworming/", "Open Policy Analysis (OPA)"),
                      "on <Insert Topic>. This components are:",
                      tags$li(
                        tags$span(
                          "This app, which presents a single output that best represents the factual information required by policy makers to inform their position regarding a policy of <Insert Topic>. Additional two other tabs allow reader to modify key assumptions and components and see how this output changes"
                        )
                      ),
                      tags$li(
                        tags$a(href = "https://bitss-opa.github.io/opa-deworming/", "A detailed report"),
                        "that describes how to obtain the final result and describes each component of the analysis"
                      ),
                      tags$li(
                        tags$a(href = "https://github.com/BITSS-OPA/opa-deworming", "A repository"),
                        "that contains all the materials needed to reproduce the analysis with minimal effort (report and interactive app)."
                      ),
                    ),
                    
                    p(
                      "See a full contributors list",
                      tags$a(href = "https://github.com/BITSS-OPA/opa-deworming/blob/master/readme.md", "here."), 
                      br(),
                      "See the dynamic document of this shiny app",
                      tags$a(href = "https://bitss-opa.github.io/opa-deworming/", "here."),
                      br(),
                      "See more OPA projects done by BITSS",
                      tags$a(href = "https://www.bitss.org/opa/projects/", "here.")
                    )
                  ),
                  fluidRow(
                    id = "tPanel_main",
                    style = "max-width: 400px; max-height: 300px; position:relative;",
                    br(),
                    h4(strong("Description of Results")),
                    p(
                      "Description of Results Content"
                    )
                  )
                ),
                 mainPanel(
                   fluidRow(id = "output_id1_main", style = "width: 100%; height: 100%; position: relative",
                            plotOutput("plot1_main")
                   )
                 )
               ),
               # end of main policy estimate tab ----
               # Begin of key assumptions tab ----
               tabPanel(
                 "Key Assumptions",
                 sidebarPanel(
                   div( id = "KA",
                   fluidRow(id = "tPanel1_ka",
                            style = "overflow-y: scroll; width: 100%; height: 100%; position:relative;",
                            numericInput(
                              "param_r1_ka",
                              label = h4("Parameter r1"),
                              value = r_input1_so,
                              min = 0
                            
                            ),
                            
                            numericInput(
                              "param_r2_ka",
                              label = h4("Parameter r2"),
                              value = r_input2_so,
                              min = 0
                              
                            )
                            
                            
                            
                            ),
                            actionButton("updateKA", "Update Plot", class = "btn-primary"),
                            actionButton("resetKA", "Reset Inputs"),
                            downloadButton("downloadPlotKA", "Save Plot")



                   
                   ),

                 ),
                 mainPanel(
                   fluidRow(id = "output_id1_ka", style = "width: 100%; height: 100%; position: relative",
                            plotOutput("plot1_ka")
                   )
                 )
               ),
               # end of key assumptions tab ----
               # Begin All assumptions tab ----
               tabPanel(
                 "All Assumptions",
                 sidebarPanel(
                   div(id = "All",
                   fluidRow(id = "tPanel",
                            style = "width: 100%; max-height: 100%; position: relative;",
                            # Begin policy estimate description ----
                            selectInput("final_result",
                                        h4("Final Result:"),
                                        choices = policy_estimates_text,
                                        selected = "A3. All income of A2. Main Policy Estimate"),
                            withMathJax(),
                            useShinyjs(),
                            conditionalPanel(
                              condition = "input.final_result == 'Main Equation' ",
                              helpText(
                               HTML("<p><a href = 'https://bitss-opa.github.io/opa-deworming/#21_Approach_1:_Baird_et_al_(2016)'>Approach 1.1.</a> Welfare measured as additional tax revenue.<br>
                                 - Benefits: tax revenue over predicted effect on earnings.
                                   Data from 10 year follow-up. No externalities. <br>
                                 - Costs: costs of treatment in Kenya in 1998 plus additional
                                   costs due to more schooling</p>")
                              )
                            ),
                            conditionalPanel(
                              condition = "input.final_result == 'Alternative Equation' ",
                              helpText(
                                HTML("<p><a href = 'https://bitss-opa.github.io/opa-deworming/#21_Approach_1:_Baird_et_al_(2016)'>Approach 1.2.</a> Welfare measured as additional tax revenue. <br>
                                 - Benefits: tax revenue over predicted effect on earnings.
                                   Data from 10 year follow-up. Including externalities. <br>
                                 - Costs: costs of treatment in Kenya in 1998 plus additional
                                   costs due to more schooling</p>")
                              )
                            ),
                            # end policy estimate description ----
                            checkboxInput("rescale",
                                          label = "Click to rescale x-axis. Unclick to fix reference point",
                                          value = FALSE),
                            numericInput("param_num_of_sim",
                                         label = h4("Number of simulations"),
                                         value = 1e4),
                            bsPopover(
                              id = "param_num_of_sim",
                              title = "",
                              content = "For faster computations, change the input to 100.",
                              placement = "top"
                            )
                   ),
                   fluidRow(id = "tPanel1",
                            style = "overflow-y: scroll; width: 100%; max-height: 250px; position: relative",
                            tabsetPanel(
                              # Begin tabpanel research ----
                              tabPanel(
                                "Research",
                                br(),
                                a(id = "toggleResearchSDs", "Show/hide all SDs", href =
                                    "#"),
                                br(),
                                br(),
                                numericInput(
                                  "param_q1",
                                  label = ("Q1"),
                                  value = q_input1_so
                                ),
                                bsPopover(
                                  id = "param_q1",
                                  title = "",
                                  content = "Interpretation for Param Q1",
                                  placement = "top"
                                ),
                                hidden(div(
                                  id = "SD3",
                                  numericInput(
                                    "param_q1_sd",
                                    label = "SD = ",
                                    value = q_input1_so * 0.1)
                                )),
                                
                                numericInput(
                                  "param_q2",
                                  label = ("Q2 "),
                                  value = q_input2_so
                                ),
                                bsPopover(
                                  id = "param_q2",
                                  title = "",
                                  content = "Interpretation for Param Q2",
                                  placement = "top"
                                ),
                                hidden(div(
                                  id = "SD4",
                                  numericInput(
                                    "param_q2_sd",
                                    label = "SD = ",
                                    value = q_input2_so * 0.1)
                                )),
                              ),
                                
                              # end tabpanel research ----
                              #
                              # Begin tabpanel data ----
                              tabPanel("Data",
                                       br(),
                                       a(id="toggleDataSDs", "Show/hide all SDs", href="#"),
                                       br(),
                                       br(),
                                       numericInput(
                                         "param_r1",
                                         label = "R1",
                                         value = r_input1_so,
                                         min = 0
                                       ),
                                       bsPopover(
                                         id = "param_r1",
                                         title = "",
                                         content = "Interpretations for r1",
                                         placement = "top"
                                       ),
                                       hidden(div(
                                         id = "SD1",
                                         sliderInput(
                                           "param_r1_sd",
                                           label = "SD = ",
                                           min = 0.000001 * r_input1_so,
                                           max = 1 * r_input1_so,
                                           value = 0.1 * r_input1_so,
                                           step = 0.001
                                         )
                                       )),
                                       sliderInput(
                                         "param_r2",
                                         label = "R2 ",
                                         min = r_input2_so/ 2,
                                         max = 2 * r_input2_so,
                                         value = r_input2_so
                                       ),
                                       bsPopover(
                                         id = "param_r2",
                                         title = "",
                                         content = "Interpretation for r2",
                                         placement = "top"
                                       ),
                                       hidden(div(
                                         id = "SD2",
                                         sliderInput(
                                           "param_r2_sd",
                                           label = "SD = ",
                                           min = 0.000001 * r_input2_so,
                                           max = 1 * r_input2_so,
                                           value = 0.1 * r_input2_so,
                                           step = 0.001
                                         )
                                       )),
                                       
                              ),
                              
                              # end tabpanel data ----
                              # Begin tabpanel GW ----
                              tabPanel(
                                "Guesswork",
                                br(),
                                a(id = "toggleGWSDs", "Show/hide all SDs", href =
                                    "#"),
                                br(),
                                br(),
                                sliderInput(
                                  "param_k1",
                                  label = "Parameter k1=  ",
                                  min = 0.1 * k_input1_so ,
                                  max = 2 * k_input1_so,
                                  value = k_input1_so
                                ),
                                bsPopover(
                                  id = "param_k1",
                                  title = "",
                                  content = "Interpretation for Param k1",
                                  placement = "top"
                                ),
                                hidden(div(
                                  id = "SD5",
                                  sliderInput(
                                    "param_k1_sd",
                                    label = "SD = ",
                                    min = 0.0000001 * k_input1_so,
                                    max = 1 * k_input1_so,
                                    value = 0.1 * k_input1_so
                                  )
                                )),
                                
                                
                                numericInput(
                                  "param_k2",
                                  label = ("Parameter k2 "),
                                  value = k_input2_so
                                ),
                                bsPopover(
                                  id = "param_k2",
                                  title = "",
                                  content = "Interpretation for Param k2",
                                  placement = "top"
                                ),
                                hidden(div(
                                  id = "SD6",
                                  numericInput(
                                    "param_k2_sd",
                                    label = "SD = ",
                                    value = k_input2_so * 0.1)
                                )),
                                
                              )
                              # end tabpanel GW ----
                            )
                   ),
                   fluidRow(id = "buttonUpdate",
                            style = "position:relative; padding-top:10px",
                            actionButton("updateAll", "Update Plot", class="btn-primary"),
                            actionButton("resetAll", "Reset Inputs")
                            
                            ),
                   fluidRow(id = "buttonDownload",
                            style = "position:relative; padding-top:10px;",
                            downloadButton("downloadParams", "Output Parameters"),
                            downloadButton("downloadPlotAll", "Save Plot")
                            )
                 )),
                 mainPanel(
                   fluidRow(id = "output_id1", style = "width: 100%; height: 100%; position:relative;",
                            plotOutput("plot1")
                   ),
                   fluidRow(id = "output_id2", style = "width: 100%; height: auto; position: absolute; top: 550px",
                            uiOutput('eqns', container = div)
                   )
                 )
               )
    )

  )


)
