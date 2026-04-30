
## 12

Table 1. TDI entrants 1996-2005. Descriptive statistics. By first vocational rehabilitation treatment.

|Number of entrants<br>(% of all entrants in parentheses)<br>Fraction with previous employment and exhausted sick pay (%)<br>Fraction females (%)<br>Age at entry<br>Years of schooling<br>Immigrant background (%)<br>Total earnings, year prior to entry (NOK, 2013 prices)<br>…of which are labor earnings<br>…of which are social insurance transfers<br>Average duration of TDI spells with observed end-date (months)<br>(% of spells with observed end-date)<br>Spells involving more than one VR category (%)<br>Selected outcomes<br>…Average annual labor earnings next five years (NOK, 2013 prices)<br>…Average annual transf. income next five years (NOK, 2013 prices)<br>…Employment first year after the end of the TDI spell (%)<br>…Permanent disability first year after the end of the TDI spell (%)|Non-<br>Treated<br>VR1<br>VR2<br>VR3<br>VR4|
|---|---|
||176,340<br>(51.1)<br>38,842<br>(11.3)<br>19,393<br>(5.6)<br>92,476<br>(26.8)<br>18,056<br>(5.2)<br>82.2<br>69.3<br>58.7<br>70.1<br>72.1<br>57.2<br>52.6<br>48.5<br>52.1<br>51.6<br>42.5<br>37.1<br>38.4<br>35.0<br>37.3<br>10.6<br>10.5<br>10.1<br>10.6<br>10.4<br>13.0<br>10.6<br>18.1<br>13.8<br>16.7<br>373,901<br>312,715<br>271,581<br>339,088<br>331,307<br>337,368<br>262,800<br>209,762<br>287,141<br>277,410<br>36,532<br>49,916<br>61,819<br>51,946<br>53,896<br>16.3<br>(97.3)<br>32.9<br>(65.8)<br>35.0<br>(62.9)<br>38.1<br>(59.9)<br>35.3<br>(59.9)<br>-<br>45.0<br>47.2<br>42.1<br>76.6<br>163,146<br>123,840<br>67,990<br>130,694<br>115,189<br>143,873<br>158,811<br>177,030<br>165,574<br>171,175<br>46.2<br>47.6<br>20.4<br>59.8<br>50.4<br>40.2<br>35.9<br>47.7<br>20.4<br>27.1|


## The way we have designed the dataset ensures that all TDI spells are followed in

the data for at least five years. Despite that, as much as 20 % of the spells are not completed within our observation period. It follows that there are many _very_ long spells in these data, particularly among claimants who participate in vocational rehabilitation. It is also notable that among the VR-participants, 47 % participate in more than one of the four VR categories during the course of the spell.

## **3. Empirical strategy**

The aim of our empirical analysis is to evaluate how local choices of rehabilitation strategies affect the labor market outcomes for those who enter the TDI program. For each client _i_ , we define a set of outcome variables _yki_ , where the _k_ subscripts refer to the type of outcome (e.g., employment, earnings, social insurance dependency). We are going to estimate a number of linear regression equations where we use these outcomes as


---

13

dependent variables, and variables representing the employment offices’ treatment strategies as independent variables together with a large number of controls. Since local treatment strategies are unobserved, we are going to estimate them as well. We do this separately for each claimant, based on the observed choices of treatment for all _other_ claimants registering in the same local treatment environment. Let **φ i** be the vector of

local treatment strategy characteristics relevant for person _i_ (we return the identification and estimation of this vector below) _._ We then specify the reduced form outcome equations as

### ==> picture [271 x 13] intentionally omitted <==

where **[x] i**[is a vector of control variables including everything we can think of that might ] affect individual _i’s_ outcomes apart from the local treatment strategies. This includes individual characteristics (age, gender, education, nationality, past earnings, and past social insurance claims), local area socioeconomic characteristics (average education, average earnings, average mortality, and average disability rate, in all cases adjusted for sex and age and computed for both the municipality and for the employment office areas), local business cycle conditions (unemployment rate, job finding rate for unemployed, job destruction rate for employees, computed for the relevant travel-to-work area for the period from 6 months before to 18 months after entry to TDI), and also entry month indicator variables (to pick up national trends/fluctuations). To avoid unjustified functional form restriction, most of these variables are entered in a non-parametric fashion, implying that we use a large number of dummy variables. Details are provided in the Appendix.

Note that in Equation (1) it is the local treatment _strategy_ that affects person and not the actual choice of treatment for that person. This reduced form approach iden-


---

14

tifies the average program effects for all TDI-clients, and can be motivated by the idea that local treatment strategies potentially affect outcomes not only through their impacts on actually realized treatments, but also through behavioral responses towards the prospects of being offered – or pushed into – these treatments. If we are willing to assume that such indirect effects are not empirically relevant, it is also possible to estimate the effects of actual participation in the four types of vocational rehabilitation programs by means of an instrumental variables (IV) approach, a point to which we return below. This approach then provides the local average treatment effects (LATE) for the “compliers”; i.e., for the set of TDI clients whose actual treatment outcomes are manipulated by the local treatment strategies.

We now explain how we identify and estimate the local treatment strategyvector **φi** . It is designed to proxy the characteristics of the treatment environment that person _i_ is exposed to upon entry into the temporary disability insurance program. It consists of five elements, one describing the local social insurance administration’s readiness to grant PDI without trying out vocational rehabilitation first, and four elements describing the speed by which still-untreated clients are enrolled into vocational rehabilitation programs of types VR1-VR4, respectively. A treatment environment corresponds to a particular local administrative entity (social insurance office or employment office) and a particular year of entry. This implies that we exploit both the crosssectional variation across different administrative entities and the idiosyncratic variations over time within these entities (national fluctuations are absorbed by the time dummy variables). In a robustness exercise below, we exploit the persistent crosssectional variation only.


---

15

Since the treatment strategy indicators are intended to represent both the choice of (first) treatment, and the speed by which it is implemented, we compute the indicators within the framework of linear discrete transition rate models, where we condition on the same client characteristics ( _[x] i_ )[as those entering the outcome equations. The ] somewhat unusual choice of linearity in this context is made in order to make it computationally feasible to “remove” each person’s influence over the treatment strategy parameters used to explain his/her own outcomes; see below. An important advantage of linearity in this context is also that it effectively prevents differences in functional form assumptions to drive our results.[4]

To illustrate our approach, let _PSijd_ be the event of being referred to state _S, S=PDI, VR1, VR2, VR3, VR4_ , for claimant _i_ registering in the local treatment environment _j,_ and who has been at risk for the event in question in _d_ months ( _PSijd =1_ if transition _S_ occurs in that month, 0 otherwise). For each entrant to TDI, we include one observation for each month at risk of making a transition to state _S_ , starting with the first month after entry. If no event occurs in this month, we add a second month for this entrant, and so forth, until either one of the events in question has occurred or until the

TDI spell ends (e.g., because the claimant has found a job). If nothing has happened within a period of 24 months, the spells are right-censored. For each of the five treatment events, we specify a linear probability model as

### ==> picture [277 x 16] intentionally omitted <==

> 4 Had we estimated local treatment parameters  _i_ with a non-linear model (in the control variables[), non-linear direct influences of ][on the various outcomes in Equation (1) could erroneously be ]

> _[x] i[x] i_ captured by the estimated treatment parameters, and thus bias the effects of interest.

