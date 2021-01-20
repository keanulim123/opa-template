# Tutorial on how to reproduce and modify the Shiny App for the Open Policy Analysis Project

The shiny app for the OPA Project contains three files: `ui.R`, `server.R`, and `all_analysis.R`.
- `01_final_opa` file contains the full walkthrough for the analysis, which is then represented in a more code-friendly way in `all_analysis.R`
- The data is `all_analysis.R` is passed to...
    - `ui.R`, which is the user interface
    - `server.R`, which manages the server components of the shiny app

The purpose of the shiny app is to allow the user to experiment with the data to see the changes that those differences make, in order to better understand the analysis. It turns policy analysis, which is often complex and hard to understand, into an easily readable and understandable format.

## Your setup to reproduce and modify the `ui.R` of the OPA Project

- To run the shiny app (SA) you will need to install R and RStudio. The relevant file can be found by running `ui.R` or `server.R`.

- Click 'Run App' located at the top of RStudio. This will open the SA.

- The SA has three tabs to explore
    - Main Policy Estimate, which describes the results. There is no interactive capabilities on this tab.
    - Key Assumptions, where you can adjust 'param A', 'param B', 'param C'.
    - Main Assumptions, where you can adjust 'param A' and 'param B', as well as the parameters in 'Data' and 'Research' tabs
        - Data
            - Param 1 (and SD)
            - Param 2 (and SD)
        - Research
            - Param 3 (and SD)
            - Param 4 (and SD)

### Beginning

- Describe relevant code below
- The code begins with a list of all relevant libraries
- At the top of the SA, it says "Open Policy Analysis for XXX: Open Output Component"
    - This is created using `navbarPage`


### The tabs

- All three tabs are created using `tabPanel`.
  - Then, use sidebarPanel, which creates the panel on the left side of the screen. For tab titled "Main Policy Estimate", this only consists of text and links.
    - `fluidrow` creates rows, such as "Param A" in "Key Assumptions".
  - `mainPanel` creates the graph seen on the right

### The functions

- `shinyUI` -> creates a user interface
- `fluidPage` -> creates a page
- `navbarPage` -> creates a page with a navigation bar at the top
- `tabPanel` -> creates a tab panel, takes in a title (i.e. "Main Result") and a value
- `sidebarPanel` -> creates a sidebar that has input controls
- `tags$a` -> creates a link
- `mainPanel` -> creates a main panel of output elements
- `plotOutput` -> creates a plot
- `checkboxInput` -> creates a checkbox used to specify logical values
- `numericInput` -> creates an input control for numeric values
- `withMathJax` -> loads in MathJax, a JavaScript library
- `useShinyjs` -> loads in Shinyjs, an r package
- `helpText` -> creates text to help explain some element of the SA
- `selectInput` -> creates a list of choices
- `sliderInput` -> creates a slider widget containing numbers in a range
- `tabsetPanel` -> creates a tabset containing elements from tabPanel
- `uiOutput` -> tells Shiny where the controls should be rendered

## Your setup to reproduce and modify the `server.R` file of the OPA Project

### The functions

- `sim_data1_f` -> returns a random sample from some distributions
- `as.numeric` -> converts a factor to a numeric factor
- `observeEvent` -> chooses which slider inputs to show and which sliders to not show
- `which` -> returns the indices that are True
- `paste` -> links vectors together after to character
- `ggplot` -> data visualization package
    - `geom_density` -> computes and draws density estimate
    - `geom_vline` -> annotates the plot with vertical lines
    - `xlim` -> sets the min and max boundaries of the plot in the x-direction
    - `guides` -> the guide is set scale-by-scale for each scale
    - `annotate` -> adds small annotations, i.e. text labels
    - `theme` -> sets the theme of the plot by costumizing all non-data components

### Walkthrough

- `reactive.data1` is an R expression that uses a widget input and outputs a value, and in this case the input is `sim_data1_f`.
- `sim_data1_f` sets variable names by turning the parameters used in `ui.R` to numeric factors
- The following section of `server.R` is `if` statements that are used to show which parameters to hide for different inputs of final result assumptions.
- Then, the code adds help text to the SA depending on the input for final result assumptions.
- The next section defines a function that generates simulation plots
    - `If` statements specify what texts to display and what `selectInput` to call for each of the three different plots (Main, ka, all)
    - Then, the code constructs the plot for all three tabs
        - All have the same axes
        - All are density plots
        - All share the same plot structure

### How to add a new slider to the UI

- In order to add a slider, you will want to use the `sliderInput` function in `ui. R`. `sliderInput` is a widget that creates a slider across a range. It has five inputs: inputId, label, min, max, and value. Below is an example:

    `sliderInput("param_name", label = "Parameter Name (X) ", min = 0.001, max = 0.2, value = param_so)`

- Here, `param_name` is the inputID, `Parameter Name (X)` is the label, min is 0.001, max is 0.2, and the default display value is `param_so`

- To add a new slider, you will first need to figure out what the inputID should be.
    - First, you will need to add the inputID to the server file. Define a variable in the function `sim_data1_f` in `server.R`. For the example above this would be `param_name_var2 = as.numeric(input$param_name)`.
    - `sim_data1_f` is contained in the `reactive.data1`.
- Then, if you don't want the slider to appear for certain inputs of final result, insert it in `else if(input$final_result == "What policy estimate
you don't want the slider to appear in")`.
- It goes in the `list_hide` function within the else if. Once that has been added, that variable, in this case `param_name_var2`, should be added to `sim_data1_f` in `all_analysis.R`. This deals directly with the original analysis.

- EXPLAIN: `knitr::purl("code/01_final_opa.Rmd", "code/shiny_app/all_analysis.R")`

- If the slider you want to add is already in `all_analysis.R`, make sure to use the name defined in `all_analysis.R`, then add it to `server.R`, and then `ui.R`.

- To change the value, which is `param_so` in the above example, modify it in the "Data" section of `all_analysis.R`.

## The chart below shows the way that the different components of the OPA interact with each other

<img align="center" width="50%" src="./www/sa_readme_chart.png">

The line, `knitr::purl("code/01_final_opa.Rmd", "code/shiny_app/all_analysis.R")` converts the R markdown in `01_final_opa.Rmd` to R script in `all_analysis.R`.
This means that when data is updated or added in `01_final_opa.Rmd`, it will update the `all_analysis.R` file.
