context("mbo resample")

test_that("mbo works with resampling", {
  f = makeSingleObjectiveFunction(
    fn = function(x) sum(x^2),
    par.set = makeParamSet(
      makeNumericVectorParam("x", len = 2, lower = 0, upper = 1)
    )
  )
  learner = makeLearner("regr.randomForest")
  ctrl = makeMBOControl(iters = 5L, resample.at = c(1, 3))
  ctrl = setMBOControlInfill(ctrl, opt.focussearch.points = 10L)
  or = mbo(f, des = NULL, learner, ctrl)
  x = or$resample.results
  expect_true(is.list(x) && length(x) == 2)
  expect_true(is.numeric(x[[1]]$aggr) && is.numeric(x[[2]]$aggr))
  expect_equal(names(x), c("1", "3"))
})
