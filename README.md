# r-power-simulation-ANOVA

I conduct a simulation analysis in R to estimate statistical power: the probability that a statistical test will reject the null hypothesis when it is false. I use the split-apply-combine strategy with R package dplyr.

This code results in a post hoc power analysis, which is not the same as a retrospective power analysis for the following reason. Let's say you just finished collecting data from a new experiment with an exciting new paradigm. Your approach is so unique that there is no precedent in the literature, and you haven't conducted any pilot studies. A retrospective power analysis in this case would be estimate power from your sample size, alpha level, and obtained effect size. The problem is, you have no idea how close the obtained effect is to the true population effect (assuming there is one), because sample effect sizes are noisy and can even be biased estimators of true effects. If, however, a population effect size can be estimated a priori by consulting the literature or previous studies in your lab, then a post hoc power analysis makes sense to do even, despite its name, before you run the study.



