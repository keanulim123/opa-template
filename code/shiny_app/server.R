
library(shiny)

shinyServer( function(input, output, session) {
  #Dynamic UI


  #Show/hide SDs code.
  onclick("toggleDataSDs",
          lapply(
            c("SD1", "SD2"),
            toggle, anim=TRUE)
          )

  onclick("toggleResearchSDs",
          lapply(c("SD3", "SD4"), toggle, anim=TRUE))

  onclick("toggleGWSDs",
          lapply(c("SD5", "SD6"), toggle, anim=TRUE))


# Generate reactive simulated data for plotting

  reactive.data1<- reactive( {
    sim_data1_f(
      nsims = as.numeric(input$param_num_of_sim),
      r_input1_var2 = as.numeric(input$param_r1),
      r_input1_var2_sd = as.numeric(input$param_r1_sd),
      r_input2_var2 = as.numeric(input$param_r2),
      r_input2_var2_sd = as.numeric(input$param_r2_sd),
      q_input1_var2 = as.numeric(input$param_q1),
      q_input1_var2_sd = as.numeric(input$param_q1_sd),
      q_input2_var2 = as.numeric(input$param_q2),
      q_input2_var2_sd = as.numeric(input$param_q2_sd),
      k_input1_var2 = as.numeric(input$param_k1),
      k_input1_var2_sd = as.numeric(input$param_k1_sd),
      k_input2_var2 = as.numeric(input$param_k2),
      k_input2_var2_sd = as.numeric(input$param_k2_sd)
      
      
      
     
    )
  }
  )
  # Export Input Parameter Values
  output$downloadParams <- downloadHandler(
    filename = "export.txt",
    content = function(file) {
      inputList <- names(reactiveValuesToList(input))
      inputLabel <- inputMaster[inputList]
      exportVars <- paste0(inputLabel, " = ", sapply(inputList, function(inpt) input[[inpt]]))
      write(exportVars, file)
    })



  # Export All Assumption Plot
  output$downloadPlotAll <- downloadHandler(filename = function() {
    "plotAll.png"
  },
  content = function(file) {
    ggsave(file, plotInputAll(), height = 8, width = 12)
  })

  # Export Key Assumption Plot
  output$downloadPlotKA <- downloadHandler(filename = function() {
    "plotKA.png"
  },
  content = function(file) {
    ggsave(file, plotInputKA(), height = 8, width = 12)
  })

  # Sync r1 variable for Key Assumptions and All Assumptions

  observeEvent(
    input$param_r1_ka,
    updateSliderInput(session, "param_r1", value = input$param_r1_ka)
  )

  observeEvent(
    input$param_r1,
    updateSliderInput(session, "param_r1_ka", value = input$param_r1)
  )



  # Sync r2 variable for Key Assumptions and All Assumptions

  observeEvent(
    input$param_r2_ka,
    updateSliderInput(session, "param_r2", value = input$param_r2_ka)
  )

  observeEvent(
    input$param_r2,
    updateSliderInput(session, "param_r2_ka", value = input$param_r2)
  )

  

  # Reset all inputs from Key Assumption tab
  observeEvent(input$resetKA, {reset("KA")})

  # Reset all inputs from All Assumption tab
  observeEvent(input$resetAll, {reset("All")})

  # Show/hide components of each model
  observeEvent(input$final_result,{
    # all params
    list_master <- c(
      "param_r1",                                             #Data
      "param_r1_sd",
      "param_r2",
      "param_r2_sd",
     
      "param_q1",                                          #Research
      "param_q1_sd",
      "param_q2",
      "param_q2_sd",
      
      "param_k1",                                          #Guesswork
      "param_k1_sd",
      "param_k2",
      "param_k2_sd"
    )
    if (input$final_result == "Main Equation") {
      # remove: counts adj, costs adj, lambda 2, delda ed w/ext, new lambdas,
      # costs due to staff,
      # new gov bonds, new inflation, new cost of teaching,
      list_hide <- c("param_q1",
                     "param_q1_sd")
      list_show <- list_master[ - which(list_master %in% list_hide)]

    } else if (input$final_result == "Alternative Equation") {
      list_hide <- c("param_q2",
                     "param_q2_sd")
      list_show <- list_master[ - which(list_master %in% list_hide)]

    }
    sapply(list_hide,
           function(x) hideElement(id = x) )
    sapply(list_show,
           function(x) showElement(id = x) )
  })


  hideElement("show_eq")
  #observeEvent(input$run, {
  ################
  ###### Results/Viz
  ################
  output$eqns <- renderUI({
    #if (input$run == TRUE) {showElement("show_eq")}
      if (input$final_result == "Main Equation" ) {
        withMathJax(
          helpText('$$
              \\begin{equation}
              y = r + q - k
            \\tag{1}
            \\end{equation}
            $$ \n See', a("Approach 1", href='https://bitss-opa.github.io/opa-deworming/#21_Approach_1:_Baird_et_al_(2016)', target = "_blank"), 'in the documentation component for more details'  )
        )

      } else if (input$final_result ==  "Alternative Equation"){
        withMathJax(
          helpText('$$
              \\begin{equation}
              y = r + q + k

            \\tag{2}
            \\end{equation}
            $$ \n See' , a("Approach 1", href="05_final_opa.html#21_Approach_1:_Baird_et_al_(2016)", target = "_blank"),  'in the documentation component for more details'  )
        )
      } 
    })
  #})


  # Generate Plot with All Asumptions
  plotInputAll <- function(){
    npv_all_sim <- reactive.data1()
    plot1 <- generate_plot_f(npv_all_sim, input$final_result, input$rescale, TRUE)[[1]]

    position <- generate_plot_f(npv_all_sim, input$final_result, input$rescale, TRUE)[[2]]
    total_time_sim <- generate_plot_f(npv_all_sim, input$final_result, input$rescale, TRUE)[[3]]
    plot1 <- plot1 + labs(y = NULL,
                          x = "Net Present Value (Benefits -  Costs)" ,
                          title = "Net Lifetime Income Effects of Deworming for Each Treated Children",
                          subtitle = paste0(policy_estimates_text[position], ". ",
                                            "N = ", input$param_num_of_sim, " simulations. Takes ",
                                            total_time_sim," ",attributes(total_time_sim)$units )  )



  }
  output$plot1 <- renderPlot({
    input$updateAll
    
    isolate({print(plotInputAll())})
  }, height = 550
  )

  # Generate Plot with Key Assumptions
  plotInputKA <- function(){
    npv_all_sim <- reactive.data1()
    output_plot <- generate_plot_f(npv_all_sim, "Main Equation", input$rescale, TRUE)
    plot1 <- output_plot[[1]]

    position <- output_plot[[2]]

    plot1 <- plot1 + labs(y = NULL,
                          x = "Net Present Value (Benefits -  Costs)" ,
                          title = "Net Lifetime Income Effects of Deworming for Each Treated Children",
                          subtitle = paste0(policy_estimates_text[position], ". ")
    )
  }

  
  output$plot1_ka <- renderPlot({
    
    input$updateKA
    isolate(print(plotInputKA()))

  }, height = 550
  )
  


  # Generate Main Policy Estimate Plot
  output$plot1_main <- renderPlot({
    npv_all_sim <- reactive.data1()
    output_plot <- generate_plot_f(npv_all_sim, "Main Equation", input$rescale)
    plot1 <- output_plot[[1]]

    position <- output_plot[[2]]

    plot1 <- plot1 + labs(y = NULL,
           x = "Net Present Value (Benefits -  Costs)" ,
           title = "Net Lifetime Income Effects of Deworming for Each Treated Children",
           subtitle = "Distribution of the Net Present Value of Deworming Interventions"
           )
    print(plot1)
  }, height = 550
  )

  # Master List of Input ID & Label

  inputMaster <- c(# ---- Key Assumptions
                   "param_r1_ka" = "r1",
                   "param_r2_ka" = "r2",
                   "resetKA" = "Reset Button for Key Assumptions",
                   "updateKA" = "Update Button for Key Assumptions",
                   # ---- All Assumptions
                   "rescale" = "Rescale Checkbox Status",
                   "final_result" = "Final Result Assumption",
                   "param_num_of_sim" = "Number of simulations",
                   "resetAll" = "Reset Button for All Assumptions",
                   "updateAll" = "Update Button for All Assumptions",
                   # ---- research tab

                   "param_q1" = "q1",
                   "param_q1_sd" = "SD of q1",
                   "param_q2" = "q2",
                   "param_q2_sd" = "SD of q2",
                   
                   #---- data tab
                   "param_r1" = "r1",
                   "param_r1_sd" = "SD of r1",
                   "param_r2" = "r2",
                   "param_r2_sd" = "SD of r2",
                   
                   # ---- GW tab
                   "param_k1" = "k1",
                   "param_k1_sd" = "SD of k1",
                   "param_k2" = "k2",
                   "param_k2_sd" = "SD of k2",
                 
                   # ---- Buttons for All Assumption tab
                   "resetAll" = "Reset Button for All Assumptions",
                   "show_eq" = "Show Equation Checkbox Status"



                   )


})
