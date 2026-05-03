# Coursera-Causal-Inference-course-Assignments
**Propensity Score Matching**

**Overview**

This project was an assignment for an online course titled "A crash course on causality: Infering causal effects from observational data". This assignment evaluates the impact of a job training program on participant earnings using the Lalonde Dataset. 

This repository contains a ".R" file consiting of the script and a  powerpoint presentation containing the result output.

**Problem**

In an observational study, participants in the treatment and control groups may differ from each other in the basline of covariates before the intervention begins. Hence, Naive treatment effect may not be accurate due to the presence of confounds. 

**Solution**

To address the limitations of naive treatment effect, this code implements a 1:1 propensity score matching in R. The matching methods used are greedy matching, logit matching (uses logit of the propensity scores) and logit matching with a caliper of 0.1.  Standardised mean differences were used to assess wether the balance of covariates across the two groups were statistically comparable. 

**Execution**

Libraries used: tableone, matching, MatchIt, gtools

Required packages can be installed in R by using install.packages() command. The name of the resspective package is typed inside the brackets of the command.

To run the script on R studio, please ensure the required libraries are installed. Then, copy and paste the script on the console.
