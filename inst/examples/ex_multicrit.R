library(mlrMBO)
library(ggplot2)
#library(mco)
library(smoof)

set.seed(1)
configureMlr(show.learner.output = FALSE)
pause = interactive()

# f = makeMBOFunction(function(x) {
  # c(x^2, (x - 2)^2)
# })
obj.fun = makeZDT1Function(dimensions = 2L)

learner = makeLearner("regr.km", nugget.estim = FALSE, predict.type = "se")

ctrl = makeMBOControl(iters = 10L, number.of.targets = 2L,
  init.design.points = 5L, save.on.disk.at = integer(0L))
ctrl = setMBOControlInfill(ctrl, crit = "dib",
  opt.focussearch.points = 10000L)
ctrl = setMBOControlMultiCrit(ctrl, parego.s = 100)

run = exampleRunMultiCrit(obj.fun, learner, ctrl, points.per.dim = 50L,
  show.info = TRUE, nsga2.args = list(), ref.point = c(11, 11))

plotExampleRun(run, pause = pause)
