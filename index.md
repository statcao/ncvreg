---
---


`ncvreg` is an R package for fitting regularization paths for linear regression, GLM, and Cox regression models using lasso or nonconvex penalties, in particular the minimax concave penalty (MCP) and smoothly clipped absolute deviation (SCAD) penalty, with options for additional L<sub>2</sub> penalties (the "elastic net" idea).  Utilities for carrying out cross-validation as well as post-fitting visualization, summarization, inference, and prediction are also provided.

This site focuses mainly on illustrating the usage and syntax of `visreg` as a way of providing online documentation.  For more on the algorithms used by `ncvreg`, see the original article:

* [Breheny P and Huang J (2011).  Coordinate descent algorithms for nonconvex penalized regression, with applications to biological feature selection.  *Annals of Applied Statistics*, 5: 232--253](http://myweb.uiowa.edu/pbreheny/pdf/Breheny2011.pdf)

For more about the marginal false discovery rate idea used for post-selection inference, see

* [Breheny P (to appear).  Marginal false discovery rates for penalized regression models.  *Biostatistics*](https://arxiv.org/pdf/1607.05636)

# Installation

`ncvreg` is on CRAN, so it can be installed via:


```r
install.packages("ncvreg")
```

# Brief introduction

`ncvreg` comes with a few example data sets; we'll look at `Prostate`, which has 8 features and one continuous response, the PSA levels (on the log scale) from men about to undergo radical prostatectomy:


```r
data(Prostate)
X <- Prostate$X
y <- Prostate$y
```

To fit a penalized regression model to this data:


```r
fit <- ncvreg(X, y)
```

The default penalty here is the minimax concave penalty (MCP), but SCAD and lasso penalties are also available.  This produces a path of coefficients, which we can plot with


```r
plot(fit)
```

![plot of chunk plot](img/index-plot-1.png)

Notice that variables enter the model one at a time, and that at any given value of $\lambda$, several coefficients are zero.  To see what the coefficients are, we could use the `coef` function:


```r
coef(fit, lambda=0.05)
```

```
## (Intercept)      lcavol     lweight         age        lbph         svi 
##  0.35121089  0.53178994  0.60389694 -0.01530917  0.08874563  0.67256096 
##         lcp     gleason       pgg45 
##  0.00000000  0.00000000  0.00168038
```

The `summary` method can be used for post-selection inference:


```r
summary(fit, lambda=0.05)
```

```
## MCP-penalized linear regression with n=97, p=8
## At lambda=0.0500:
## -------------------------------------------------
##   Nonzero coefficients: 6
##   Expected nonzero coefficients: 3.85
##   mFDR: 0.642
##   (local) Expected nonzero coefficients: 2.51
##   (local) Overall mfdr (6 features)    : 0.418
## 
##         Estimate      z      mfdr
## lcavol   0.53179  8.880   < 1e-04
## svi      0.67256  3.945 0.0018967
## lweight  0.60390  3.666 0.0050683
## lbph     0.08875  1.928 0.4998035
## age     -0.01531 -1.788 1.0000000
## pgg45    0.00168  1.160 1.0000000
```

In this case, it would appear that `lcavol`, `svi`, and `lweight` are clearly associated with the response, even after adjusting for the other variables in the model, while `lbph`, `age`, and `pgg45` may be false positives included simply by chance.

Typically, one would carry out cross-validation for the purposes of assessing the predictive accuracy of the model at various values of $\lambda$:


```r
cvfit <- cv.ncvreg(X, y)
plot(cvfit)
```

![plot of chunk cvplot](img/index-cvplot-1.png)

The value of $\lambda$ that minimizes the cross-validation error is given by `cvfit$lambda.min`, which in this case is 0.024.  Applying `coef` to the output of `cv.ncvreg` returns the coefficients at that value of $\lambda$:


```r
coef(cvfit)
```

```
##  (Intercept)       lcavol      lweight          age         lbph 
##  0.494155488  0.569546029  0.614419592 -0.020913469  0.097352619 
##          svi          lcp      gleason        pgg45 
##  0.752398445 -0.104959575  0.000000000  0.005324463
```

Predicted values can be obtained via `predict`, which has a number of options:


```r
predict(cvfit, X=head(X))
```

```
##         1         2         3         4         5         6 
## 0.8304041 0.7650906 0.4262073 0.6230117 1.7449492 0.8449595
```

```r
predict(cvfit, type="nvars")  # Number of nonzero coefficients
```

```
## 0.02402 
##       7
```

Note that the original fit (to the full data set) is returned as `cvfit$fit`; it is not necessary to call both `ncvreg` and `cv.ncvreg` to analyze a data set.  For example, `plot(cvfit$fit)` will produce the same coefficient path plot as `plot(fit)` above.
