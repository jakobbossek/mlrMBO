context("mbo")

test_that("mbo works with rf", {
  par.set = makeParamSet(
    makeNumericParam("x1", lower = -2, upper = 1),
    makeNumericParam("x2", lower = -1, upper = 2)
  )
  f = makeSingleObjectiveFunction(
    fn = function(x) sum(x^2),
    par.set = par.set
  )
  des = generateDesign(10L, par.set = par.set)
  y  = sapply(1:nrow(des), function(i) f(as.list(des[i,])))
  des$y = y
  learner = makeLearner("regr.randomForest")
  ctrl = makeMBOControl(iters = 5L, store.model.at = c(1,5))
  ctrl = setMBOControlInfill(ctrl, opt.focussearch.points = 100L)
  or = mbo(f, des, learner, ctrl, show.info = TRUE)
  expect_true(!is.na(or$y))
  expect_equal(or$y, f(or$x))
  expect_equal(getOptPathLength(or$opt.path), 15)
  expect_true(is.list(or$x))
  expect_equal(names(or$x), names(par.set$pars))
  expect_equal(length(or$models[[1]]$subset), 10)
  expect_equal(length(or$models[[2]]$subset), 14) #In the 15th step we used a model based on 14

  # check errors
  ctrl = makeMBOControl(iters = 5)
  ctrl = setMBOControlInfill(ctrl, crit = "ei", opt.focussearch.points = 100L)
  expect_error(mbo(f, des, learner, ctrl), "must be set to 'se'")
  ctrl = makeMBOControl(iters = 5)
  ctrl = setMBOControlInfill(ctrl, opt.focussearch.points = 100L)

  # f2 = makeMBOFunction(function(x) x^2)
  # expect_error(mbo(f2, des, learner, ctrl), "wrong length")

  ctrl = makeMBOControl(iters = 5)
  ctrl = setMBOControlInfill(ctrl, opt.focussearch.points = 100L)
  learner = makeLearner("classif.randomForest")
  expect_error(mbo(f, des, learner, ctrl), "mbo requires regression learner")
  learner = makeLearner("regr.randomForest")
  # check trafo
  par.set = makeParamSet(
    makeNumericParam("x1", lower = -10, upper = 10, trafo = function(x) abs(x))
  )
  f = makeSingleObjectiveFunction(
    fn = function(x) sum(x^2),
    par.set = par.set
  )
  des = generateDesign(10L, par.set = par.set)
  des$y  = sapply(1:nrow(des), function(i) f(as.list(des[i,])))
  or = mbo(f, des, learner, ctrl)
  expect_true(!is.na(or$y))
  expect_equal(getOptPathLength(or$opt.path), 15)
  df = as.data.frame(or$opt.path)
  expect_true(is.numeric(df$x1))

  # discrete par
  par.set = makeParamSet(
    makeNumericParam("x1", lower = -2, upper = 1),
    makeIntegerParam("x2", lower = -1, upper = 2),
    makeDiscreteParam("x3", values = c("a", "b"))
  )

  f = makeSingleObjectiveFunction(
    fn = function(x) {
      if (x[[3]] == "a")
        x[[1]]^2+x[[2]]^2
      else
        x[[1]]^2+x[[2]]^2 + 20
    },
    par.set = par.set,
    has.simple.signature = FALSE
  )

  des = generateDesign(10, par.set = par.set)
  y  = sapply(1:nrow(des), function(i) f(as.list(des[i,])))
  des$y = y
  learner = makeLearner("regr.randomForest")
  ctrl = makeMBOControl(iters = 5)
  ctrl = setMBOControlInfill(ctrl, opt.focussearch.points = 100)
  or = mbo(f, des, learner, ctrl)
  expect_true(!is.na(or$y))
  expect_equal(getOptPathLength(or$opt.path), 15)
  df = as.data.frame(or$opt.path)
  expect_true(is.numeric(df$x1))
  expect_true(is.integer(df$x2))
  expect_true(is.factor(df$x3))
  expect_true(is.numeric(df$y))
  expect_true(is.list(or$x))
  expect_equal(names(or$x), names(par.set$pars))

  # check best.predicted
  ctrl = makeMBOControl(iters = 5, final.method = "best.predicted")
  ctrl = setMBOControlInfill(ctrl, opt.focussearch.points = 100)
  or = mbo(f, des, learner, ctrl)
  expect_true(!is.na(or$y))
  expect_equal(getOptPathLength(or$opt.path), 15)

  ctrl = makeMBOControl(init.design.points = 10, iters = 5)
  ctrl = setMBOControlInfill(ctrl, opt.focussearch.points = 100)
  or = mbo(f, des = NULL, learner, ctrl)
  expect_true(!is.na(or$y))
  expect_equal(getOptPathLength(or$opt.path), 15)
  expect_equal(names(or$x), names(par.set$pars))

  # check cmaes
  par.set = makeParamSet(
    makeNumericVectorParam("v", lower = -5, upper = 5, len = 2),
    makeNumericParam("w", lower = -5, upper = 5)
  )
  f = makeSingleObjectiveFunction(
    fn = function(x) sum(x[[1]]^2) + (2 - x[[2]])^2,
    par.set = par.set
  )

  learner = makeLearner("regr.randomForest")
  ctrl = makeMBOControl(init.design.points = 10L, iters = 3L)
  ctrl = setMBOControlInfill(ctrl, opt = "cmaes", opt.cmaes.control = list(maxit = 2L))
  or = mbo(f, des = NULL, learner, ctrl)
  expect_true(!is.na(or$y))
  expect_equal(getOptPathLength(or$opt.path), 10 + 3)
  ctrl = makeMBOControl(init.design.points = 10L, iters = 3L, final.method = "best.predicted")
  ctrl = setMBOControlInfill(ctrl, opt = "cmaes", opt.cmaes.control = list(maxit = 2L))
  or = mbo(f, des = NULL, learner, ctrl)
  expect_equal(getOptPathLength(or$opt.path), 10 + 3)

  # check more.args
  par.set = makeParamSet(
    makeNumericParam("x1", lower = -2, upper = 1),
    makeNumericParam("x2", lower = -1, upper = 2)
  )

  f = makeSingleObjectiveFunction(
    fn = function(x, shift = 0) {
      sum(x^2) + shift
    },
    par.set = par.set
  )

  learner = makeLearner("regr.randomForest")
  ctrl = makeMBOControl(iters = 5L)
  ctrl = setMBOControlInfill(ctrl, opt.focussearch.points = 100L)
  or = mbo(f, des = NULL, learner, ctrl, more.args = list(shift = 0))
  expect_true(!is.na(or$y))

  # check y transformation before modelling
  par.set = makeParamSet(
    makeNumericParam("x1", lower = -1, upper = 1)
  )
  f = makeSingleObjectiveFunction(
    fn = function(x, shift = 0) {
      sum(x^2) + shift
    },
    par.set = par.set
  )

  ctrl = makeMBOControl(iters = 2L, trafo.y.fun = trafoLog(handle.violations = "error"))
  expect_error(mbo(f, control = ctrl, more.args = list(shift = -1)))
  or = mbo(f, control = ctrl, more.args = list(shift = 0))
  expect_true(!is.na(or$y))
  # negative function values not allowed when log-transforming y-values before modelling
  expect_error(mbo(f, control = ctrl, more.args = list(shift = -1)))
})

# FIXME: we do we get so bad results with so many models for this case?
# analyse visually.
# FIXME: this test is also MUCH too slow
# test_that("mbo works with logicals", {
#   f = function(x) {
#     if (x$a)
#       sum(x$b^2)
#     else
#       sum(x$b^2) + 10
#   }

#   ps = makeParamSet(
#     makeLogicalParam("a"),
#     makeNumericVectorParam("b", len = 2, lower = -3, upper = 3)
#   )
#   learner = makeBaggingWrapper(makeLearner("regr.gbm"), bag.iters = 10)
#   learner = setPredictType(learner, "se")
#   ctrl = makeMBOControl(init.design.points = 50, iters = 10)
#   ctrl = setMBOControlInfill(ctrl, crit = "ei", opt = "focussearch",
#     opt.restarts = 3, opt.focussearch.maxit = 3, opt.focussearch.points = 5000)
#   or = mbo(f, ps, learner = learner, control = ctrl, show.info = TRUE)
#   expect_true(!is.na(or$y))
#   expect_equal(getOptPathLength(or$opt.path), 60)
#   expect_equal(or$x$a, TRUE)
#   expect_true(sum(or$x$b^2) < 1)
# })

