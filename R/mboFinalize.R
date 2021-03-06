#' @title Finalizes an mbo run from a save-file.
#'
#' @description
#' Useful if your optimization didn't terminate but you want a results nonetheless.
#'
#' @param file [\code{character(1)}]\cr
#'   File path of saved MBO state.
#'   See \code{save.on.disk.at} argument of \code{\link{MBOControl}} object.
#' @return See \code{\link{mbo}}.
#' @export
mboFinalize = function(file) {
  assertCharacter(file, len = 1L)
  opt.state = loadOptState(file)
  state = getOptStateState(opt.state)
  if (state %in% getTerminateChars()) {
    warningf("Optimization ended with %s. No need to finalize Simply returning stored result.", state)
    return(getOptResultMboResult(getOptStateOptResult(opt.state)))
  }
  setOptStateState(opt.state, getTerminateChars("manual"))
  mboFinalize2(opt.state)
}

mboFinalize2 = function(opt.state) {
  mbo.result = makeOptStateMboResult(opt.state)
  opt.problem = getOptStateOptProblem(opt.state)
  # save on disk routine
  if (getOptStateLoop(opt.state) %in% getOptProblemControl(opt.problem)$save.on.disk.at || is.finite(getOptProblemControl(opt.problem)$save.on.disk.at.time))
    saveOptState(opt.state)
  
  # restore mlr configuration
  configureMlr(
    on.learner.error = getOptProblemOldopts(opt.problem)[["ole"]], 
    show.learner.output = getOptProblemOldopts(opt.problem)[["slo"]]
  )
  mbo.result
}
