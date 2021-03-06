context("impute y")

test_that("impute y", {

  # silent mode
  options(parallelMap.suppress.local.errors = TRUE)

  par.set = makeNumericParamSet(len = 2L, lower = 0, upper = 3)
  f1 = smoof::makeSingleObjectiveFunction(
    fn = function(x) {
      y = sum(x^2)
      if (y < 5)
        return(NA)
      return(y)
    },
    par.set = par.set
  )

  f2 = smoof::makeSingleObjectiveFunction(
    fn = function(x) {
      y = sum(x^2)
      if (y < 5)
        stop("foo")
      return(y)
    },
    par.set = par.set
  )

  learner = makeLearner("regr.randomForest")

  n.focus.points = 100L
  ctrl = makeMBOControl(iters = 20)
  ctrl = setMBOControlInfill(ctrl, opt.focussearch.points = n.focus.points)
  expect_error(mbo(f1, des = NULL, learner, ctrl), "must be a numeric of length 1")

  ctrl = makeMBOControl(iters = 20, impute.y.fun = function(x, y, opt.path) 0)
  ctrl = setMBOControlInfill(ctrl, opt.focussearch.points = n.focus.points)
  res = mbo(f1, des = NULL, learner, ctrl)

  # Check for correct error messages
  na.inds = which(getOptPathY(res$opt.path) == 0)
  for (ind in 1:getOptPathLength(res$opt.path)) {
    if(ind %in% na.inds)
      expect_equal(grep("mlrMBO:", getOptPathErrorMessages(res$opt.path)[ind]), 1)
    else
      expect_equal(NA_character_, getOptPathErrorMessages(res$opt.path)[ind])
  }

  ctrl = makeMBOControl(iters = 50)
  ctrl = setMBOControlInfill(ctrl, opt.focussearch.points = n.focus.points)
  expect_error(mbo(f2, des = NULL, learner, ctrl), "foo")
  ctrl = makeMBOControl(iters = 50, impute.y.fun = function(x, y, opt.path) 0)
  ctrl = setMBOControlInfill(ctrl, opt.focussearch.points = n.focus.points)
  res = mbo(f2, des = NULL, learner, ctrl)
  # Check for correct error messages
  na.inds = which(getOptPathY(res$opt.path) == 0)
  for (ind in 1:getOptPathLength(res$opt.path)) {
    if(ind %in% na.inds)
      expect_equal(grep("foo", getOptPathErrorMessages(res$opt.path)[ind]), 1)
    else
      expect_equal(NA_character_, getOptPathErrorMessages(res$opt.path)[ind])
  }

  # turn off silent mode
  options(parallelMap.suppress.local.errors = FALSE)
})

test_that("impute y parego", {

  # Test impute
  f1 = smoof::makeMultiObjectiveFunction(
    fn = function(x) {
      y = x^2
      ifelse(y < 2, NA, y)
    },
    par.set = makeNumericParamSet(len = 2L, lower = 0, upper = 3),
    n.objectives = 2L
  )
  learner = makeLearner("regr.rpart")
  ctrl = makeMBOControl(init.design.points = 10L, iters = 5, number.of.targets = 2L,
    impute.y.fun = function(x, y, opt.path) c(100, 100))
  ctrl = setMBOControlInfill(ctrl, opt.focussearch.points = 10)
  ctrl = setMBOControlMultiCrit(ctrl, method = "parego", parego.s = 100)
  or = mbo(f1, learner = learner, control = ctrl)
  op = as.data.frame(or$opt.path)
  expect_equal(nrow(op), 10 + 5)
  expect_true(all(is.na(op$error.message) | op$y1 == 100))
})
