
# define the parameters
mu = NULL
sigma = NULL
rho = NULL
nsubs = NULL
nsims = NULL

# create 2 factors representing the 2 independent variables
cond = data.frame(
  X1 = rep(factor(letters[1:2]), nsubs * 2),
  X2 = rep(factor(letters[1:2]), nsubs, each=2))

# create a subjects factor
subject = factor(sort(rep(1:nsubs, 4)))

# combine above into the design matrix
dm = data.frame(subject, cond)

# create k x k matrix populated with sigma
sigma.mat <- rep(sigma, 4)
S <- matrix(sigma.mat, ncol=length(sigma.mat), nrow=length(sigma.mat))

# compute covariance between measures
Sigma <- t(S) * S * rho

# put the variances on the diagonal
diag(Sigma) <- sigma^2

# stack 'nsims' individual data frames into one large data frame
df = dm[rep(seq_len(nrow(dm)), nsims), ]

# add an index column to track the simulation run
df$simID = sort(rep(seq_len(nsims), nrow(dm)))

# sample the observed data from a multivariate normal distribution
# using MASS::mvrnorm with the parameters mu and Sigma created earlier
# and bind to the existing df

require(MASS)
make.y = expression(as.vector(t(mvrnorm(nsubs, mu, Sigma))))
df$y = as.vector(replicate(nsims, eval(make.y)))

# use do(), the general purpose complement to the specialized data
# manipulation functions available in dplyr, to run the ANOVA on
# each section of the grouped data frame created by group_by

require(dplyr)
require(car)
require(broom)

mods <- df %>%
  group_by(simID) %>%
  do(model = aov(y ~ X1 * X2 + Error(subject / (X1*X2)), qr=FALSE, data = .))

# extract p-values for each effect and store in a data frame
p = data.frame(
  mods %>% do(as.data.frame(tidy(.$model[[3]])$p.value[1])),
  mods %>% do(as.data.frame(tidy(.$model[[4]])$p.value[1])),
  mods %>% do(as.data.frame(tidy(.$model[[5]])$p.value[1])))
colnames(p) = c('X1','X2','Interaction')

power = apply(as.matrix(p), 2,
              function(x) round(mean(ifelse(x < .05, 1, 0) * 100),0))

# plot the known effects
require(ggplot2)
require(gridExtra)

means = data.frame(cond[1:4, ], mu, SE = sigma / sqrt(nsubs))
plt1 = ggplot(means, aes(y = mu, x = X1, fill=X2)) +
  geom_bar(position = position_dodge(), stat="identity") +
  geom_errorbar(aes(ymin = mu-SE, ymax = mu+SE),
                position = position_dodge(width=0.9), size=.6, width=.3) +
  coord_cartesian(ylim=c((.7*min(mu)), 1.2*max(mu))) +
  theme_bw()

# melt the data into a ggplot friendly 'long' format
require(reshape2)
plotData <- melt(p, value.name = 'p')

# plot each of the p-value distributions on a log scale
options(scipen = 999) # 'turn off' scientific notation
plt2 = ggplot(plotData, aes(x = p)) +
  scale_x_log10(breaks=c(1, 0.05, 0.001),
                labels=c(1, 0.05, 0.001)) +
  geom_histogram(colour = "darkblue", fill = "white") +
  geom_vline(xintercept = 0.05, colour='red') +
  facet_grid(variable ~ .) +
  labs(x = expression(Log[10]~P)) +
  theme(axis.text.x = element_text(color='black', size=7))

# arrange plots side by side and print
grid.arrange(plt1, plt2, nrow=1)
