
if (require("lme4", quietly = TRUE) && require("effectsize", quietly = TRUE) && packageVersion("effectsize") > "0.4.3") {
  test_that("comparison rmcorr", {
    if (require("rmcorr", quietly = TRUE)) {
      set.seed(123)
      rez_rmcorr <- rmcorr::rmcorr(Species, Sepal.Length, Sepal.Width, dataset = iris)

      set.seed(123)
      rez <- cor_test(iris[c(1, 2, 5)], "Sepal.Length", "Sepal.Width", partial = TRUE, multilevel = TRUE)

      expect_equal(rez$r, rez_rmcorr$r, tolerance = 0.001)
      expect_equal(rez$p, rez_rmcorr$p, tolerance = 0.001)
      # expect_equal(rez$df_error, rez_rmcorr$df)
      expect_equal(rez$CI_low, rez_rmcorr$CI[1], tolerance = 0.01)
      expect_equal(rez$CI_high, rez_rmcorr$CI[2], tolerance = 0.01)
    }
  })


  test_that("Reductio ad absurdum", {
    if (require("bayestestR", quietly = TRUE)) {
      cormatrix <- matrix(c(
        1.0, 0.3, 0.6,
        0.3, 1.0, 0.0,
        0.6, 0.0, 1.0
      ), nrow = 3)

      data <- bayestestR::simulate_correlation(n = 500, r = cormatrix)
      # Add factor levels "at random", so the grouping structure should NOT change much
      data$Group <- sample(rep_len(c("A", "B", "C"), length.out = 500))

      rez <- correlation(data)
      expect_equal(max(as.matrix(rez) - cormatrix), 0, tolerance = 0.000001)

      rez <- correlation(data, multilevel = TRUE)
      expect_equal(max(as.matrix(rez) - cormatrix), 0, tolerance = 0.01)

      rez <- correlation(data, multilevel = TRUE, partial = TRUE)
      expect_equal(max(as.matrix(pcor_to_cor(rez)) - cormatrix), 0, tolerance = 0.01)
    }
  })
}
