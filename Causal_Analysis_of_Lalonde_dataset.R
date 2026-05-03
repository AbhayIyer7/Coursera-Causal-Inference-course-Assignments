#Load Libraries

library(tableone)
library(Matching)
library(MatchIt)
library(gtools)

#Loading Data

data(lalonde)

#Data Viewing

View(lalonde) 

#Converting dataset into numeric variables

treat<-as.numeric(lalonde$treat)
age<-as.numeric(lalonde$age)
educ<-as.numeric(lalonde$educ)
black<-as.numeric(lalonde$race == 'black')
hispan<-as.numeric(lalonde$race == 'hispan')
married<-as.numeric(lalonde$married)
nodegree<-as.numeric(lalonde$nodegree)
re74<-as.numeric(lalonde$re74)
re75<-as.numeric(lalonde$re75)
re78<-as.numeric(lalonde$re78)

#creating a datset

Lalonde_dataset<-cbind(treat,age,educ,black,hispan,married,nodegree,re74,re75,re78)
Lalondedataset<-data.frame(Lalonde_dataset)

#Discriptive Statistics

xvars <- c("age", "educ", "black", "hispan", "married", "nodegree", "re74", "re75") 
discriptive_stats <- CreateTableOne(vars = xvars, strata = "treat", data = Lalondedataset, test = FALSE) 
print(discriptive_stats, smd = TRUE)

#Naive treatment effect

#Calculation of raw difference in earnings in the year 1978 without matching

mean_treated_raw <- mean(Lalondedataset$re78[Lalondedataset$treat == 1]) 
mean_control_raw <- mean(Lalondedataset$re78[Lalondedataset$treat == 0]) 
naive_treatment_effect <- mean_treated_raw - mean_control_raw 
cat("Naive Treatment Effect is: $", round(naive_treatment_effect, 2), "\n")

#Logistic regression: Propensity score

psmodel<-glm(treat~age+educ+black+hispan+married+nodegree+re74+re75,family=binomial(),data=Lalondedataset)

#summary of the model

summary(psmodel)

#Propensity scores

pscore<-psmodel$fitted.values

#nearest neigbour matching

set.seed(931)
m.out<-matchit(treat~age+educ+black+hispan+married+nodegree+re74+re75,data=Lalondedataset, method ='nearest')
summary(m.out)
matched_a <- match.data(m.out)

#Plots for propensity scores

plot(m.out,type="jitter")
plot(m.out,type="hist")

#Outcome analysis A: after nearest neighbour matching

# t test

y_treated <- matched_a$re78[matched_a$treat == 1] 
y_control <- matched_a$re78[matched_a$treat == 0] 
ttest_a <- t.test(y_treated, y_control, paired = TRUE) 
print(ttest_a)

#Average treatment effect for nearest neighbour matching

ATE_a <- mean(matched_a$re78[matched_a$treat == 1]) - mean(matched_a$re78[matched_a$treat == 0])
cat("The ATE for the dataset after nearest neigbour matching: $", round(ATE_a, 2), "\n")
print(ttest_a$conf.int)

#Matching based on logit without using caliper (No rematching allowed)

set.seed(931)
psmatch<-Match(Tr=Lalondedataset$treat,M=1,X=logit(pscore),replace=FALSE)
matched<-Lalondedataset[unlist(psmatch[c("index.treated", "index.control")]), ]
xvars<-c("age","educ","black","hispan","married","nodegree","re74","re75")
matchedtab1<-CreateTableOne(vars=xvars, strata ="treat",data=matched, test=FALSE)
print(matchedtab1,smd = TRUE)

# Summary of the logit match 

summary(psmatch)

#Logit match plots

plot(pscore ~ treat, data = Lalondedataset, main = "Propensity Score Distribution: Logit Match", xlab = "Treatment (0 = Control, 1 = Treated)", ylab = "Propensity Score", col = c("red", "blue"))

#Outcome analysis B: after logit matching without using caliper

#ttest

y_tr_b <- Lalondedataset$re78[psmatch$index.treated] 
y_ct_b <- Lalondedataset$re78[psmatch$index.control] 
ttest_b <- t.test(y_tr_b, y_ct_b, paired = TRUE)

#Average treatment effect for logit matching

ATE_b <- mean(matched$re78[matched$treat == 1]) - mean(matched$re78[matched$treat == 0])
cat("The ATE for the dataset after logit matching: $", round(ATE_b, 2), "\n")
print(ttest_b$conf.int)

print(ttest_b)

#Matching based on logit using a caliper of 0.1 (No rematching allowed)

set.seed(931)
logitpsmatch<-Match(Tr=Lalondedataset$treat,M=1,X=logit(pscore),replace=FALSE, caliper=0.1)
logitmatched<-Lalondedataset[unlist(logitpsmatch[c("index.treated", "index.control")]), ]
xvars<-c("age","educ","black","hispan","married","nodegree","re74","re75")
logitmatchedtab1<-CreateTableOne(vars=xvars, strata ="treat",data=logitmatched, test=FALSE)
print(logitmatchedtab1,smd = TRUE)

#Summary of logit match with caliper 0.1

summary(logitpsmatch)

#Number of dropped participants in logit matching using a caliper of 0.1

total_treated <- sum(treat) 
matched_pairs <- length(logitpsmatch$index.treated) 
dropped_participants <- total_treated - matched_pairs 
cat("Total treated in dataset:", total_treated, "\n") 
cat("Number dropped:", dropped_participants, "\n")

#Outcome analysis C: after logit matching using a caliper of 0.1

#ttest

y_tr_c <- Lalondedataset$re78[logitpsmatch$index.treated] 
y_ct_c <- Lalondedataset$re78[logitpsmatch$index.control] 
ttest_c <- t.test(y_tr_c, y_ct_c, paired = TRUE)

#Average treatment effect for logit matching

ATE_c <- mean(logitmatched$re78[logitmatched$treat == 1]) - mean(logitmatched$re78[logitmatched$treat == 0])
cat("The ATE for the dataset after logit matching: $", round(ATE_c, 2), "\n")
print(ttest_c$conf.int)
print(ttest_c)
