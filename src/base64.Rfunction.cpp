#include <Rcpp.h>
#include "base64.h"

using Rcpp::RawVector;
using Rcpp::as;
using Rcpp::wrap;

RcppExport SEXP base64__encode(SEXP Rraw) {
  BEGIN_RCPP
  
  RawVector raw(Rraw);
  std::string input(raw.size(), 0);
  ::memcpy(&input[0], &raw[0], input.size());
  return wrap(Encoding::base64_encode(input));
  
  END_RCPP
}

RcppExport SEXP base64__decode(SEXP Rbase64) {
  BEGIN_RCPP
  
  std::string base64_result(Encoding::base64_decode(as<std::string>(Rbase64)));
  RawVector result(base64_result.size());
  ::memcpy(&result[0], &base64_result[0], base64_result.size());
  return result;
  
  END_RCPP
}
