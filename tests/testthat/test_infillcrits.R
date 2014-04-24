context("infill crits")

test_that("infill crits", {
  f1 = makeMBOFunction(function(x) sum(x^2))
  f2 = makeMBOFunction(function(x) sum(x^2) + rnorm(1, 0, 0.1))
  ps = makeNumericParamSet(len = 2L, lower = -10, upper = 10)

  ninit = 20L; niters = 3L
  mycontrol = function(minimize, noisy, crit) {
    makeMBOControl(minimize = minimize, noisy = noisy, init.design.points = ninit, iters = niters,
    infill.crit = crit, infill.opt = "focussearch", infill.opt.restarts = 1L,
    infill.opt.focussearch.points = 300L, final.evals = 10L)
  }

  mycheck = function(or, minimize) {
    expect_equal(getOptPathLength(or$opt.path), ninit + niters)
    expect_true(!is.na(or$y))
    # FIXME: reenable, but takes comp. time...
    # if (minimize)
      # expect_true(or$y < 1)
    # else
      # expect_true(or$y > 100)
    expect_true(!is.na(or$y))
  }

  learners = list(
    makeLearner("regr.km", predict.type="se"),
    makeLearner("regr.randomForest", ntree = 10, predict.type = "se")
  )

  # FIXME: we see a problem with crit="mean" here.
  # at some point we will always eval the same point.
  # kriging will then produce numerical errors, but the real problem is that
  # we have converged and just waste time. we need to detect this somehow, or cope with it
  for (noisy in c(FALSE, TRUE)) {
    for (minimize in c(TRUE, FALSE)) {
      crits = if (!noisy) c("mean", "ei") else c("aei")
      for (lrn in learners) {
        if (inherits(lrn, "regr.km"))
          lrn = setHyperPars(lrn, nugget.estim = noisy)
        for (crit in crits) {
          ctrl = mycontrol(minimize, noisy, crit)
          f = if (!noisy) f1 else f2
          or = mbo(f, ps, NULL, lrn, ctrl, show.info=FALSE)
          mycheck(or, minimize)
        }
      }
    }
  }
})

