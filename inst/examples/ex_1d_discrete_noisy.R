##### optimizing 1D fun with 3 categorical level and
##### noisy outout with random forest

library(mlrMBO)
library(ggplot2)
library(smoof)
set.seed(1)
configureMlr(show.learner.output = FALSE)
pause = interactive()

obj.fun = makeSingleObjectiveFunction(
  name = "Mixed decision space function",
  fn = function(x) {
    if (x$foo == "a") {
      return(5 + x$bar^2 + rnorm(1))
    } else if (x$foo == "b") {
      return(4 + x$bar^2 + rnorm(1, sd = 0.5))
    } else {
      return(3 + x$bar^2 + rnorm(1, sd = 1))
    }
  },
  par.set = makeParamSet(
    makeDiscreteParam("foo", values = letters[1:3]),
    makeNumericParam("bar", lower = -5, upper = 5)
  ),
  has.simple.signature = FALSE, # function expects a named list of parameter values
  noisy = TRUE
)

ctrl = makeMBOControl(init.design.points = 20L, iters = 10L)

# we can basically do an exhaustive search in 3 values
ctrl = setMBOControlInfill(ctrl, crit = "ei",
  opt.restarts = 1L, opt.focussearch.points = 3L, opt.focussearch.maxit = 1L)

lrn = makeLearner("regr.randomForest", predict.type = "se")

run = exampleRun(obj.fun, learner = lrn, control = ctrl,
	points.per.dim = 50L, show.info = TRUE)

print(run)
plotExampleRun(run, pause = pause, densregion = TRUE)
