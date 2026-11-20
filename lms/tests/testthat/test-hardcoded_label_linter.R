label_message <- "Don't hardcode a variable label"

test_that("string literals in labs() aesthetics are flagged", {
  lintr::expect_lint(
    'labs(x = "Wage (thousands of dollars)")',
    label_message,
    hardcoded_label_linter()
  )
  lintr::expect_lint(
    'ggplot2::labs(x = "Age (years)", y = "Wage", colour = "Span")',
    list(label_message, label_message, label_message),
    hardcoded_label_linter()
  )
  lintr::expect_lint(
    'p + labs(fill = paste0("Group ", k))',
    label_message,
    hardcoded_label_linter()
  )
})

test_that("labs() arguments that describe the plot are not flagged", {
  lintr::expect_no_lint(
    'labs(title = "Wages", subtitle = "2003", caption = "Source: ISL")',
    hardcoded_label_linter()
  )
  lintr::expect_no_lint(
    'labs(tag = "A", alt = "A scatter plot of wage against age")',
    hardcoded_label_linter()
  )
  lintr::expect_lint(
    'labs(title = "Wages", x = "Age")',
    list(message = label_message, column_number = 27L),
    hardcoded_label_linter()
  )
})

test_that("xlab(), ylab(), scales and guides are checked", {
  lintr::expect_lint('xlab("Age")', label_message, hardcoded_label_linter())
  lintr::expect_lint(
    'ggplot2::ylab(label = "Wage")',
    label_message,
    hardcoded_label_linter()
  )
  lintr::expect_lint(
    'scale_x_continuous("Age (years)", limits = c(0, 10))',
    label_message,
    hardcoded_label_linter()
  )
  lintr::expect_lint(
    'scale_colour_manual(name = "Span", values = cols)',
    label_message,
    hardcoded_label_linter()
  )
  lintr::expect_lint(
    'guides(colour = guide_legend(title = "Span"))',
    label_message,
    hardcoded_label_linter()
  )
})

test_that("scale arguments other than the name are not flagged", {
  lintr::expect_no_lint(
    'scale_x_continuous(breaks = 1:3, labels = c("a", "b", "c"))',
    hardcoded_label_linter()
  )
  lintr::expect_no_lint(
    'scale_colour_manual(values = c(a = "red", b = "blue"))',
    hardcoded_label_linter()
  )
})

test_that("table column labels are checked", {
  lintr::expect_lint(
    'knitr::kable(df, col.names = c("Age", "Wage"))',
    label_message,
    hardcoded_label_linter()
  )
  lintr::expect_lint(
    'DT::datatable(df, colnames = c("Age", "Wage"))',
    label_message,
    hardcoded_label_linter()
  )
  lintr::expect_lint(
    'tbl |> gt::cols_label(age = "Age", wage = "Wage")',
    list(label_message, label_message),
    hardcoded_label_linter()
  )
  lintr::expect_lint(
    'flextable::set_header_labels(ft, values = list(age = "Age"))',
    label_message,
    hardcoded_label_linter()
  )
  lintr::expect_no_lint(
    'knitr::kable(df, digits = 2, caption = "Wages by age")',
    hardcoded_label_linter()
  )
})

test_that("labels read from the data are not flagged", {
  lintr::expect_no_lint(
    "labs(x = labelled::var_label(df$age))",
    hardcoded_label_linter()
  )
  lintr::expect_no_lint(
    'labs(x = labelled::var_label(df[["age"]]))',
    hardcoded_label_linter()
  )
  lintr::expect_no_lint(
    "knitr::kable(df, col.names = labelled::var_label(df, unlist = TRUE))",
    hardcoded_label_linter()
  )
  lintr::expect_no_lint(
    "labs(x = expression(beta), y = NULL)",
    hardcoded_label_linter()
  )
})

test_that("a dictionary is flagged inline but not as a named object", {
  lintr::expect_lint(
    'labs(dictionary = c(count = "Number of workers"))',
    label_message,
    hardcoded_label_linter()
  )
  lintr::expect_no_lint(
    "labs(dictionary = wage_labels)",
    hardcoded_label_linter()
  )
})

test_that("setting labels in preprocessing is not flagged", {
  lintr::expect_no_lint(
    'df |> labelled::set_variable_labels(wage = "Wage (thousands of dollars)")',
    hardcoded_label_linter()
  )
})

test_that("default_linters(nested_calls = TRUE) includes it", {
  linters <- default_linters(nested_calls = TRUE)
  expect_true("hardcoded_label_linter" %in% names(linters))
  expect_false("hardcoded_label_linter" %in% names(default_linters()))
})
