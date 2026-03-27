
# 28

If local treatment strategies respond to local cyclical fluctuations in a way unaccounted for by our business cycle indicators, our estimators could be confounded by reverse causation. To assess this potential problem, we re-estimate all our models on the basis of treatment strategy indicators that are constant over time across local administrations. This implies that we treat each local administrative entity as representing the same treatment environment throughout the data period, and that the corresponding indexes are obtained by summing over all residuals  belonging to the entities in question in Equation (4), regardless of year of entry. Hence, in this exercise, we only exploit the persistent cross-sectional variation in treatment strategies.

Table 5. Robustness analysis. Instrumental variables estimates of VR-participation on post-TDI outcomes with constant treatment strategy indicators (no time-variation within administrative units) used as instruments (standard errors in parentheses)

|inparentheses)||
|---|---|
|Actual participation<br>in:<br>VR1<br>VR2<br>VR3<br>VR4<br>N|I<br>Employment<br>(p.p.)<br>II<br>Labor earnings<br>(NOK)<br>III<br>Permanent disability<br>(p.p.)<br>IV<br>Social insurance<br>transfers (NOK)|
||23.448***<br>(8.269)<br>89,778***<br>(30,382)<br>-6.399<br>(13.503)<br>-83,125***<br>(20,406)<br>-24.034**<br>(9.351)<br>-67,751*<br>(36,170)<br>25.159<br>(19.220)<br>32,858<br>(34,645)<br>10.407<br>(7.074)<br>63,076**<br>(24,021)<br>-26.721***<br>(9.336)<br>-29,719<br>(19,028)<br>-17.280<br>(13.510)<br>-52,210<br>(52,274)<br>-7.531<br>(21.573)<br>-19,887<br>(36,864)<br>274,500<br>274,500<br>275,628<br>274,500|


Notes: Coefficients report impacts measured in percentage points (columns I and III) or NOK (measured in 2013 prices). List of additional control variables used in all the regressions is provided in the Appendix. The number of observations (N) is slightly higher for the PDI outcome (Column III) for the reason that these outcomes are observed with more accurate timing, and hence do not require a full post-treatment calendar year to be identified. The reported standard errors are robust, clustered on administrative units. *(**)(***) Significant at the 10(5)(1) % level.

# For ease of comparison, we focus on the instrumental variables estimates in this

robustness exercise.[11] What happens when we use treatment strategy indicators that are

# constant within each administrative unit is that virtually all the estimated impacts be-

> 11 It is more difficult to compare the reduced form estimates, since the variation in the estimated treatment strategy indexes are much larger when they vary by both district and year than when they vary by district only. All the qualitative conclusions are the same, however.


---

29

come a bit larger; see Table 5. At the same time, the sizes of the standard errors rise considerably, reflecting the significant loss of variation in the instruments. All the major conclusions remain unchanged, however.

As a further check for remaining bias, we also run “placebo”-regressions, using _past_ earnings as the outcome measure instead of future earnings. For this purpose, we use the same sample of TDI-spells and the exact same statistical reduced form model as we use in our main analysis. Since we have conditioned on earnings 1-3 year before entry, our “placebo” outcomes are in this case average earnings 4 and 5 years _before_ entry to TDI, respectively. If there is a systematic correlation between the choice of local treatment strategies and the resources of the claimant population, it is probable that this show up in “effects” on past earnings as well as on future earnings. As is clear from the results in Table 6, there is no indication of bias in this sense.

Table 6. Results from placebo regressions (standard errors in parenthesis)

|VR1-intensity<br>VR2-intensity<br>VR3-intensity<br>VR4-intensity<br>PDI-intensity<br>N|Average earnings 4 years before<br>(NOK)<br>Average earnings 5 years before<br>(NOK)|
|---|---|
||-975<br>(1,329)<br>-2,579<br>(1,693)<br>-1,273<br>(1,017)<br>-271<br>(1,233)<br>1,616<br>(1,145)<br>463<br>(1,345)<br>451<br>(650)<br>530<br>(793)<br>-366<br>(1,108)<br>221<br>(1,316)<br>330,890<br>303,577|


Notes: VR and PDI intensities are normalized such that a unit difference corresponds to the average difference (taken over all 10 years) between the two local administrations using the respective strategies least and most. All outcomes are measured in NOK and inflated to the 2013 price level. Reduced sample sizes for the TDI claimants reflect missing information on past earnings. List of additional control variables used in all the regressions is provided in the Appendix. The reported standard errors are robust, clustered on social insurance districts. *(**)(***) Significant at the 10(5)(1) % level.

As a final test for confounders related to local cyclical fluctuations, we investi-

gate whether our treatment strategy indicators are correlated with outcomes for locals

who did _not_ participate in TDI. In this exercise we use the exact same statistical reduced


---

# 30

form model as in the main analysis, and also the same future 5-year earnings outcome. We look at two different populations. The first is a set of matched groups of locals with

no relationship to the social insurance and employment offices at the time of matching to a TDI entrant. This is done in the following way: For each TDI claimant, we find a non-client who lives in the same neighborhood, who has the same sex, is of approximately the same age (+/- 2 years), and has the same level and type of education (35 different categories).[12] If treatment strategies are correlated to uncontrolled for local labor market opportunities for the population of TDI clients, it should be traceable in the earnings developments of these similar non-claimants also.

Table 7. Results from regressions based on local non-TDI populations. Effects on average earnings next five years (NOK) (standard errors in parenthesis)

|(standard errors inparenthesis)||
|---|---|
|VR1-intensity<br>VR2-intensity<br>VR3-intensity<br>VR4-intensity<br>PDI-intensity<br>N|Matched sample of local non-<br>clients<br>Matched sample of ordinary un-<br>employed|
||-3,069**<br>(1,315)<br>1,456<br>(1,933)<br>-1,288<br>(1,078)<br>3,933**<br>(1,572)<br>1,329<br>(1,333)<br>2,236<br>(1,768)<br>-215<br>(738)<br>-1,793<br>(1,109)<br>-51<br>(1,031)<br>4,474**<br>(1,790)<br>308,949<br>222,343|


Notes: VR and PDI intensities are normalized such that a unit difference corresponds to the average difference (taken over all 10 years) between the two local administrations using the respective strategies least and most. All outcomes are measured in NOK and inflated to the 2013 price level. Reduced sample sizes reflect missing matches of sufficient quality. List of additional control variables used in all the regressions is provided in the Appendix. The reported standard errors are robust, clustered on social insurance districts. *(**)(***) Significant at the 10(5)(1) % level.

The second group is a matched population of regular unemployed who registered at the same employment offices during exactly the same time period as our TDI-

> 12 For this purpose, we use additional complete population data, made available to us by Statistics Norway.


---

31

clients. We use the same matching criteria as for local non-clients.[13] Note also that this latter population may not be a clean placebo group, since ordinary unemployed job seekers are clients at the same employment offices as the VR-participants, and, hence, may be subject to similar caseworker strategies and also share some of the same (perhaps limited) program resources.

The results from these exercises are shown in Table 7. For the matched group of non-clients, there is little evidence that future labor market performance is correlated to the local treatment environment. A notable exception is that high local VR1-propensity seems to correlate _negatively_ with future labor earnings. Taken at face value, this may indicate that VR1 is disproportionally used in economic environments with particularly poor employment outlooks for persons with characteristics corresponding to the TDIpopulation. This is the opposite of what we would worry about if we were concerned that the positive impact identified for TDI-claimants was spurious. Turning to unemployed job seekers, we see that future labor earnings correlate positively with the use of sheltered employment (VR2) for TDI-clients, and also with the tendency to grant TDIclients permanent disability insurance without ever referring them to vocational programs. Since both these policies typically imply that the employment offices need to spend less time and energy on TDI-claimants, their apparently positive impacts on ordinary unemployed can probably be explained by more resources becoming available for this group of clients. In any case, the significant coefficients again go in the opposite direction of what we would worry about if we were concerned that our main results were spuriously related to unobserved local labor market fluctuations.

> 13 Since the population of unemployed is much smaller than the population of non-clients, we lose some observations in this exercise; see Table 7.

