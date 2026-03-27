
16

where **d** is a vector of duration dummy variables (1,2,…,24) and **[x]** _i_[is the same vector ] ˆ of controls as we use in Equation (1). Now, let _p Sijd_ be the predictions from OLS estimation of (2) and let _u_ ˆ _Sijd_ be the corresponding residuals. Furthermore, let _DSi_ be the realized duration at which individual _i_ was under risk of the event in question. We then have that the sum of individual _i’s_ residuals can be written

### ==> picture [282 x 30] intentionally omitted <==

On average, the sums of individual residuals are by construction equal to zero. To illustrate their interpretation, we abstract for a moment from right-censoring and duration ˆ dependence, and denote the (then) constant event probability _p Sij_ . The right-hand side ˆ of (3) then simplifies to 1  _DSi pSij_ . Since expected duration until an event for person _i_ is

ˆ the inverse of the event probability ( _E_ ( _Dsi_ )  1/ _pSij_ ) , we also have that ˆ ˆ ˆ _uSij_  ( _DSi_  _E_ [ _DSi_ ]) _pSij_ , i.e., _uSij_ is equal to minus the number of “excess” waiting months (compared to what we would expect on the basis of **[x] i**[), weighted by the transi-] tion probabilities. If the sum of individual residuals is positive (negative), the claimant has made the transition in question more quickly (slowly) than what would be predicted on the basis of observed characteristics, and the weight attributed to a given deviation is ˆ larger the less likely it is to occur. The sum _uSij_ can thus be interpreted as the estimated covariate-adjusted transition propensity at the claimant level. A natural indicator for the local treatment environment’s contribution to this propensity is therefore the average sum of residuals among its clients; i.e.

### ==> picture [266 x 20] intentionally omitted <==


---

17

where _N j_ is the number of clients subject to treatment environment _j_ (defined by ad-

ministrative entity and year of entry).

A potential problem with using  _Sj_ directly as a covariate in relation to person

_i’s_ outcomes in Equation (1) is that we have used the treatment outcome for that very same person to estimate it. Hence, if there is a correlation between the residuals in Equations (1) and (2) – which seems plausible – our estimates of causal effects will be biased. We deal with this problem by removing client _i_ from the computation of his/her own local rehabilitation strategy indicators. We then compute the local treatment strategy parameters relevant for person _i_ as

### ==> picture [260 x 33] intentionally omitted <==

which is then exogenous to individual _i_ , provided that the distribution of clients to treatment environments can be considered as good as randomly assigned, conditional on

> _[.]_[ Hence, it is important that ][is sufficiently rich and flexible to account for the resi-]

> **[x] i[x] i** dential sorting into the different social insurance districts. If treatment environments with, say, particularly high measured PDI propensities also systematically tend to have clients with particularly poor employment prospects after **[x] i**[is controlled for, this condi-] tion is violated. We return to this issue below in a series of robustness and placebo analyses. It is also clear that our treatment strategy indicators are at best _proxies_ for some unobserved _true_ local treatment strategies; i.e., they are measured with error. This implies that the estimated impacts of the treatment strategies will be biased toward zero. Hence, in this sense, our estimates may be viewed as lower bounds on the true effects.

For post-TDI outcomes, we also estimate an instrumental variables model where we use observed program participation directly as explanatory variables, and instrument


---

18

them with the vector of local program intensity indicators in **φ i** . Let **P** _i_   _P_ 1 _i_ , _P_ 2 _i_ , _P_ 3 _i_ , _P_ 4 _i_  be a vector of variables indicating that a treatment starting with the corresponding type of VR program was initiated at some time during a TDI spell. We then write the outcome equations as

### ==> picture [284 x 14] intentionally omitted <==

Here,  _k_ can be interpreted as the effects of actually participating in the different programs _compared to being non-treated_ , regardless of when the first transition to treatment occurred. Since the elements in **[P] i**[  are likely to be highly correlated with the re-] siduals  _ki_ , we instrument them by the corresponding indicators computed in Equation (5), i.e.,  _VR_ 1 _j_ ,  _i_ ,  _VR_ 2 _j_ ,  _i_ ,  _VR_ 3 _j_ ,  _i_ ,  _VR_ 4 _j_ ,  _i_  . This implies that if the true effects of program participation are heterogeneous – which seems plausible – our estimates will have a local average treatment effect (LATE) interpretation; i.e., for each program, the estimated effect is representative for the sub-population whose participation in that particular program is manipulated by the local treatment strategy parameters.[5] Since these parameters also can be interpreted directly as the labor market authorities’ decision variables, the IV-strategy yields treatment effect estimates of high policy relevance. It also solves the errors-in-variables problem referred to above, since the measurement error is corrected for through the first step estimation where individual treatment outcomes are regressed on the treatment strategy proxies. Validity of IV model requires, however, that the local

> 5 Given that we have all four endogenous and mutually exclusive treatment outcomes simultaneously as right-hand-side variables in Equation (6), it is perhaps not obvious that the IV (two-step least squares) coefficients are consistent estimators for the true treatment effects _relative to non-treatment_ for the respective complier groups. We have therefore verified this interpretation by means of a Monte Carlo (MC) experiment where we generated multiple treatments with a data-generating process similar to the one used here. A brief description of the MC experiment and its results are available here: http://www.frisch.uio.no/docs/MC_multi_treatment.html


---

19

treatment strategies affect the TDI claimants through the probabilities of actual participation only.

Our methodological approach is similar in spirit to the one used by Duggan (2005) to characterize psychiatrists’ propensities to prescribe particular drugs, by Doyle (2008) to characterize child protection investigators’ propensities to place children in foster care, and by Markussen _et al_ . (2012) to characterize physicians’ propensities to impose activity requirements on sick-listed workers.

## **4. The local treatment strategies**

How important are the local treatment strategies for actual treatment events? To answer this question we add the strategy indicators ( **φ i** ) into the duration models in Equation (2), and examine their predictive power for actual choices of treatment strategies. Some results are given in Table 2. To facilitate interpretation, we have scaled the treatment policy indicators such that a unit difference corresponds to the average difference (taken over all 10 years) between the local administrations using the respective strategies least and most; hence the reported parameters can be interpreted as the expected percentage point change in monthly entry probabilities resulting from a movement from the treatment environment giving lowest priority to the strategy under consideration to the one giving it highest priority. Recall, however, that measurement error will tend to bias these coefficients toward zero.

It is evident from Table 2 that the local treatment strategies have significant impacts on the claimants’ treatment outcomes. As expected, it is the propensity to use the treatment strategy under consideration that is most important (the diagonal elements in Table 2). In addition, we find that a high local propensity to grant permanent disability

