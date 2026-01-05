# Data Understanding & Validation
use project_automobile_insurance;

# retrieving data from table
select * from auto_table;

#counting number of data from table
select count(*) as Total_records from auto_table;

# year coverage
select distinct filing_year from auto_table order by filing_year;

# Company coverage
select count(distinct Company_Name) as Total_companies from auto_table;

# check for nulls
select 
	sum(case when company_name is null then 1 else 0 end) as null_company,
    sum(case when filing_year is null then 1 else 0 end) as null_year,
    sum(case when premiums_written is null then 1 else 0 end) as null_premuims
from auto_table;
--------------------------------------------------------------------------------------------------------------------------
# Complaint Diagnostic analysis
# Complaint volume by year
select filing_year,
	sum(total_complaints) as total_complaints
from auto_table group by filing_year order by filing_year;

# complaint type distribution
select filing_year,
	sum(upheld_complaints) as upheld,
    sum(question_of_fact_complaints) as question_of_fact,
    sum(not_upheld_complaints) as not_upheld
from auto_table group by filing_year order by filing_year;

# complaint type percentage contribution
select filing_year,
	round(sum(upheld_complaints) *100.0 / sum(total_complaints),2) as pct_upheld,
    round(sum(question_of_fact_complaints) *100.0 / sum(total_complaints),2) as pct_qof,
    round(sum(not_upheld_complaints) *100.0 / sum(total_complaints),2) as pct_not_upheld
from auto_table group by filing_year order by filing_year;
--------------------------------------------------------------------------------------------------------------------------------------------------

# Company-wise complaint analysis
# total complaints per company
select company_name, 
	sum(total_complaints) as Total_complaints 
from auto_table group by company_name order by Total_complaints desc;

# Upheld complaitns per company
select company_name,
	sum(upheld_complaints) as Upheld_complaints 
from auto_table group by company_name order by Upheld_complaints desc;

# complaint trend for a selected company
select filing_year,
	sum(total_complaints) as Complaints 
from auto_table where Company_Name = 'GEICO Indemnity Company' 
group by filing_year order by filing_year;

-----------------------------------------------------------------------------------------------------------------------------------

# Premium Analysis 
# Premium trend by year
select filing_year,
	sum(premiums_written) as Total_Premiums 
from auto_table group by filing_year order by filing_year ;

# Company wise premium contribution
select company_name,
	sum(premiums_written) as Premiums
from auto_table group by Company_Name order by Premiums desc;

----------------------------------------------------------------------------------------------------------------------------------------

# Relationship analysis 
# complaints vs premiums (company level)
select Company_Name,
	sum(total_complaints) as Complaints,
    sum(premiums_written) as Premiums
from auto_table group by Company_Name;

# complaints per million dollars premium
select Company_Name,
	round(sum(upheld_complaints) / sum(premiums_written),4) as complaints_per_million
from auto_table group by company_name order by complaints_per_million desc;
---------------------------------------------------------------------------------------------------------------------------------

# Complaint ration validation (key metric)
select Company_Name,filing_year,
	round(sum(upheld_complaints) / sum(premiums_written),4) as Calculated_ratio
from auto_table group by company_name, filing_year;

---------------------------------------------------------------------------------------------------------------------------------

# Ranking analysis
# Rank companies by complaint ratio (year-wise)
select a.Company_Name, a.filing_year, a.ratio, 
(	
	select count(distinct b.ratio) from auto_table b 
    where b.filing_year = a.filing_year 
		and b.ratio < a.ratio
    )
    +1 as company_rank
from auto_table a 
order by a.filing_year, company_rank;

# Worst-performing companies
select company_name,
	avg(ratio) as avg_ratio
from auto_table group by company_name order by avg_ratio desc;

----------------------------------------------------------------------------------------------------------------------------------

# Companison of 5 Companies (dashboard support)
select company_name, 
	sum(total_complaints) as Total_complaints,
    sum(upheld_complaints) as uphled_complaints,
    sum(premiums_written) as Premiums, 
    round(avg(ratio),4) as avg_ratio 
from auto_table 
group by company_name
order by avg_ratio asc limit 5;
-----------------------------------------------------------------------------------------------------------------------------

# Final "insight" queries
# Year with highest complaints
select filing_year,
	sum(total_complaints) as Complaints
from auto_table group by filing_year order by filing_year desc limit 1;

# Company needing improvements
select company_name,
	avg(ratio) as Avg_ratio
from auto_table group by company_name order by Avg_ratio desc limit 1;

